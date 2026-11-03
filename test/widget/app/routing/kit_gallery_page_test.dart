// The debug kit gallery: every section builds, the network probe and the
// fake session work.

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/app/routing/app_router.dart';
import 'package:kiveto_mobile/app/routing/app_routes.dart';
import 'package:kiveto_mobile/app/routing/kit_gallery_page.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/fakes.dart';
import '../../../support/portal_api/fake_portal_backend.dart';

void main() {
  testWidgets('every section builds, top to bottom', (tester) async {
    await pumpKivetoApp(tester, initialLocation: AppRoutes.kitGallery);
    expect(find.byType(KitGalleryPage), findsOneWidget);

    // Scroll to the end, collecting every text built on the way.
    final seen = <String>{};
    final list = find.byType(Scrollable).first;
    for (var i = 0; i < 40; i++) {
      seen.addAll(
        tester
            .widgetList<Text>(find.byType(Text))
            .map((text) => text.data ?? ''),
      );
      await tester.drag(list, const Offset(0, -400));
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(
      seen,
      containsAll([
        'Réseau',
        'Session factice',
        'Boutons',
        'Surfaces et lignes',
        'Pastilles, puces, avatars',
        'Navigation et structure',
        'Formulaires',
        'Retours',
        'Formats',
        'Icônes',
        'Typographie',
        'Couleurs',
        'Mar. 4 nov. · 10:30',
        '68,00 €',
        'wifiOff',
        'shadow',
      ]),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the network probe shows the terms version', (tester) async {
    final backend = FakePortalBackend()
      ..on(
        'GET',
        '/api/portal/v1/legal/terms/current',
        PortalReply.json('{"version": "2026-10", "url": "https://x/cgu"}'),
      );
    await pumpKivetoApp(
      tester,
      initialLocation: AppRoutes.kitGallery,
      overrides: [
        portalServerProvider.overrideWithValue(portalServer(backend)),
      ],
    );

    await tester.tap(find.text('GET /legal/terms/current'));
    await tester.pumpAndSettle();
    expect(
      find.text('GET /legal/terms/current → 200 · 2026-10'),
      findsOneWidget,
    );

    await tester.tap(find.text('GET /legal/terms/current'));
    await tester.pumpAndSettle();
    expect(backend.requests, hasLength(2));
  });

  testWidgets('the fake session opens the shell and closes it', (tester) async {
    final session = await memorySession();
    final container = await pumpKivetoApp(
      tester,
      session: session,
      initialLocation: AppRoutes.kitGallery,
    );

    await tester.tap(find.text('Ouvrir une session factice'));
    await tester.pumpAndSettle();
    expect(session.status, SessionStatus.signedIn);

    container.read(routerProvider).go(AppRoutes.home);
    await tester.pumpAndSettle();
    expect(find.text('Rendez-vous'), findsOneWidget);
  });
}
