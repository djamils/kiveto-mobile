import 'package:kiveto_mobile/features/patient/patient.dart' show speciesLabel;
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/species.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// The longest name the server takes for a new pet.
const maxNewPetNameLength = 80;

/// The species a new pet may have.
const List<Species> newPetSpecies = [
  Species.dog,
  Species.cat,
  Species.nac,
  Species.other,
];

/// The new pet as typed, when the form may be sent: a name (trimmed, at
/// most [maxNewPetNameLength] characters) and a species; null before.
(String name, Species species)? newPetOf(String typed, Species? species) {
  final name = typed.trim();
  if (name.isEmpty || name.length > maxNewPetNameLength || species == null) {
    return null;
  }
  return (name, species);
}

/// A new pet described with a booking (12's « Un autre animal », the
/// new-client booking's « Votre animal »): its name (at most
/// [maxNewPetNameLength] characters, the only local guard) and its species
/// chips. [framed]: inside the selected card of 12, titled « Un autre
/// animal »; plain fields otherwise. [nameError] is the server's word on
/// the name (`newPet.name`), shown under the field.
class NewPetForm extends StatelessWidget {
  const new({
    required this.name,
    required this.species,
    required this.onNameChanged,
    required this.onSpecies,
    super.key,
    this.framed = true,
    this.nameError,
  });

  final TextEditingController name;
  final Species? species;
  final VoidCallback onNameChanged;
  final ValueChanged<Species> onSpecies;
  final bool framed;
  final String? nameError;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fields = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KivetoTextField(
          label: l10n.bookingNewPetName,
          controller: name,
          errorText: name.text.trim().length > maxNewPetNameLength
              ? l10n.bookingNewPetNameTooLong(maxNewPetNameLength)
              : nameError,
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
              for (final candidate in newPetSpecies)
                KivetoChoiceChip(
                  label: speciesLabel(l10n, candidate) ?? '',
                  selected: candidate == species,
                  onSelected: () => onSpecies(candidate),
                ),
            ],
          ),
        ),
      ],
    );
    if (!framed) return fields;
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
            fields,
          ],
        ),
      ),
    );
  }
}
