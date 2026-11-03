import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../support/fakes.dart';

Color? _fill(WidgetTester tester, String label) {
  final material = tester.widget<Material>(
    find.ancestor(of: find.text(label), matching: find.byType(Material)).first,
  );
  return material.color;
}

void main() {
  testWidgets('primary: tappable, its size, brand fill', (tester) async {
    var taps = 0;
    await pumpKit(
      tester,
      Column(
        children: [
          KivetoButton.primary(
            label: 'Recevoir mon code',
            onPressed: () => taps++,
          ),
          KivetoButton.primary(
            label: 'Continuer',
            size: KivetoButtonSize.medium,
            onPressed: () {},
          ),
          KivetoButton.primary(
            label: 'Rattacher',
            size: KivetoButtonSize.small,
            onPressed: () {},
          ),
        ],
      ),
    );

    await tester.tap(find.text('Recevoir mon code'));
    expect(taps, 1);
    expect(_fill(tester, 'Recevoir mon code'), KivetoColors.brand);
    final large = tester.getSize(
      find.ancestor(
        of: find.text('Recevoir mon code'),
        matching: find.byType(TextButton),
      ),
    );
    expect(large.height, 52);
    expect(large.width, greaterThan(300));
    final small = tester.getRect(
      find
          .ancestor(of: find.text('Rattacher'), matching: find.byType(Material))
          .first,
    );
    expect(small.height, 40);
    expect(small.width, lessThan(200));
  });

  testWidgets('disabled: the C-1d colours, not tappable', (tester) async {
    await pumpKit(
      tester,
      KivetoButton.primary(label: 'Envoyer la demande', onPressed: null),
    );

    expect(_fill(tester, 'Envoyer la demande'), KivetoColors.brandDisabled);
    expect(
      tester.widget<TextButton>(find.byType(TextButton)).onPressed,
      isNull,
    );
  });

  testWidgets('loading: a spinner, the enabled colours, not tappable', (
    tester,
  ) async {
    var taps = 0;
    await pumpKit(
      tester,
      KivetoButton.primary(
        label: 'Valider',
        loading: true,
        onPressed: () => taps++,
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(_fill(tester, 'Valider'), KivetoColors.brand);
    await tester.tap(find.byType(TextButton));
    expect(taps, 0);
  });

  testWidgets('every family builds, enabled and disabled', (tester) async {
    await pumpKit(
      tester,
      Column(
        children: [
          for (final enabled in [true, false]) ...[
            KivetoButton.dark(
              label: 'dark',
              icon: LucideGlyph.plus,
              onPressed: enabled ? () {} : null,
            ),
            KivetoButton.danger(
              label: 'dangerL',
              onPressed: enabled ? () {} : null,
            ),
            KivetoButton.danger(
              label: 'dangerS',
              size: KivetoButtonSize.small,
              onPressed: enabled ? () {} : null,
            ),
            for (final size in KivetoButtonSize.values)
              KivetoButton.outline(
                label: 'outline $size',
                size: size,
                icon: LucideGlyph.calendar,
                onPressed: enabled ? () {} : null,
              ),
            KivetoButton.outlineBrand(
              label: 'brand',
              onPressed: enabled ? () {} : null,
            ),
            KivetoButton.outlineDanger(
              label: 'outlineDanger',
              onPressed: enabled ? () {} : null,
            ),
            KivetoButton.tonal(
              label: 'tonalS',
              icon: LucideGlyph.download,
              onPressed: enabled ? () {} : null,
            ),
            KivetoButton.tonal(
              label: 'tonalM',
              size: KivetoButtonSize.medium,
              onPressed: enabled ? () {} : null,
            ),
            KivetoButton.onBrand(
              label: 'onBrand',
              onPressed: enabled ? () {} : null,
            ),
            KivetoButton.onBrandOutline(
              label: 'onBrandOutline',
              onPressed: enabled ? () {} : null,
            ),
          ],
        ],
      ),
    );

    expect(find.byType(KivetoButton), findsNWidgets(24));
    expect(
      _fill(tester, 'dangerL'),
      isIn([KivetoColors.danger, KivetoColors.dangerDisabled]),
    );
  });

  testWidgets('pressed: brand fills darken', (tester) async {
    await pumpKit(tester, KivetoButton.primary(label: 'Go', onPressed: () {}));

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Go')),
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(_fill(tester, 'Go'), KivetoColors.brandPressed);
    await gesture.up();
  });

  testWidgets('text buttons and links', (tester) async {
    var taps = 0;
    var links = <String>[];
    await pumpKit(
      tester,
      Column(
        children: [
          const KivetoTextButton(
            label: 'Renvoyer le SMS dans 0:24',
            onPressed: null,
          ),
          KivetoTextButton(
            label: 'Recevoir le code par email',
            onPressed: () => taps++,
          ),
          KivetoLinkButton(label: 'Plus tard', onPressed: () => taps++),
          const KivetoLinkButton(label: 'Désactivé', onPressed: null),
          KivetoInlineLinks([
            const InlinePart.text("J'accepte les "),
            InlinePart.link('conditions', onTap: () => links.add('cgu')),
            const InlinePart.text('.'),
          ]),
          KivetoInlineLinks(
            [
              InlinePart.link(
                'Tout voir',
                onTap: () => links.add('all'),
                underline: false,
                strong: true,
              ),
            ],
            style: const TextStyle(fontSize: 13),
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );

    await tester.tap(find.text('Recevoir le code par email'));
    await tester.tap(find.text('Plus tard'));
    expect(taps, 2);
    await tester.tapOnText(find.textRange.ofSubstring('conditions'));
    await tester.tapOnText(find.textRange.ofSubstring('Tout voir'));
    expect(links, ['cgu', 'all']);

    // Rebuilt: the recognizers are replaced, not leaked.
    links = [];
    await pumpKit(tester, const SizedBox());
  });

  testWidgets('icon buttons: 44 × 44, labelled', (tester) async {
    final handle = tester.ensureSemantics();
    final pressed = <String>[];
    await pumpKit(
      tester,
      Wrap(
        children: [
          KivetoIconButton.back(onPressed: () => pressed.add('back')),
          KivetoIconButton.close(onPressed: () => pressed.add('close')),
          KivetoIconButton.roundOutline(
            glyph: LucideGlyph.bell,
            semanticLabel: 'Notifications',
            onPressed: () => pressed.add('bell'),
          ),
          KivetoIconButton.fab(
            glyph: LucideGlyph.plus,
            semanticLabel: 'Nouveau rendez-vous',
            onPressed: () => pressed.add('fab'),
          ),
          KivetoIconButton.squareMuted(
            glyph: LucideGlyph.download,
            semanticLabel: 'Télécharger',
            onPressed: () => pressed.add('download'),
          ),
          KivetoIconButton.back(
            onPressed: () {},
            semanticLabel: 'Fermer le flux',
            offset: 0,
          ),
        ],
      ),
    );

    for (final label in [
      'Retour',
      'Fermer',
      'Notifications',
      'Nouveau rendez-vous',
      'Télécharger',
    ]) {
      await tester.tap(find.bySemanticsLabel(label));
    }
    expect(pressed, ['back', 'close', 'bell', 'fab', 'download']);
    expect(find.bySemanticsLabel('Fermer le flux'), findsOneWidget);
    // The tap action survives excludeSemantics: activable by a screen
    // reader; none when disabled.
    final notifications = tester.getSemantics(
      find.bySemanticsLabel('Notifications'),
    );
    expect(
      notifications.getSemanticsData().hasAction(SemanticsAction.tap),
      isTrue,
    );
    notifications.owner!.performAction(notifications.id, SemanticsAction.tap);
    expect(pressed.last, 'bell');
    expect(pressed, hasLength(6));
    expect(
      tester.getSize(find.byType(KivetoIconButton).first),
      const Size.square(44),
    );
    handle.dispose();
  });

  testWidgets('a rebuild between pointer down and up keeps the link tap', (
    tester,
  ) async {
    var taps = 0;
    late StateSetter rebuild;
    var tick = 0;
    await pumpKit(
      tester,
      StatefulBuilder(
        builder: (context, setState) {
          rebuild = setState;
          return KivetoInlineLinks([
            // A new list and callback at every build, as a countdown parent.
            InlinePart.link('Renvoyer ($tick)', onTap: () => taps++),
          ]);
        },
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(KivetoInlineLinks)),
    );
    rebuild(() => tick++);
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(taps, 1);
    expect(find.textContaining('(1)', findRichText: true), findsOneWidget);
  });
}
