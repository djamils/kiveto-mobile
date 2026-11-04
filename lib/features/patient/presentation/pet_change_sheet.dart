import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/patient/di.dart';
import 'package:kiveto_mobile/features/patient/domain/pet.dart';
import 'package:kiveto_mobile/features/patient/domain/pet_change.dart';
import 'package:kiveto_mobile/features/patient/presentation/pet_messages.dart';
import 'package:kiveto_mobile/features/patient/presentation/pet_providers.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/intent_key.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/formatters/kiveto_format.dart';
import 'package:kiveto_mobile/shared/presentation/icons/kiveto_icon.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// The longest proposed value and note the contract takes.
const _valueMaxLength = 120;
const _noteMaxLength = 500;

/// The change request of [pet] in [clinicId] (« Signaler une
/// modification » on screen 2), in a sheet over the navigation: what to
/// change, its new value (a weight with the day it was measured, a
/// sterilization by the pet's sex…), a note, « Envoyer la demande »; then
/// « Demande envoyée ». The clinic checks each change before it updates
/// the sheet: the server answers for every value.
Future<void> showPetChangeSheet(
  BuildContext context, {
  required PetSummary pet,
  required ClinicId clinicId,
}) => showKivetoSheet<void>(
  context: context,
  builder: (context) => PetChangeSheet(pet: pet, clinicId: clinicId),
);

/// The content of the change request sheet (see [showPetChangeSheet]).
class PetChangeSheet extends ConsumerStatefulWidget {
  const new({required this.pet, required this.clinicId, super.key});

  final PetSummary pet;
  final ClinicId clinicId;

  @override
  ConsumerState<PetChangeSheet> createState() => _PetChangeSheetState();
}

class _PetChangeSheetState extends ConsumerState<PetChangeSheet> {
  final _name = TextEditingController();
  final _weight = TextEditingController();
  final _chipNumber = TextEditingController();
  final _other = TextEditingController();
  final _note = TextEditingController();

  /// One key per content: a retry of the same request sends the same key.
  late final _intent = IntentKey<PetChangeDraft>(
    ref.read(idempotencyKeyFactoryProvider),
  );
  PetChangeField? _field;
  Sterilization? _sterilization;

  /// The day of the weighing, once picked (none: the day of the request).
  LocalDate? _measuredOn;
  bool _sending = false;
  Object? _error;
  bool _sent = false;

  @override
  void dispose() {
    _name.dispose();
    _weight.dispose();
    _chipNumber.dispose();
    _other.dispose();
    _note.dispose();
    super.dispose();
  }

  /// The request to send: a field and its value; null before.
  PetChangeDraft? get _draft {
    final field = _field;
    if (field == null) return null;
    final value = switch (field) {
      PetChangeField.name => _name.text.trim(),
      PetChangeField.weight => _weight.text.trim(),
      PetChangeField.sterilization => sterilizationValues[_sterilization] ?? '',
      PetChangeField.chipNumber => _chipNumber.text.trim(),
      PetChangeField.other || PetChangeField.unknown => _other.text.trim(),
    };
    if (value.isEmpty) return null;
    return PetChangeDraft(
      field: field,
      proposedValue: value,
      measuredOn: field == PetChangeField.weight ? _measuredOn : null,
      note: switch (_note.text.trim()) {
        '' => null,
        final note => note,
      },
    );
  }

  /// Any edit: the form changed, the last answer no longer applies.
  void _edited() => setState(() => _error = null);

  Future<void> _send() async {
    final draft = _draft;
    if (draft == null || _sending) return;
    final key = _intent.keyFor(draft);
    setState(() {
      _sending = true;
      _error = null;
    });
    final repository = ref.read(petChangeRepositoryProvider);
    final container = ProviderScope.containerOf(context, listen: false);
    try {
      await repository.requestChange(
        widget.clinicId,
        widget.pet.id,
        draft,
        key,
      );
      // Sent whatever became of the sheet: the pet's sheet shows it
      // pending.
      container.invalidate(petChangeRequestsProvider);
      if (!mounted) return;
      setState(() {
        _sending = false;
        _sent = true;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = error;
      });
    }
  }

  Future<void> _pickMeasuredOn() async {
    final today = deviceToday(ref.read(clockProvider));
    final shown = _measuredOn ?? today;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(shown.year, shown.month, shown.day),
      firstDate: DateTime(today.year - 30),
      lastDate: DateTime(today.year, today.month, today.day),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _measuredOn = LocalDate(picked.year, picked.month, picked.day);
      _error = null;
    });
  }

  /// The message of the violation of [path] in the last answer, shown
  /// under its field.
  String? _violation(String path) => switch (_error) {
    ValidationFailure(:final violations) =>
      violations
          .where((violation) => violation.propertyPath == path)
          .firstOrNull
          ?.message,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_sent) {
      return _SheetFrame(
        child: SheetSuccessView(
          title: l10n.petChangeDoneTitle,
          message: l10n.petChangeDoneBody,
          action: KivetoButton.primary(
            label: l10n.petChangeDoneClose,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      );
    }
    final field = _field;
    final error = _error;
    final sending = _sending;
    final draft = _draft;
    final other = field == PetChangeField.other;
    final message = error == null
        ? null
        : petChangeFailureMessage(
            l10n,
            error,
            shown: {
              'proposedValue',
              'note',
              if (field == PetChangeField.weight) 'measuredOn',
            },
          );
    return KivetoSheet(
      title: l10n.petReportChange,
      subtitle: l10n.petChangeSubtitle(widget.pet.name),
      // The sheet sets its children 8 apart; the groups are 18 apart
      // (8 + 2 + 8), as on screen 16.
      children: [
        _Group(
          legend: l10n.petChangeFieldLegend,
          child: Wrap(
            spacing: KivetoSpace.sm,
            runSpacing: KivetoSpace.sm,
            children: [
              for (final value in [
                PetChangeField.name,
                PetChangeField.weight,
                PetChangeField.sterilization,
                PetChangeField.chipNumber,
                PetChangeField.other,
              ])
                KivetoChoiceChip(
                  label: petChangeFieldLabel(l10n, value),
                  selected: value == field,
                  onSelected: sending
                      ? null
                      : () => setState(() {
                          _field = value;
                          _error = null;
                        }),
                ),
            ],
          ),
        ),
        if (field != null) ...[_gap, _input(l10n, field)],
        _gap,
        KivetoTextField.multiline(
          label: other ? l10n.petChangeNoteOther : l10n.petChangeNote,
          optional: !other,
          largeLabel: false,
          helpText: other ? l10n.petChangeNoteOtherHelp : null,
          errorText: _violation('note'),
          controller: _note,
          maxLength: _noteMaxLength,
          enabled: !sending,
          onChanged: (_) => _edited(),
        ),
        if (message != null) ...[
          _gap,
          KivetoCallout.danger(
            body: message,
            actionLabel: isTransientPetChangeFailure(error!)
                ? l10n.commonRetry
                : null,
            onAction: () => unawaited(_send()),
          ),
        ],
        _gap,
        KivetoButton.primary(
          label: l10n.petChangeSend,
          loading: sending,
          onPressed: draft == null || sending ? null : () => unawaited(_send()),
        ),
      ],
    );
  }

  /// The input of the new value of [field].
  Widget _input(AppLocalizations l10n, PetChangeField field) {
    final sending = _sending;
    final error = _violation('proposedValue');
    KivetoTextField text(
      TextEditingController controller,
      String label, {
      String? hint,
      String? help,
      TextInputType? keyboard,
    }) => KivetoTextField(
      label: label,
      hintText: hint,
      helpText: help,
      errorText: error,
      controller: controller,
      keyboardType: keyboard,
      maxLength: _valueMaxLength,
      enabled: !sending,
      onChanged: (_) => _edited(),
    );
    switch (field) {
      case PetChangeField.name:
        return text(_name, l10n.petChangeNewName);
      case PetChangeField.weight:
        final measuredOn = _measuredOn;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            text(
              _weight,
              l10n.petChangeNewWeight,
              hint: l10n.petChangeNewWeightHint,
              keyboard: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: KivetoSpace.xl),
            _DateField(
              label: l10n.petChangeMeasuredOn,
              value: measuredOn == null
                  ? l10n.petChangeMeasuredToday
                  : KivetoFormat.dayMonthYear(measuredOn),
              errorText: _violation('measuredOn'),
              onTap: sending ? null : () => unawaited(_pickMeasuredOn()),
            ),
          ],
        );
      case PetChangeField.sterilization:
        final sex = widget.pet.sex;
        return _Group(
          legend: l10n.petChangeFieldSterilization,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: KivetoSpace.sm,
                runSpacing: KivetoSpace.sm,
                children: [
                  for (final value in sterilizationValues.keys)
                    KivetoChoiceChip(
                      label: sterilizationChoiceLabel(l10n, value, sex),
                      selected: value == _sterilization,
                      onSelected: sending
                          ? null
                          : () => setState(() {
                              _sterilization = value;
                              _error = null;
                            }),
                    ),
                ],
              ),
              if (error != null) ...[
                const SizedBox(height: KivetoSpace.s),
                Text(
                  error,
                  style: KivetoText.caption.copyWith(
                    color: KivetoColors.danger,
                  ),
                ),
              ],
            ],
          ),
        );
      case PetChangeField.chipNumber:
        return text(
          _chipNumber,
          l10n.petChangeChipNumber,
          help: l10n.petChangeChipNumberHelp,
          keyboard: TextInputType.number,
        );
      case PetChangeField.other || PetChangeField.unknown:
        return text(
          _other,
          l10n.petChangeOtherValue,
          hint: l10n.petChangeOtherValueHint,
        );
    }
  }
}

/// The message of the sheet's callout for [error]: a violation no field
/// shows (those of [shown] sit under their field: none then), the codes of
/// the Portal API, else the shared message of the failure kind.
String? petChangeFailureMessage(
  AppLocalizations l10n,
  Object error, {
  Set<String> shown = const {},
}) => switch (error) {
  ValidationFailure(:final violations) when violations.isNotEmpty =>
    violations
        .where((violation) => !shown.contains(violation.propertyPath))
        .firstOrNull
        ?.message,
  ApiFailure(code: 'pet_not_eligible') => l10n.petChangeNotEligible,
  RateLimitedFailure() => l10n.requestRateLimited,
  NotFoundFailure() => l10n.petChangeNotFound,
  final other => failureMessage(l10n, other).$2,
};

/// The failure may go away by sending the same request again (the
/// network, the server): the same key goes with it.
bool isTransientPetChangeFailure(Object error) =>
    error is NetworkFailure || error is ServerFailure;

/// Two more points between two children of the sheet (8 apart): the 18
/// between its groups.
const _gap = SizedBox(height: KivetoSpace.xxs);

/// A group of choices with its legend (14/700, 10 above the choices),
/// announced as one group.
class _Group extends StatelessWidget {
  const new({required this.legend, required this.child});

  final String legend;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: legend,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(child: Text(legend, style: KivetoText.labelStrong)),
        const SizedBox(height: KivetoSpace.m),
        child,
      ],
    ),
  );
}

/// « Pesé le »: a C-18a box with the calendar glyph and the day
/// (« Aujourd'hui » until one is picked); it opens the date picker.
class _DateField extends StatelessWidget {
  const new({
    required this.label,
    required this.value,
    required this.onTap,
    this.errorText,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final errorText = this.errorText;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(KivetoRadius.m),
      side: BorderSide(
        color: errorText == null
            ? KivetoColors.borderStrong
            : KivetoColors.danger,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(child: Text(label, style: KivetoText.labelSmall)),
        const SizedBox(height: KivetoSpace.s),
        Semantics(
          button: true,
          label: label,
          value: value,
          hint: errorText,
          onTap: onTap,
          excludeSemantics: true,
          child: Material(
            color: KivetoColors.surface,
            shape: shape,
            child: InkWell(
              onTap: onTap,
              customBorder: shape,
              splashFactory: NoSplash.splashFactory,
              overlayColor: const WidgetStatePropertyAll(
                KivetoColors.inkPressed,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      const KivetoIcon(
                        LucideGlyph.calendar,
                        size: 18,
                        color: KivetoColors.inkMuted,
                      ),
                      const SizedBox(width: KivetoSpace.m),
                      Expanded(child: Text(value, style: KivetoText.input)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: KivetoSpace.s),
          ExcludeSemantics(
            child: Text(
              errorText,
              style: KivetoText.caption.copyWith(color: KivetoColors.danger),
            ),
          ),
        ],
      ],
    );
  }
}

/// The handle and paddings of a sheet without title (its success state).
class _SheetFrame extends StatelessWidget {
  const new({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.fromLTRB(
      KivetoSpace.gutter,
      10,
      KivetoSpace.gutter,
      kivetoBottomPadding(context, 28),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: KivetoColors.borderChip,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        const SizedBox(height: KivetoSpace.xl2),
        child,
      ],
    ),
  );
}
