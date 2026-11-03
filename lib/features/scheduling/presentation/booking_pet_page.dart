import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/patient/patient.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/booking_layout.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/booking_wizard.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_messages.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/domain/species.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
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

/// The longest name the server takes for a new pet.
const _maxNameLength = 80;

/// The species a new pet may have.
const List<Species> _species = [
  Species.dog,
  Species.cat,
  Species.nac,
  Species.other,
];

/// Screen 12, step 1 of the booking (mockup 12): the clinic (its chip opens
/// the switcher when the account has several), « Pour quel animal ? », the
/// pets of the clinic still followed (the first one chosen), « Un autre
/// animal » (a name and a species: the booking creates the pet).
///
/// Exits: [onContinue] once a pet is chosen, [onClose] (back and close:
/// the first step).
class BookingPetPage extends ConsumerStatefulWidget {
  const new({required this.onContinue, required this.onClose, super.key});

  final void Function(BuildContext context) onContinue;
  final void Function(BuildContext context) onClose;

  @override
  ConsumerState<BookingPetPage> createState() => _BookingPetPageState();
}

class _BookingPetPageState extends ConsumerState<BookingPetPage> {
  /// The pet tapped (null: the first one listed).
  String? _petId;

  /// « Un autre animal » is open.
  bool _newPet = false;
  final _name = TextEditingController();
  Species? _newSpecies;

  @override
  void initState() {
    super.initState();
    // Back on the first step: the choice made.
    switch (ref.read(bookingWizardProvider).draft.pet) {
      case ExistingPet(:final petId):
        _petId = petId;
      case NewPet(:final name, :final species):
        _newPet = true;
        _name.text = name;
        _newSpecies = species;
      case null:
        break;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _reset() => setState(() {
    _petId = null;
    _newPet = false;
    _name.clear();
    _newSpecies = null;
  });

  void _retry(Object error) {
    // A 404: the link with the clinic may be gone, /me says which remain;
    // a failure of /me reaches the pets through the active clinic.
    if (failureCause(error) is NotFoundFailure ||
        ref.read(meProvider).hasError) {
      ref.invalidate(meProvider);
    }
    ref.invalidate(petsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Another clinic: its pets, and a new draft.
    ref.listen<ClinicId?>(
      bookingWizardProvider.select((state) => state.draft.clinicId),
      (previous, next) => _reset(),
    );
    final today = deviceToday(ref.watch(clockProvider));
    final pets = ref.watch(petsProvider);
    final listed = switch (pets) {
      AsyncData(:final value) => [
        for (final (index, pet) in value.indexed)
          if (pet.lifeStatus != LifeStatus.deceased &&
              pet.lifeStatus != LifeStatus.missing)
            (index: index, pet: pet),
      ],
      _ => null,
    };
    // Without a pet followed, only a new one.
    final newPet = _newPet || (listed != null && listed.isEmpty);
    final chosen = newPet || listed == null
        ? null
        : (listed.where((entry) => entry.pet.id.value == _petId).firstOrNull ??
                  listed.first)
              .pet;
    final name = _name.text.trim();
    final species = _newSpecies;
    final pet = newPet
        ? (name.isNotEmpty && name.length <= _maxNameLength && species != null
              ? NewPet(name, species)
              : null)
        : switch (chosen) {
            final PetSummary chosen => ExistingPet(
              chosen.id.value,
              chosen.name,
            ),
            null => null,
          };
    return FlowScaffold(
      bar: StickySummaryBar(
        label: l10n.bookingPetBarLabel,
        value: newPet
            ? (name.isEmpty ? l10n.bookingNewPetBarValue : name)
            : chosen?.name ?? '',
        action: KivetoButton.primary(
          label: l10n.commonContinue,
          size: KivetoButtonSize.medium,
          onPressed: pet == null
              ? null
              : () {
                  ref.read(bookingWizardProvider.notifier).choosePet(pet);
                  widget.onContinue(context);
                },
        ),
      ),
      children: [
        WizardHeader(
          step: 1,
          stepLabel: l10n.bookingStepLabel(1),
          title: l10n.screenBookingPetTitle,
          onBack: () => widget.onClose(context),
          onClose: () => widget.onClose(context),
          overTitle: const _ClinicChip(),
        ),
        switch (pets) {
          AsyncValue(isLoading: true, hasError: true) => const _Loading(),
          AsyncData() => _pets(l10n, listed ?? const [], chosen, newPet, today),
          AsyncError(:final error) => ErrorView(
            error: error,
            onRetry: () => _retry(error),
            title: failureCause(error) is NotFoundFailure
                ? l10n.appointmentsClinicGoneTitle
                : null,
            message: failureCause(error) is NotFoundFailure
                ? l10n.appointmentsClinicGoneBody
                : null,
          ),
          _ => const _Loading(),
        },
        KivetoFootnote(l10n.bookingPetFootnote),
      ],
    );
  }

  Widget _pets(
    AppLocalizations l10n,
    List<({int index, PetSummary pet})> listed,
    PetSummary? chosen,
    bool newPet,
    LocalDate today,
  ) => Semantics(
    container: true,
    label: l10n.bookingPetLabel,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (:index, :pet) in listed) ...[
          KivetoRadioCard(
            title: pet.name,
            subtitle: bookingPetLine(l10n, pet, today),
            leading: InitialsAvatar(
              pet.initial,
              size: 48,
              pet: true,
              tone: AvatarTone.forPetIndex(index),
            ),
            selected: !newPet && pet.id == chosen?.id,
            onTap: () => setState(() {
              _newPet = false;
              _petId = pet.id.value;
            }),
          ),
          const SizedBox(height: KivetoSpace.m),
        ],
        if (newPet)
          _NewPetForm(
            name: _name,
            species: _newSpecies,
            onNameChanged: () => setState(() {}),
            onSpecies: (species) => setState(() => _newSpecies = species),
          )
        else
          KivetoAddCard(
            label: l10n.bookingNewPet,
            onTap: () => setState(() => _newPet = true),
          ),
      ],
    ),
  );
}

/// The clinic of the booking: a summary chip, opening the switcher when the
/// account has several confirmed clinics.
class _ClinicChip extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final clinic = switch (ref.watch(activeClinicProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (clinic == null) return const SizedBox(height: 36);
    final several = switch (ref.watch(meProvider)) {
      AsyncData(:final value) => value.confirmedClinics.length > 1,
      _ => false,
    };
    final chip = KivetoSummaryChip(
      label: clinic.name,
      trailingGlyph: several ? LucideGlyph.chevronDown : null,
      onPressed: several
          ? () => unawaited(showClinicSwitcherSheet(context))
          : null,
    );
    return several
        ? Semantics(
            label: l10n.bookingClinicSwitcherLabel(clinic.name),
            button: true,
            excludeSemantics: true,
            child: chip,
          )
        : chip;
  }
}

/// « Un autre animal », open: a selected card with the name field and the
/// species chips.
class _NewPetForm extends StatelessWidget {
  const new({
    required this.name,
    required this.species,
    required this.onNameChanged,
    required this.onSpecies,
  });

  final TextEditingController name;
  final Species? species;
  final VoidCallback onNameChanged;
  final ValueChanged<Species> onSpecies;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      selected: true,
      inMutuallyExclusiveGroup: true,
      container: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(15, 11, 15, 15),
        decoration: BoxDecoration(
          color: KivetoColors.brandSubtle,
          border: Border.all(color: KivetoColors.brand, width: 2),
          borderRadius: BorderRadius.circular(KivetoRadius.xl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 40),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.bookingNewPet,
                      style: KivetoText.itemValue.copyWith(
                        color: KivetoColors.brand,
                      ),
                    ),
                  ),
                  const RadioDot(selected: true),
                ],
              ),
            ),
            const SizedBox(height: KivetoSpace.sm),
            KivetoTextField(
              label: l10n.bookingNewPetName,
              controller: name,
              errorText: name.text.trim().length > _maxNameLength
                  ? l10n.bookingNewPetNameTooLong(_maxNameLength)
                  : null,
              textInputAction: TextInputAction.done,
              onChanged: (_) => onNameChanged(),
            ),
            const SizedBox(height: KivetoSpace.ml),
            Semantics(
              container: true,
              label: l10n.bookingNewPetSpecies,
              child: Wrap(
                spacing: KivetoSpace.sm,
                runSpacing: KivetoSpace.sm,
                children: [
                  for (final candidate in _species)
                    KivetoChoiceChip(
                      label: speciesLabel(l10n, candidate) ?? '',
                      selected: candidate == species,
                      onSelected: () => onSpecies(candidate),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) =>
      const SizedBox(height: 160, child: LoadingView());
}
