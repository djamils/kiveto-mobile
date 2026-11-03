import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderException;
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/consultation/consultation.dart';
import 'package:kiveto_mobile/features/document/document.dart';
import 'package:kiveto_mobile/features/patient/di.dart';
import 'package:kiveto_mobile/features/patient/domain/care_item.dart';
import 'package:kiveto_mobile/features/patient/domain/pet.dart';
import 'package:kiveto_mobile/features/patient/presentation/pet_messages.dart';
import 'package:kiveto_mobile/features/patient/presentation/pet_providers.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/formatters/kiveto_format.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// Screen 2, « Fiche animal » (mockup 02): a pet of the active clinic, its
/// identity, its care items and vaccination booklet, its visit history.
/// [petId] picks the pet (the route's); without it, or for a pet the
/// clinic does not list, the first pet of `GET /pets`. With several pets a
/// switcher shows another one without navigating.
///
/// Exits: [onBack]; [onReportChange] with the pet's id (the change
/// request, slice 6).
class PetPage extends ConsumerStatefulWidget {
  const new({
    required this.onBack,
    required this.onReportChange,
    super.key,
    this.petId,
    this.request,
  });

  final String? petId;

  /// The navigation that opened the sheet: a new value (a new navigation
  /// to the sheet, the same pet included) drops the switcher's choice.
  final Object? request;
  final void Function(BuildContext context) onBack;
  final void Function(BuildContext context, String petId) onReportChange;

  @override
  ConsumerState<PetPage> createState() => _PetPageState();
}

class _PetPageState extends ConsumerState<PetPage> {
  /// The pet chosen in the switcher (null: the route's). A choice the
  /// clinic's list does not hold any more falls back to the route's pet.
  PetId? _selected;

  @override
  void didUpdateWidget(PetPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.petId != widget.petId ||
        oldWidget.request != widget.request) {
      _selected = null;
    }
  }

  /// The pet shown (the switcher's choice, else the route's, else the
  /// first), and its position in the clinic's list (its colour).
  (PetSummary, int) _shown(List<PetSummary> pets) {
    int? indexOf(bool Function(PetSummary pet) test) {
      for (var i = 0; i < pets.length; i++) {
        if (test(pets[i])) return i;
      }
      return null;
    }

    final index =
        indexOf((pet) => pet.id == _selected) ??
        indexOf((pet) => pet.id.value == widget.petId) ??
        0;
    return (pets[index], index);
  }

  void _retryPets(Object error) {
    // A 404: the link with the clinic may be gone, /me says which clinics
    // remain. A failure of /me reaches the pets through the active clinic.
    if (_cause(error) is NotFoundFailure || ref.read(meProvider).hasError) {
      ref.invalidate(meProvider);
    }
    ref.invalidate(petsProvider);
  }

  /// Pull-to-refresh: the pets, the sheets, the care items, the visits;
  /// done when the list answered.
  Future<void> _refresh() async {
    ref
      ..invalidate(petsProvider)
      ..invalidate(petDetailProvider)
      ..invalidate(careItemsProvider)
      ..invalidate(petTimelineProvider);
    try {
      await ref.read(petsProvider.future);
    } on Object {
      // The page shows the failure.
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: KivetoColors.canvas,
    body: SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: KivetoColors.brand,
        onRefresh: _refresh,
        child: CustomScrollView(
          // A short page can be pulled too.
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: _content(context),
        ),
      ),
    ),
  );

  List<Widget> _content(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget padded(Widget sliver) => SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        KivetoSpace.gutter,
        KivetoSpace.xl,
        KivetoSpace.gutter,
        KivetoSpace.xl3,
      ),
      sliver: sliver,
    );
    Widget fill(Widget child) =>
        SliverFillRemaining(hasScrollBody: false, child: child);
    final back = _TopRow(onBack: () => widget.onBack(context));
    final loading = [
      padded(
        SliverList.list(
          children: [
            back,
            const SizedBox(height: KivetoSpace.xl3),
            const KivetoSkeleton(),
          ],
        ),
      ),
    ];
    switch (ref.watch(petsProvider)) {
      // A retry after an error: loading, not the error again.
      case AsyncValue(isLoading: true, hasError: true):
        return loading;
      case AsyncData(value: []):
        final clinic = switch (ref.watch(activeClinicProvider)) {
          AsyncData(:final value) => value,
          _ => null,
        };
        return [
          padded(SliverToBoxAdapter(child: back)),
          fill(
            EmptyState(
              glyph: LucideGlyph.pawPrint,
              title: l10n.petEmptyTitle,
              body: clinic == null ? null : l10n.petEmptyBody(clinic.name),
            ),
          ),
        ];
      case AsyncData(:final value):
        final (pet, index) = _shown(value);
        return [
          padded(
            SliverMainAxisGroup(
              slivers: [
                SliverList.list(
                  children: [
                    _TopRow(
                      onBack: () => widget.onBack(context),
                      switcher: value.length < 2
                          ? null
                          : _PetSwitcher(
                              pets: value,
                              selected: pet.id,
                              onChanged: (id) => setState(() => _selected = id),
                            ),
                    ),
                    const SizedBox(height: KivetoSpace.xl3),
                    _PetHeader(pet: pet, index: index),
                    const SizedBox(height: KivetoSpace.xl3),
                    _IdentityGrid(pet: pet),
                    const SizedBox(height: KivetoSpace.xl3),
                    KivetoButton.outline(
                      label: l10n.petReportChange,
                      icon: LucideGlyph.penLine,
                      expand: true,
                      onPressed: () =>
                          widget.onReportChange(context, pet.id.value),
                    ),
                    const SizedBox(height: KivetoSpace.s),
                    KivetoFootnote(
                      l10n.petReportChangeCaption,
                      small: true,
                      centered: true,
                    ),
                    const SizedBox(height: KivetoSpace.xl3),
                    _CareSection(pet: pet),
                    const SizedBox(height: KivetoSpace.xl3),
                  ],
                ),
                PetTimelineSection(key: ValueKey(pet.id), petId: pet.id.value),
              ],
            ),
          ),
        ];
      case AsyncError(:final error):
        return [
          padded(SliverToBoxAdapter(child: back)),
          fill(ErrorView(error: error, onRetry: () => _retryPets(error))),
        ];
      default:
        return loading;
    }
  }
}

/// The top row of the sheet: back (its glyph on the gutter), the pet
/// switcher centred, a 34 px balance on the right.
class _TopRow extends StatelessWidget {
  const new({required this.onBack, this.switcher});

  final VoidCallback onBack;
  final Widget? switcher;

  @override
  Widget build(BuildContext context) {
    final switcher = this.switcher;
    return Row(
      children: [
        // The 44 px button drawn 10 px into the gutter (margin-left −10).
        SizedBox(
          width: 34,
          height: 44,
          child: OverflowBox(
            maxWidth: 44,
            alignment: AlignmentDirectional.centerEnd,
            child: KivetoIconButton.back(onPressed: onBack, offset: 0),
          ),
        ),
        Expanded(child: switcher ?? const SizedBox.shrink()),
        const SizedBox(width: 34),
      ],
    );
  }
}

/// C-15b: the pets of the clinic, compact segments, scrolling sideways when
/// they do not fit; the selected pet is brought into view.
class _PetSwitcher extends StatefulWidget {
  const new({
    required this.pets,
    required this.selected,
    required this.onChanged,
  });

  final List<PetSummary> pets;
  final PetId selected;
  final ValueChanged<PetId> onChanged;

  @override
  State<_PetSwitcher> createState() => _PetSwitcherState();
}

class _PetSwitcherState extends State<_PetSwitcher> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _revealSelected();
  }

  @override
  void didUpdateWidget(_PetSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) _revealSelected();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// After layout: scrolls in proportion to the selected pet's place, so
  /// that a pet at the end of a long list shows (nothing when it fits).
  void _revealSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final position = _scroll.position;
      final pets = widget.pets;
      final index = pets.indexWhere((pet) => pet.id == widget.selected);
      if (position.maxScrollExtent <= 0 || index < 0 || pets.length < 2) {
        return;
      }
      _scroll.jumpTo(
        (position.maxScrollExtent * index / (pets.length - 1)).clamp(
          position.minScrollExtent,
          position.maxScrollExtent,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: AppLocalizations.of(context).petSwitcherLabel,
    child: LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: Center(
            child: KivetoSegmentedControl<PetId>(
              compact: true,
              segments: [
                for (final pet in widget.pets) KivetoSegment(pet.id, pet.name),
              ],
              selected: widget.selected,
              onChanged: widget.onChanged,
            ),
          ),
        ),
      ),
    ),
  );
}

/// The avatar, the name, the species · breed · sex line, and the pill of a
/// pet no longer followed.
class _PetHeader extends StatelessWidget {
  const new({required this.pet, required this.index});

  final PetSummary pet;
  final int index;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final line = petLine(l10n, pet);
    final life = lifeStatusLabel(l10n, pet.lifeStatus, pet.sex);
    return Row(
      children: [
        InitialsAvatar(
          pet.initial,
          size: 64,
          tone: AvatarTone.forPetIndex(index),
        ),
        const SizedBox(width: KivetoSpace.xl),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(pet.name, style: KivetoText.pageTitle),
              ),
              if (line.isNotEmpty) ...[
                const SizedBox(height: KivetoSpace.xs),
                Text(line, style: KivetoText.body),
              ],
              if (life != null) ...[
                const SizedBox(height: KivetoSpace.s),
                StatusPill(life, tone: StatusTone.neutral),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// C-11f: the identity grid (birth date, weight, chip, vet) of the pet's
/// sheet; its own loading and retry.
class _IdentityGrid extends ConsumerWidget {
  const new({required this.pet});

  final PetSummary pet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = petDetailProvider(pet.id);
    switch (ref.watch(provider)) {
      case AsyncValue(isLoading: true, hasError: true):
        return const _Loading();
      case AsyncData(:final value):
        final today = deviceToday(ref.watch(clockProvider));
        final birthDate = value.summary.birthDate;
        final weight = value.lastWeight;
        final none = l10n.petNone;
        return KivetoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _GridRow(
                left: _Cell(
                  label: bornLabel(l10n, value.summary.sex),
                  value: Text(
                    birthDate == null
                        ? none
                        : KivetoFormat.numericDate(birthDate),
                    style: KivetoText.itemValue,
                  ),
                ),
                right: _Cell(
                  label: l10n.petWeight,
                  value: weight == null
                      ? Text(none, style: KivetoText.itemValue)
                      : Text.rich(
                          TextSpan(
                            text: weightLabel(l10n, weight),
                            children: [
                              TextSpan(
                                text: ' · ${careDate(weight.at, today)}',
                                style: KivetoText.captionMedium,
                              ),
                            ],
                          ),
                          style: KivetoText.itemValue,
                        ),
                ),
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: KivetoColors.divider,
              ),
              _GridRow(
                left: _Cell(
                  label: l10n.petChip,
                  value: Text(
                    value.chipNumberMasked ?? none,
                    style: KivetoText.itemValue,
                  ),
                ),
                right: _Cell(
                  label: l10n.petReferentVet,
                  value: Text(
                    value.referentVet ?? none,
                    style: KivetoText.itemValue,
                  ),
                ),
              ),
            ],
          ),
        );
      case AsyncError(:final error):
        return ErrorView(
          error: error,
          onRetry: () {
            if (ref.read(meProvider).hasError) ref.invalidate(meProvider);
            ref.invalidate(provider);
          },
        );
      default:
        return const _Loading();
    }
  }
}

/// A row of the identity grid: two cells and the line between them.
class _GridRow extends StatelessWidget {
  const new({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: left),
        const ColoredBox(
          color: KivetoColors.divider,
          child: SizedBox(width: 1),
        ),
        Expanded(child: right),
      ],
    ),
  );
}

/// A cell of the identity grid: its label (12, grey) over its value.
class _Cell extends StatelessWidget {
  const new({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(KivetoSpace.l),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: KivetoText.caption),
        const SizedBox(height: KivetoSpace.xxs),
        value,
      ],
    ),
  );
}

/// « Vaccins et préventions »: the « Carnet PDF » button and the care
/// items of the pet; their own loading and retry.
class _CareSection extends ConsumerWidget {
  const new({required this.pet});

  final PetSummary pet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final clinicId = switch (ref.watch(activeClinicProvider)) {
      AsyncData(value: final clinic?) => clinic.clinicId,
      _ => null,
    };
    final provider = careItemsProvider(pet.id);
    final items = switch (ref.watch(provider)) {
      AsyncValue(isLoading: true, hasError: true) => const _Loading(),
      AsyncData(value: []) => Text(
        l10n.petCareEmpty,
        style: KivetoText.bodySmall,
      ),
      AsyncData(:final value) => _CareList(items: value),
      AsyncError(:final error) => ErrorView(
        error: error,
        onRetry: () {
          if (ref.read(meProvider).hasError) ref.invalidate(meProvider);
          ref.invalidate(provider);
        },
      ),
      _ => const _Loading(),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KivetoSectionHeader(
          l10n.petCareTitle,
          trailing: KivetoButton.tonal(
            label: l10n.petBooklet,
            icon: LucideGlyph.download,
            onPressed: clinicId == null
                ? null
                : () => _openBooklet(context, l10n, clinicId),
          ),
        ),
        const SizedBox(height: KivetoSpace.m),
        items,
      ],
    );
  }

  void _openBooklet(
    BuildContext context,
    AppLocalizations l10n,
    ClinicId clinicId,
  ) => unawaited(
    openPdfFile(
      context,
      title: l10n.petBookletTitle(pet.name),
      load: (ref) =>
          ref.read(petRepositoryProvider).vaccinationBooklet(clinicId, pet.id),
    ),
  );
}

/// The care items of a pet (C-11a, padding 13 14): label, the line of its
/// status, its pill.
class _CareList extends ConsumerWidget {
  const new({required this.items});

  final List<CareItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final today = deviceToday(ref.watch(clockProvider));
    return KivetoCard.list(
      children: [
        for (final item in items)
          KivetoListRow(
            title: item.label,
            meta: careSubLine(l10n, item, today),
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
            trailing: CareStatusPill(
              status: item.status,
              dueOn: item.dueOn,
              today: today,
            ),
          ),
      ],
    );
  }
}

/// A part of the sheet still loading.
class _Loading extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: KivetoSpace.xl3),
    child: LoadingView(),
  );
}

/// The error a provider failed with (an error that reached it through
/// another provider arrives wrapped in [ProviderException]s).
Object _cause(Object error) =>
    error is ProviderException ? _cause(error.exception) : error;
