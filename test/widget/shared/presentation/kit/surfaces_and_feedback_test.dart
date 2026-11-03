import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../support/fakes.dart';

void main() {
  testWidgets('cards and rows', (tester) async {
    final taps = <String>[];
    var switchOn = false;
    var checked = false;
    await pumpKit(
      tester,
      StatefulBuilder(
        builder: (context, setState) => Column(
          children: [
            KivetoCard.list(
              children: [
                KivetoListRow(
                  title: 'Pistache — Rappel',
                  meta: 'Avant le 18 nov.',
                  trailing: const StatusPill(
                    'Dans 3 sem.',
                    tone: StatusTone.warning,
                  ),
                  onTap: () => taps.add('row'),
                ),
                KivetoListRow.navigation(
                  title: 'Vaccination',
                  meta: '30 min',
                  onTap: () => taps.add('navigation'),
                ),
                const KivetoListRow.tile(
                  leading: KivetoLeadingTile(
                    colors: KivetoColorSets.green,
                    text: '€',
                  ),
                  title: 'Facture',
                ),
                const KivetoListRow.tile(
                  leading: KivetoLeadingTile(
                    colors: KivetoColorSets.indigo,
                    glyph: LucideGlyph.fileText,
                    size: 40,
                  ),
                  title: 'Compte-rendu',
                ),
              ],
            ),
            KivetoActionRow(
              glyph: LucideGlyph.trash,
              label: 'Supprimer',
              danger: true,
              onTap: () => taps.add('action'),
            ),
            KivetoKeyValueRow(
              label: 'Clinique',
              value: 'Clinique des Lices',
              secondary: '12 rue des Lices',
              actionLabel: 'Modifier',
              onAction: () => taps.add('edit'),
            ),
            const KivetoKeyValueRow(
              label: 'Animal',
              value: 'Moka',
              actionLabel: 'Voir',
            ),
            KivetoSwitchRow(
              title: 'Rappels',
              description: 'Un rappel avant échéance.',
              value: switchOn,
              onChanged: (value) => setState(() => switchOn = value),
            ),
            KivetoCheckboxRow(
              title: 'Apoquel 16 mg',
              meta: '1 comprimé par jour',
              value: checked,
              onChanged: (value) => setState(() => checked = value),
            ),
            const KivetoCheckboxRow(
              title: 'Figé',
              value: false,
              onChanged: null,
            ),
            const KivetoCard(child: Text('Carte simple')),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Pistache — Rappel'));
    await tester.tap(find.text('Vaccination'));
    await tester.tap(find.text('Supprimer'));
    await tester.tapOnText(find.textRange.ofSubstring('Modifier'));
    await tester.tapOnText(find.textRange.ofSubstring('Voir'));
    await tester.tap(find.byType(KivetoSwitch));
    await tester.tap(find.text('Apoquel 16 mg'));
    await tester.pumpAndSettle();

    expect(taps, ['row', 'navigation', 'action', 'edit']);
    expect((switchOn, checked), (true, true));
    expect(
      tester.getSize(find.byType(KivetoActionRow)).height,
      greaterThanOrEqualTo(52),
    );
  });

  testWidgets('headers, lockup, pills, tags, chips, avatars, dots', (
    tester,
  ) async {
    final taps = <String>[];
    await pumpKit(
      tester,
      Column(
        children: [
          KivetoSectionHeader(
            'Derniers documents',
            actionLabel: 'Tout voir',
            onAction: () => taps.add('all'),
          ),
          const KivetoSectionHeader(
            'Mes animaux',
            trailingCaption: '2 animaux',
          ),
          const KivetoSectionHeader(
            'Consentements',
            description: 'Ce que la clinique envoie.',
          ),
          const KivetoSectionHeader('Sans action', actionLabel: 'Lien'),
          KivetoSectionHeader(
            'Vaccins',
            trailing: KivetoButton.tonal(label: 'Carnet PDF', onPressed: () {}),
          ),
          const KivetoPageHeader('Rendez-vous', subtitle: 'Clinique des Lices'),
          KivetoDetailHeader(
            title: 'Clinique des Lices',
            subtitle: 'Angers',
            extra: 'Ouvert',
            extraIsPositive: true,
            onBack: () => taps.add('back'),
          ),
          const KivetoDetailHeader(title: 'Sans retour', extra: 'Fermé'),
          const KivetoBrandLockup(),
          Wrap(
            children: [
              for (final tone in StatusTone.values) StatusPill('x', tone: tone),
              const StatusPill(
                'compact',
                tone: StatusTone.neutral,
                compact: true,
              ),
            ],
          ),
          const KivetoTag.brand('Invitation'),
          const KivetoTag.success('vérifié'),
          KivetoFilterChip(
            label: 'Tous',
            selected: true,
            onSelected: () => taps.add('filter'),
          ),
          KivetoFilterChip(
            label: 'Factures',
            selected: false,
            onSelected: () {},
          ),
          KivetoChoiceChip(
            label: 'Boiterie',
            selected: true,
            onSelected: () => taps.add('choice'),
          ),
          KivetoChoiceChip(label: 'Toux', selected: false, onSelected: () {}),
          KivetoSummaryChip(
            label: 'Moka',
            onPressed: () => taps.add('summary'),
          ),
          KivetoSummaryChip.action(
            label: 'Autour de moi',
            leadingGlyph: LucideGlyph.mapPin,
            onPressed: () {},
          ),
          KivetoDocumentChip(
            label: 'Ordonnance',
            onPressed: () => taps.add('document'),
          ),
          Wrap(
            children: [
              for (final tone in AvatarTone.values)
                InitialsAvatar('M', tone: tone),
              for (final size in [24.0, 44.0, 48.0, 64.0])
                InitialsAvatar('SB', size: size),
              const InitialsAvatar('M', size: 48, pet: true),
              const StatusDot(),
              const StatusDot(active: false),
            ],
          ),
        ],
      ),
    );

    await tester.tapOnText(find.textRange.ofSubstring('Tout voir'));
    await tester.tapOnText(find.textRange.ofSubstring('Lien'));
    await tester.tap(find.byType(KivetoIconButton));
    for (final label in ['Tous', 'Boiterie', 'Moka', 'Ordonnance']) {
      await tester.ensureVisible(find.text(label));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
    }
    expect(taps, ['all', 'back', 'filter', 'choice', 'summary', 'document']);
    expect(
      [for (var i = 0; i < 8; i++) AvatarTone.forPetIndex(i)],
      [
        AvatarTone.indigo,
        AvatarTone.orange,
        AvatarTone.green,
        AvatarTone.neutral,
        AvatarTone.indigo,
        AvatarTone.orange,
        AvatarTone.green,
        AvatarTone.neutral,
      ],
    );
    expect(find.text('K'), findsOneWidget);
  });

  testWidgets('callouts, footnotes, reassurance, success views, skeleton', (
    tester,
  ) async {
    final taps = <String>[];
    await pumpKit(
      tester,
      Column(
        children: [
          KivetoCallout.info(
            title: 'Une invitation ?',
            body: 'Ouvrez le lien.',
            actionLabel: "J'ai un lien",
            onAction: () => taps.add('info'),
          ),
          const KivetoCallout.info(
            title: 'Sans lien',
            body: 'Corps.',
            actionLabel: 'Lien inerte',
          ),
          const KivetoCallout.info(title: 'Sans action', body: 'Corps.'),
          KivetoCallout.brand(
            title: 'Un dossier ?',
            body: 'La clinique a un dossier.',
            actionLabel: 'Rattacher',
            onAction: () => taps.add('brand'),
          ),
          const KivetoCallout.warning(body: 'Attention.'),
          KivetoCallout.danger(
            body: 'Urgence ?',
            actionLabel: 'Appeler',
            onAction: () => taps.add('call'),
          ),
          const KivetoCallout.danger(body: 'Sans action.'),
          const KivetoFootnote('Note.'),
          const KivetoFootnote('Petite note.', small: true, centered: true),
          const ReassuranceList(['Un', 'Deux']),
          SuccessView(
            title: 'Rendez-vous confirmé',
            message: 'Mar. 4 nov.',
            note: 'Un SMS.',
            action: KivetoButton.outline(label: 'Calendrier', onPressed: () {}),
          ),
          const SuccessView(
            title: 'Demande envoyée',
            message: 'La clinique répondra.',
          ),
          SheetSuccessView(
            title: 'Rendez-vous annulé',
            message: 'La clinique est prévenue.',
            action: KivetoButton.primary(label: 'Fermer', onPressed: () {}),
          ),
          const KivetoSkeleton(),
        ],
      ),
    );

    await tester.tapOnText(find.textRange.ofSubstring("J'ai un lien"));
    await tester.tapOnText(find.textRange.ofSubstring('Lien inerte'));
    for (final label in ['Rattacher', 'Appeler']) {
      await tester.ensureVisible(find.text(label));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
    }
    expect(taps, ['info', 'brand', 'call']);
    expect(find.text('Rendez-vous confirmé'), findsOneWidget);
  });
}
