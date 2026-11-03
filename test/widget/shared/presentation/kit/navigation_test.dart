import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../support/fakes.dart';

List<KivetoNavItem> _items(int documents) => [
  const KivetoNavItem(label: 'Accueil', glyph: LucideGlyph.house),
  const KivetoNavItem(label: 'Animaux', glyph: LucideGlyph.pawPrint),
  const KivetoNavItem(label: 'Rendez-vous', glyph: LucideGlyph.calendar),
  KivetoNavItem(
    label: 'Documents',
    glyph: LucideGlyph.fileText,
    badgeCount: documents,
    semanticLabel: documents > 0 ? 'Documents, $documents nouveaux' : null,
  ),
  const KivetoNavItem(label: 'Compte', avatar: true),
];

void main() {
  group('KivetoBottomNav', () {
    for (final (count, badge) in [
      (0, null),
      (2, '2'),
      (99, '99'),
      (120, '99+'),
    ]) {
      testWidgets('badge $count: ${badge ?? 'hidden'}', (tester) async {
        await pumpKit(
          tester,
          KivetoBottomNav(items: _items(count), currentIndex: 0, onTap: (_) {}),
        );

        expect(
          find.text(badge ?? '0'),
          badge == null ? findsNothing : findsOneWidget,
        );
      });
    }

    testWidgets('64 high, the active tab, the avatar tab, taps, semantics', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final taps = <int>[];
      await pumpKit(
        tester,
        KivetoBottomNav(
          items: [
            ..._items(2).take(4),
            const KivetoNavItem(label: 'Compte', avatar: true, initials: 'SB'),
            const KivetoNavItem(label: 'Vide'),
          ],
          currentIndex: 4,
          onTap: taps.add,
        ),
      );

      expect(
        tester
            .getSize(
              find
                  .descendant(
                    of: find.byType(KivetoBottomNav),
                    matching: find.byType(Container),
                  )
                  .first,
            )
            .height,
        64,
      );
      final avatar = tester.widget<InitialsAvatar>(find.byType(InitialsAvatar));
      expect(avatar.tone, AvatarTone.brand);
      expect(find.text('SB'), findsOneWidget);
      expect(find.bySemanticsLabel('Documents, 2 nouveaux'), findsOneWidget);

      await tester.tap(find.text('Animaux'));
      await tester.tap(find.bySemanticsLabel('Documents, 2 nouveaux'));
      expect(taps, [1, 3]);

      // The tabs keep their tap action for screen readers and switch access.
      final animaux = tester.getSemantics(find.bySemanticsLabel('Animaux'));
      expect(animaux.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      animaux.owner!.performAction(animaux.id, SemanticsAction.tap);
      expect(taps, [1, 3, 1]);
      handle.dispose();
    });

    for (final (inset, bottom) in [(0.0, 18.0), (34.0, 42.0)]) {
      testWidgets('bottom padding $bottom with a system inset of $inset', (
        tester,
      ) async {
        await pumpKit(
          tester,
          MediaQuery(
            data: MediaQueryData(viewPadding: EdgeInsets.only(bottom: inset)),
            child: KivetoBottomNav(
              items: _items(0),
              currentIndex: 0,
              onTap: (_) {},
            ),
          ),
        );

        final padding = tester.widget<Padding>(
          find
              .descendant(
                of: find.byType(KivetoBottomNav),
                matching: find.byType(Padding),
              )
              .first,
        );
        expect(padding.padding, EdgeInsets.fromLTRB(12, 8, 12, bottom));
      });
    }
  });

  testWidgets('KivetoSegmentedControl, full width and compact', (tester) async {
    var selected = 0;
    var pet = 'moka';
    await pumpKit(
      tester,
      StatefulBuilder(
        builder: (context, setState) => Column(
          children: [
            KivetoSegmentedControl<int>(
              segments: const [
                KivetoSegment(0, 'À venir (2)'),
                KivetoSegment(1, 'Passés'),
              ],
              selected: selected,
              onChanged: (value) => setState(() => selected = value),
            ),
            KivetoSegmentedControl<String>(
              compact: true,
              segments: const [
                KivetoSegment('moka', 'Moka'),
                KivetoSegment('pistache', 'Pistache'),
              ],
              selected: pet,
              onChanged: (value) => setState(() => pet = value),
            ),
            const KivetoSegmentedControl<int>(
              segments: [KivetoSegment(0, 'Seul')],
              selected: 0,
              onChanged: null,
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Passés'));
    await tester.tap(find.text('Pistache'));
    await tester.tap(find.text('Seul'));
    await tester.pumpAndSettle();

    expect((selected, pet), (1, 'pistache'));
    final passed = tester.getSize(find.text('Passés'));
    final upcoming = tester.getSize(find.text('À venir (2)'));
    expect(passed.height, upcoming.height);
  });

  testWidgets('the wizard header, the sticky bars, the bottom area', (
    tester,
  ) async {
    final events = <String>[];
    await pumpKit(
      tester,
      Column(
        children: [
          WizardHeader(
            step: 2,
            stepLabel: 'Étape 2 sur 4',
            title: 'Quel est le motif ?',
            onBack: () => events.add('back'),
            onClose: () => events.add('close'),
          ),
          StickySummaryBar(
            label: 'Animal',
            value: 'Moka',
            action: KivetoButton.primary(
              label: 'Continuer',
              size: KivetoButtonSize.medium,
              onPressed: () => events.add('continue'),
            ),
          ),
          StickyCtaBar(
            child: KivetoButton.primary(label: 'Confirmer', onPressed: () {}),
          ),
          BottomCtaArea(
            children: [
              KivetoButton.primary(label: 'Valider', onPressed: () {}),
              KivetoLinkButton(label: 'Plus tard', onPressed: () {}),
            ],
          ),
          const BottomCtaArea(success: true, children: [SizedBox()]),
        ],
      ),
    );

    await tester.tap(find.byType(KivetoIconButton).first);
    await tester.tap(find.byType(KivetoIconButton).last);
    await tester.tap(find.text('Continuer'));
    expect(events, ['back', 'close', 'continue']);
    final bars = tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(WizardHeader),
            matching: find.byType(Container),
          ),
        )
        .map((bar) => (bar.decoration! as BoxDecoration).color)
        .toList();
    expect(bars, [
      KivetoColors.brand,
      KivetoColors.brand,
      KivetoColors.border,
      KivetoColors.border,
    ]);
  });

  testWidgets('showKivetoSheet: scrim, handle, title, actions', (tester) async {
    await pumpKit(
      tester,
      Builder(
        builder: (context) => KivetoButton.outline(
          label: 'Ouvrir',
          onPressed: () => showKivetoSheet<void>(
            context: context,
            builder: (context) => KivetoSheet(
              title: 'Annuler ce rendez-vous ?',
              subtitle: 'Mar. 4 nov. · 10:30',
              children: [
                KivetoButton.danger(
                  label: 'Annuler le rendez-vous',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();
    expect(find.text('Annuler ce rendez-vous ?'), findsOneWidget);
    expect(
      tester.widget<ModalBarrier>(find.byType(ModalBarrier).last).color,
      KivetoColors.scrim,
    );

    await tester.tap(find.text('Annuler le rendez-vous'));
    await tester.pumpAndSettle();
    expect(find.text('Annuler ce rendez-vous ?'), findsNothing);

    await pumpKit(
      tester,
      const KivetoSheet(title: 'Sans sous-titre', children: [SizedBox()]),
    );
    expect(find.text('Sans sous-titre'), findsOneWidget);
  });

  testWidgets('showKivetoSheet from a tab: the scrim covers the bottom nav '
      'too (root navigator)', (tester) async {
    await pumpKivetoApp(tester, session: await memorySession(pair('A')));

    unawaited(
      showKivetoSheet<void>(
        context: tester.element(find.byType(KivetoPageHeader)),
        builder: (context) =>
            const KivetoSheet(title: 'Feuille', children: [SizedBox()]),
      ),
    );
    await tester.pumpAndSettle();

    final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    final barrier = tester.getRect(find.byType(ModalBarrier).last);
    expect(barrier.bottom, screen.height);
    expect(barrier.height, screen.height);
  });

  testWidgets('KivetoSheet: above the keyboard, tall content scrolls', (
    tester,
  ) async {
    await pumpKit(
      tester,
      SizedBox(
        height: 500,
        child: MediaQuery(
          data: const MediaQueryData(viewInsets: EdgeInsets.only(bottom: 400)),
          child: KivetoSheet(
            title: 'Annuler ce rendez-vous ?',
            subtitle: 'Mar. 4 nov. · 10:30',
            children: [
              for (var i = 0; i < 6; i++)
                KivetoButton.outline(label: 'Action $i', onPressed: () {}),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsWidgets);
  });

  testWidgets('the badge grows with large text', (tester) async {
    await pumpKit(
      tester,
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: KivetoBottomNav(
          items: _items(120),
          currentIndex: 0,
          onTap: (_) {},
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final text = tester.getSize(find.text('99+'));
    final badge = tester.getSize(
      find
          .ancestor(of: find.text('99+'), matching: find.byType(Container))
          .first,
    );
    expect(badge.height, greaterThanOrEqualTo(text.height + 4));
    expect(badge.width, greaterThanOrEqualTo(text.width + 8));
  });
}
