import 'package:kiveto_mobile/features/home/domain/home_overview.dart';
import 'package:kiveto_mobile/features/patient/patient.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// « Mes animaux » of the home: one card full width, two or more two per
/// row (C-29), in the clinic's order (the avatar colour follows it).
class PetCards extends StatelessWidget {
  const new({
    required this.pets,
    required this.today,
    required this.onOpen,
    super.key,
  });

  final List<HomePet> pets;
  final LocalDate today;
  final void Function(HomePet pet) onOpen;

  @override
  Widget build(BuildContext context) {
    Widget card(int index) => PetCard(
      pet: pets[index],
      index: index,
      today: today,
      onTap: () => onOpen(pets[index]),
    );
    if (pets.length == 1) return card(0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var row = 0; row < pets.length; row += 2) ...[
          if (row > 0) const SizedBox(height: KivetoSpace.m),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: card(row)),
                const SizedBox(width: KivetoSpace.m),
                Expanded(
                  child: row + 1 < pets.length
                      ? card(row + 1)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// C-29, a pet of the home: its avatar (44), its name, « Espèce · âge ».
class PetCard extends StatelessWidget {
  const new({
    required this.pet,
    required this.index,
    required this.today,
    required this.onTap,
    super.key,
  });

  final HomePet pet;

  /// Its position in the clinic's list: its avatar colour.
  final int index;
  final LocalDate today;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final meta = petCardMeta(
      AppLocalizations.of(context),
      pet.species,
      pet.birthDate,
      today,
    );
    return Semantics(
      button: true,
      child: Material(
        color: KivetoColors.surface,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: KivetoColors.border),
          borderRadius: BorderRadius.circular(KivetoRadius.l),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashFactory: NoSplash.splashFactory,
          overlayColor: const WidgetStatePropertyAll(KivetoColors.inkPressed),
          child: Padding(
            padding: const EdgeInsets.all(KivetoSpace.ml),
            child: Row(
              children: [
                InitialsAvatar(
                  pet.initial,
                  tone: AvatarTone.forPetIndex(index),
                ),
                const SizedBox(width: KivetoSpace.ml),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pet.name, style: KivetoText.itemTitle),
                      if (meta.isNotEmpty) ...[
                        const SizedBox(height: KivetoSpace.xxs),
                        Text(meta, style: KivetoText.caption),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
