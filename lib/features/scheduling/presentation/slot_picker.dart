import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_messages.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_providers.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/formatters/kiveto_format.dart';
import 'package:kiveto_mobile/shared/presentation/icons/kiveto_icon.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// The days of one page of the day picker.
const _pageDays = 7;

/// The practitioner choice and C-25 (mockup 03): a week of days (7
/// columns: the API answers every day, Sundays included), the morning and
/// afternoon slots of the selected day; shared by the booking (3) and the
/// reschedule. Only the slots the server answered are offered; the slots
/// seen taken ([takenSlots]) stay struck through in their day.
///
/// The weeks are pages of 7 days from [today]; one availability request
/// covers two pages (14 days), the third page asks for the next window.
/// [onPractitioner] when another practitioner is chosen, [onSlot] with the
/// practitioner when a slot is.
class SlotPicker extends ConsumerStatefulWidget {
  const new({
    required this.clinicId,
    required this.motifId,
    required this.today,
    required this.selectedPractitionerId,
    required this.selectedSlot,
    required this.takenSlots,
    required this.onPractitioner,
    required this.onSlot,
    super.key,
    this.warning,
  });

  final ClinicId clinicId;
  final MotifId motifId;

  /// The first day of the first page (the device's today).
  final LocalDate today;

  /// Null: the first practitioner of the list.
  final PractitionerId? selectedPractitionerId;
  final ClinicInstant? selectedSlot;

  /// The slots another booking took meanwhile (`409 slot_taken`).
  final Iterable<ClinicInstant> takenSlots;
  final ValueChanged<Practitioner> onPractitioner;
  final void Function(Practitioner practitioner, ClinicInstant slot) onSlot;

  /// A warning above the days (« Ce créneau vient d'être pris… »).
  final String? warning;

  @override
  ConsumerState<SlotPicker> createState() => _SlotPickerState();
}

class _SlotPickerState extends ConsumerState<SlotPicker> {
  /// The page shown (0: the 7 days from today).
  late int _page;

  /// The furthest page shown so far: its windows stay read, so paging
  /// back and forth sends no request again.
  late int _furthest;

  /// The day the owner tapped on the page shown (null: the page's first
  /// day with a slot, else its first open day).
  LocalDate? _day;

  @override
  void initState() {
    super.initState();
    final slot = widget.selectedSlot;
    _page = slot == null
        ? 0
        : math.max(0, widget.today.daysUntil(slot.date) ~/ _pageDays);
    _furthest = _page;
  }

  void _goTo(int page) => setState(() {
    _page = page;
    _furthest = math.max(_furthest, page);
    _day = null;
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final practitioners = ref.watch(
      practitionersProvider((widget.clinicId, widget.motifId)),
    );
    return switch (practitioners) {
      AsyncValue(isLoading: true, hasError: true) => const _Loading(),
      AsyncData(value: final list) when list.isEmpty => _Message(
        l10n.bookingNoPractitioner,
      ),
      AsyncData(value: final list) => _picker(context, l10n, list),
      AsyncError(:final error) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(
          practitionersProvider((widget.clinicId, widget.motifId)),
        ),
      ),
      _ => const _Loading(),
    };
  }

  Widget _picker(
    BuildContext context,
    AppLocalizations l10n,
    List<Practitioner> practitioners,
  ) {
    final practitioner = practitioners.firstWhere(
      (candidate) => candidate.id == widget.selectedPractitionerId,
      orElse: () => practitioners.first,
    );
    final warning = widget.warning;
    final (shown, key, before) = _window(practitioner);
    // The day shown stays shown with another practitioner (when open).
    final shownDay = switch (shown) {
      AsyncData(value: final window) => _selectedDay(_pageOf(window))?.date,
      _ => null,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          container: true,
          label: l10n.bookingVetLabel,
          child: Wrap(
            spacing: KivetoSpace.sm,
            runSpacing: KivetoSpace.sm,
            children: [
              for (final candidate in practitioners)
                KivetoChoiceChip(
                  label: practitionerLabel(l10n, candidate.displayName),
                  selected: candidate.id == practitioner.id,
                  onSelected: candidate.id == practitioner.id
                      ? () {}
                      : () {
                          setState(() => _day = shownDay);
                          widget.onPractitioner(candidate);
                        },
                ),
            ],
          ),
        ),
        if (warning != null) ...[
          const SizedBox(height: KivetoSpace.xl3),
          KivetoCallout.warning(body: warning),
        ],
        const SizedBox(height: KivetoSpace.xl3),
        switch (shown) {
          AsyncValue(isLoading: true, hasError: true) => const _Loading(),
          AsyncData(value: final window) => _days(
            context,
            l10n,
            practitioner,
            window,
            before,
          ),
          AsyncError(:final error) => ErrorView(
            error: error,
            onRetry: () => ref.invalidate(availabilityProvider(key)),
          ),
          _ => const _Loading(),
        },
        const SizedBox(height: KivetoSpace.xl3),
        KivetoFootnote(l10n.bookingSlotFootnote),
      ],
    );
  }

  /// The window of the page shown, its key, and the window before it (null
  /// for the first): the windows up to it are watched in turn (each starts
  /// where the previous one ended), and those read beyond it stay watched.
  (AsyncValue<AvailabilityWindow>, AvailabilityKey, AvailabilityWindow?)
  _window(Practitioner practitioner) {
    final needed = _page ~/ 2;
    final kept = math.max(needed, _furthest ~/ 2);
    AsyncValue<AvailabilityWindow>? shown;
    AvailabilityKey? shownKey;
    AvailabilityWindow? before;
    var start = widget.today;
    for (var window = 0; window <= kept; window++) {
      final key = (widget.clinicId, widget.motifId, practitioner.id, start);
      final value = ref.watch(availabilityProvider(key));
      if (window == needed) {
        shown = value;
        shownKey = key;
      }
      if (value case AsyncData(:final value)) {
        if (window == needed - 1) before = value;
        start = value.next;
      } else {
        if (window < needed) {
          shown = value;
          shownKey = key;
        }
        break;
      }
    }
    return (shown!, shownKey!, before);
  }

  /// The days of the page shown, out of its window.
  List<AvailabilityDay> _pageOf(AvailabilityWindow window) {
    final from = math.min(_page % 2 * _pageDays, window.days.length);
    return window.days.sublist(
      from,
      math.min(from + _pageDays, window.days.length),
    );
  }

  Widget _days(
    BuildContext context,
    AppLocalizations l10n,
    Practitioner practitioner,
    AvailabilityWindow window,
    AvailabilityWindow? before,
  ) {
    final days = _pageOf(window);
    final last = _page.isOdd || window.days.length <= _pageDays;
    bool open(AvailabilityWindow? window) =>
        window == null || window.days.any((day) => day.open);
    // The horizon is passed when two windows in a row (28 days) are closed:
    // one closed window may be a closure (the summer), with days after it.
    final next = last
        ? open(window) || open(before)
        : window.days.length > _pageDays;
    final day = _selectedDay(days);
    final weekHasSlot = days.any((candidate) => candidate.slots.isNotEmpty);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                days.isEmpty
                    ? ''
                    : KivetoFormat.monthRange(days.first.date, days.last.date),
                style: KivetoText.labelStrong,
              ),
            ),
            _PageButton(
              glyph: LucideGlyph.chevronLeft,
              label: l10n.bookingPreviousWeek,
              onPressed: _page > 0 ? () => _goTo(_page - 1) : null,
            ),
            _PageButton(
              glyph: LucideGlyph.chevronRight,
              label: l10n.bookingNextWeek,
              onPressed: next ? () => _goTo(_page + 1) : null,
            ),
          ],
        ),
        const SizedBox(height: KivetoSpace.m),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < _pageDays; i++) ...[
              if (i > 0) const SizedBox(width: KivetoSpace.s),
              Expanded(
                child: i < days.length
                    ? _DayCell(
                        key: ValueKey('day-${days[i].date}'),
                        day: days[i],
                        selected: days[i].date == day?.date,
                        onTap: () => setState(() => _day = days[i].date),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ],
        ),
        const SizedBox(height: KivetoSpace.xl3),
        if (!weekHasSlot && !days.any(_hasTaken))
          _Message(l10n.bookingNoSlotWeek)
        else if (day != null)
          _slots(l10n, practitioner, day),
      ],
    );
  }

  bool _hasTaken(AvailabilityDay day) => _taken(day).isNotEmpty;

  /// The slots of [day] seen taken that the fresh answer no longer has.
  List<ClinicInstant> _taken(AvailabilityDay day) => [
    for (final slot in widget.takenSlots)
      if (slot.date == day.date && !day.slots.any(slot.isAtSameMomentAs)) slot,
  ];

  /// The day tapped if still open on the page, else the day of the chosen
  /// slot, else a day with a slot taken meanwhile, else the first day with
  /// a slot, else the first open day.
  AvailabilityDay? _selectedDay(List<AvailabilityDay> days) {
    AvailabilityDay? find(bool Function(AvailabilityDay day) test) {
      for (final day in days) {
        if (test(day)) return day;
      }
      return null;
    }

    final tapped = _day;
    final slot = widget.selectedSlot;
    return (tapped == null
            ? null
            : find((day) => day.date == tapped && day.open)) ??
        (slot == null ? null : find((day) => day.date == slot.date)) ??
        find(_hasTaken) ??
        find((day) => day.slots.isNotEmpty) ??
        find((day) => day.open);
  }

  Widget _slots(
    AppLocalizations l10n,
    Practitioner practitioner,
    AvailabilityDay day,
  ) {
    final entries = [
      for (final slot in day.slots) (slot: slot, taken: false),
      for (final slot in _taken(day)) (slot: slot, taken: true),
    ]..sort((a, b) => a.slot.compareTo(b.slot));
    if (entries.isEmpty) return _Message(l10n.bookingNoSlotDay);
    final morning = [
      for (final entry in entries)
        if (entry.slot.hour < 12) entry,
    ];
    final afternoon = [
      for (final entry in entries)
        if (entry.slot.hour >= 12) entry,
    ];
    final selected = widget.selectedSlot;
    Widget period(
      String label,
      List<({ClinicInstant slot, bool taken})> slots,
    ) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(label, style: KivetoText.labelStrong),
        ),
        const SizedBox(height: KivetoSpace.m),
        _SlotGrid(
          children: [
            for (final entry in slots)
              _SlotCell(
                key: ValueKey('slot-${entry.slot}'),
                time: KivetoFormat.time(entry.slot),
                taken: entry.taken,
                selected:
                    !entry.taken &&
                    selected != null &&
                    selected.isAtSameMomentAs(entry.slot),
                onTap: () {
                  // The day stays shown after the slot is taken meanwhile.
                  setState(() => _day = entry.slot.date);
                  widget.onSlot(practitioner, entry.slot);
                },
              ),
          ],
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (morning.isNotEmpty) period(l10n.bookingMorning, morning),
        if (morning.isNotEmpty && afternoon.isNotEmpty)
          const SizedBox(height: KivetoSpace.xl),
        if (afternoon.isNotEmpty) period(l10n.bookingAfternoon, afternoon),
      ],
    );
  }
}

class _Loading extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) =>
      const SizedBox(height: 160, child: LoadingView());
}

/// A grey line where slots would be.
class _Message extends StatelessWidget {
  const new(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: KivetoSpace.sm),
    child: Text(text, style: KivetoText.body),
  );
}

/// The previous or next week: a 44 icon button, disabled at the ends.
class _PageButton extends StatelessWidget {
  const new({
    required this.glyph,
    required this.label,
    required this.onPressed,
  });

  final LucideGlyph glyph;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onPressed != null,
    label: label,
    excludeSemantics: true,
    child: InkResponse(
      onTap: onPressed,
      radius: 22,
      child: SizedBox.square(
        dimension: 44,
        child: Center(
          child: KivetoIcon(
            glyph,
            color: onPressed == null
                ? KivetoColors.inkUnavailable
                : KivetoColors.ink,
          ),
        ),
      ),
    ),
  );
}

/// A day of C-25: weekday 11/600 over the number 18/700, min-height 60,
/// radius 10; selected brand, open white, closed dashed on canvas (not
/// tappable).
class _DayCell extends StatelessWidget {
  const new({
    required this.day,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final AvailabilityDay day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final open = day.open;
    final foreground = selected
        ? KivetoColors.surface
        : open
        ? KivetoColors.ink
        : KivetoColors.inkUnavailable;
    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            KivetoFormat.weekdayShort(day.date),
            style: kivetoTextStyle(11, FontWeight.w600, color: foreground),
          ),
          const SizedBox(height: KivetoSpace.xxs),
          Text(
            '${day.date.day}',
            style: kivetoTextStyle(18, FontWeight.w700, color: foreground),
          ),
        ],
      ),
    );
    final radius = BorderRadius.circular(KivetoRadius.m);
    return Semantics(
      button: open,
      enabled: open,
      selected: selected,
      label: KivetoFormat.dayLong(day.date),
      excludeSemantics: true,
      child: open
          ? Material(
              color: selected ? KivetoColors.brand : KivetoColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: radius,
                side: BorderSide(
                  color: selected ? KivetoColors.brand : KivetoColors.border,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                splashFactory: NoSplash.splashFactory,
                overlayColor: const WidgetStatePropertyAll(
                  KivetoColors.inkPressed,
                ),
                child: content,
              ),
            )
          : KivetoDashedBorder(
              color: KivetoColors.borderChip,
              radius: KivetoRadius.m,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: KivetoColors.canvas,
                  borderRadius: radius,
                ),
                child: content,
              ),
            ),
    );
  }
}

/// The slots of a period: 4 columns, gap 8.
class _SlotGrid extends StatelessWidget {
  const new({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var row = 0; row < children.length; row += 4) ...[
        if (row > 0) const SizedBox(height: KivetoSpace.sm),
        Row(
          children: [
            for (var i = row; i < row + 4; i++) ...[
              if (i > row) const SizedBox(width: KivetoSpace.sm),
              Expanded(
                child: i < children.length
                    ? children[i]
                    : const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      ],
    ],
  );
}

/// A slot of C-25: min-height 44, radius 10, 14/600; selected brand, free
/// white, taken struck through on canvas (not tappable).
class _SlotCell extends StatelessWidget {
  const new({
    required this.time,
    required this.taken,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String time;
  final bool taken;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (fill, border, foreground) = selected
        ? (KivetoColors.brand, KivetoColors.brand, KivetoColors.surface)
        : taken
        ? (
            KivetoColors.canvas,
            KivetoColors.divider,
            KivetoColors.inkUnavailable,
          )
        : (KivetoColors.surface, KivetoColors.borderStrong, KivetoColors.ink);
    return Semantics(
      button: !taken,
      enabled: !taken,
      selected: selected,
      label: taken ? l10n.bookingSlotTakenLabel(time) : time,
      excludeSemantics: true,
      child: Material(
        color: fill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KivetoRadius.m),
          side: BorderSide(color: border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: taken ? null : onTap,
          splashFactory: NoSplash.splashFactory,
          overlayColor: const WidgetStatePropertyAll(KivetoColors.inkPressed),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Center(
              child: Text(
                time,
                style: KivetoText.label.copyWith(
                  color: foreground,
                  decoration: taken ? TextDecoration.lineThrough : null,
                  decorationColor: foreground,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
