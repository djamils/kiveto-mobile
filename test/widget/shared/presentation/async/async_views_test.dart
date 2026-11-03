import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/l10n/app_localizations_fr.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/icons/kiveto_icon.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../support/fakes.dart';

void main() {
  final l10n = AppLocalizationsFr();

  test('failureMessage: a French title and body per failure', () {
    final cases = <Object, (String, String)>{
      const NetworkFailure(): (
        'Pas de connexion',
        'Vérifiez votre connexion Internet, puis réessayez.',
      ),
      const UnauthorizedFailure(): (
        'Session expirée',
        'Reconnectez-vous pour continuer.',
      ),
      const ValidationFailure(): (
        'Informations à corriger',
        'Certaines informations ne sont pas valides. Corrigez-les, puis '
            'réessayez.',
      ),
      const RateLimitedFailure(retryAfter: Duration(seconds: 120)): (
        'Trop de tentatives',
        'Réessayez dans 2 min.',
      ),
      const RateLimitedFailure(retryAfter: Duration(seconds: 61)): (
        'Trop de tentatives',
        'Réessayez dans 2 min.',
      ),
      const RateLimitedFailure(retryAfter: Duration.zero): (
        'Trop de tentatives',
        'Réessayez dans 1 min.',
      ),
      const RateLimitedFailure(): (
        'Trop de tentatives',
        'Réessayez dans quelques minutes.',
      ),
      const NotFoundFailure(): (
        'Introuvable',
        "Cet élément n'existe pas ou n'est plus disponible.",
      ),
      const ConflictFailure(): (
        'Action déjà traitée',
        'La situation a changé entre-temps. Actualisez, puis réessayez.',
      ),
      const ServerFailure(): (
        'Service indisponible',
        'Le service rencontre un problème. Réessayez dans un instant.',
      ),
      const BusinessFailure(code: 'otp_invalid', statusCode: 422): (
        'Action impossible',
        "Cette action n'a pas pu aboutir.",
      ),
      StateError('boom'): (
        'Une erreur est survenue',
        'Réessayez dans un instant.',
      ),
    };
    for (final MapEntry(key: error, value: expected) in cases.entries) {
      expect(failureMessage(l10n, error), expected, reason: '$error');
    }
  });

  for (final (error, glyph) in [
    (const NetworkFailure(), LucideGlyph.wifiOff),
    (const RateLimitedFailure(), LucideGlyph.clock),
    (const ServerFailure(), LucideGlyph.circleAlert),
    (StateError('x'), LucideGlyph.circleAlert),
  ]) {
    testWidgets('ErrorView of ${error.runtimeType}: its glyph, title, body', (
      tester,
    ) async {
      await pumpKit(tester, ErrorView(error: error));

      final (title, body) = failureMessage(l10n, error);
      expect(find.text(title), findsOneWidget);
      expect(find.text(body), findsOneWidget);
      expect(tester.widget<KivetoIcon>(find.byType(KivetoIcon)).glyph, glyph);
      expect(find.text('Réessayer'), findsNothing);
    });
  }

  testWidgets('ErrorView: retry calls onRetry; message replaces the body', (
    tester,
  ) async {
    var retries = 0;
    await pumpKit(
      tester,
      ErrorView(
        error: const BusinessFailure(code: 'slot_taken', statusCode: 422),
        message: 'Ce créneau vient d’être pris.',
        onRetry: () => retries++,
      ),
    );

    await tester.tap(find.text('Réessayer'));
    expect(retries, 1);
    expect(find.text('Ce créneau vient d’être pris.'), findsOneWidget);
  });

  testWidgets('AsyncValueView: a retry after an error shows the loading '
      'view, not the error and its retry button', (tester) async {
    var calls = 0;
    final pending = Completer<String>();
    final provider = FutureProvider<String>((ref) {
      calls++;
      return calls == 1 ? Future.error(const NetworkFailure()) : pending.future;
    });
    final container = ProviderContainer(retry: (_, _) => null);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('fr'),
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) => AsyncValueView<String>(
                value: ref.watch(provider),
                onRetry: () => ref.invalidate(provider),
                data: Text.new,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Pas de connexion'), findsOneWidget);

    await tester.tap(find.text('Réessayer'));
    await tester.pump();
    expect(container.read(provider).hasError, isTrue);
    expect(container.read(provider).isLoading, isTrue);
    expect(find.byType(LoadingView), findsOneWidget);
    expect(find.text('Réessayer'), findsNothing);

    pending.complete('prêt');
    await tester.pump();
    expect(find.text('prêt'), findsOneWidget);
  });

  testWidgets('AsyncValueView: loading, error, data', (tester) async {
    await pumpKit(
      tester,
      Column(
        children: [
          const AsyncValueView<String>(value: AsyncLoading(), data: Text.new),
          const AsyncValueView<String>(
            value: AsyncLoading(),
            data: Text.new,
            loading: Text('patience'),
          ),
          AsyncValueView<String>(
            value: const AsyncError(NetworkFailure(), StackTrace.empty),
            data: Text.new,
            onRetry: () {},
          ),
          const AsyncValueView<String>(
            value: AsyncData('prêt'),
            data: Text.new,
          ),
          const SizedBox(
            height: 200,
            child: EmptyState(
              glyph: LucideGlyph.inbox,
              title: 'Aucun document',
            ),
          ),
        ],
      ),
    );

    expect(find.byType(LoadingView), findsOneWidget);
    expect(find.text('patience'), findsOneWidget);
    expect(find.text('Pas de connexion'), findsOneWidget);
    expect(find.text('prêt'), findsOneWidget);
    expect(find.text('Aucun document'), findsOneWidget);
  });
}
