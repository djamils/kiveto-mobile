// Screen 17 on the fake backend and the captures: ORD-36 (its date, vet,
// pet and line read-only), the conditions and their warning, « Envoyer la
// demande » once a condition is chosen, the request sent with its key,
// « Demande envoyée » (the documents lists read again, also when the page
// was left before the answer; back is « Retour aux documents »), the
// server's refusals (422 prescription_not_renewable with its reason, a note
// refused under the note, 429, 404), the retry of a failure with the same
// key and a new key once the content changed, the prescription gone or
// failing.

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/client/di.dart';
import 'package:kiveto_mobile/features/document/document.dart';
import 'package:kiveto_mobile/features/document/presentation/documents_providers.dart';
import 'package:kiveto_mobile/shared/domain/idempotency_key.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/fakes.dart';
import '../../../support/keyboard.dart';
import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';

const _paris = '01960000-0000-7000-8000-000000000001';
const _ord36 = '01a19a12-8b44-7c87-b043-5d82ad91c574';
const _prescription = '$api/clinics/$_paris/prescriptions/$_ord36';
const _renewal = '$_prescription/renewal-requests';
const _documents = '$api/clinics/$_paris/documents';
const _prescriptions = '$_documents?type=prescription';

Map<String, Object?> _jsonOf(PortalRequest request) =>
    jsonDecode(utf8.decode(request.body)) as Map<String, Object?>;

PortalReply _accepted() => PortalReply.fixture(
  'clinics.paris.prescriptions.renewal-requests.post.202.json',
  status: 202,
);

/// Julien signed in, Paris active, ORD-36 and the documents list.
FakePortalBackend _backend() => FakePortalBackend()
  ..on('GET', '$api/me', PortalReply.fixture('me.get.200.json'))
  ..on(
    'GET',
    _prescription,
    PortalReply.fixture('clinics.paris.prescriptions.renewable.get.200.json'),
  )
  ..on(
    'GET',
    _documents,
    PortalReply.fixture('clinics.paris.documents.prescriptions.get.200.json'),
  )
  ..on(
    'GET',
    _prescriptions,
    PortalReply.fixture('clinics.paris.documents.prescriptions.get.200.json'),
  );

Finder _chip(String label) => find.widgetWithText(KivetoChoiceChip, label);

Finder _send() => find.widgetWithText(KivetoButton, 'Envoyer la demande');

bool _canSend(WidgetTester tester) =>
    tester.widget<KivetoButton>(_send()).onPressed != null;

const _warning =
    'Le vétérinaire vous proposera sans doute une consultation avant de '
    'renouveler.';

void main() {
  late List<String> exits;
  late List<String> keys;

  setUp(() {
    exits = [];
    keys = [];
  });

  /// Screen 17 for ORD-36 on [backend] while [shown] (default: always);
  /// keys `key-1`, `key-2`…; the documents lists (every document, the
  /// prescriptions) kept read (the Documents tab under it).
  Future<ProviderContainer> pump(
    WidgetTester tester,
    FakePortalBackend backend, {
    ValueNotifier<bool>? shown,
  }) async {
    final container = await pumpPage(
      tester,
      ValueListenableBuilder<bool>(
        valueListenable: shown ?? ValueNotifier(true),
        builder: (context, visible, _) => visible
            ? RenewalPage(
                prescriptionId: _ord36,
                onBack: (context) => exits.add('back'),
                onDone: (context) => exits.add('done'),
              )
            : const SizedBox.shrink(),
      ),
      session: await memorySession(pair('A')),
      backend: backend,
      overrides: [
        activeClinicStoreProvider.overrideWithValue(
          InMemoryActiveClinicStore(),
        ),
        idempotencyKeyFactoryProvider.overrideWithValue(() {
          keys.add('key-${keys.length + 1}');
          return IdempotencyKey(keys.last);
        }),
      ],
    );
    container
      ..listen(documentListProvider(null), (_, _) {})
      ..listen(documentListProvider(DocumentKind.prescription), (_, _) {});
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'iOS: the note has no dismiss key, a drag on the page closes the '
    'keyboard',
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    (tester) async {
      await pump(tester, _backend());

      await expectDragClosesKeyboard(
        tester,
        field: find.byType(KivetoTextField),
        from: find.text('Ça va mieux'),
      );
    },
  );

  testWidgets(
    'iOS: a drag that scrolls the text of the note keeps the keyboard; a '
    'drag on the page closes it',
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    (tester) async {
      await pump(tester, _backend());

      await expectTextScrollKeepsKeyboard(
        tester,
        field: find.byType(KivetoTextField),
        from: find.text('Ça va mieux'),
      );
    },
  );

  testWidgets(
    'iOS: a form that fits (a tall screen) still closes the keyboard on a '
    'drag (always-scrollable physics)',
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    (tester) async {
      await pump(tester, _backend());
      tester.view.physicalSize = const Size(390 * 3, 2600 * 3);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpAndSettle();

      await expectDragClosesKeyboard(
        tester,
        field: find.byType(KivetoTextField),
        from: find.text('Ça va mieux'),
        beforeDrag: () => expect(
          tester
              .state<ScrollableState>(
                find
                    .descendant(
                      of: find.byType(KeyboardDismissOnDrag),
                      matching: find.byType(Scrollable),
                    )
                    .first,
              )
              .position
              .maxScrollExtent,
          0,
          reason: 'the form fits: nothing to scroll',
        ),
      );
    },
  );

  testWidgets('ORD-36 (capture): the header, its line read-only, the '
      'conditions, the note and the footnote; « Envoyer la demande » once a '
      'condition is chosen', (tester) async {
    await pump(tester, _backend());

    expect(find.text('Demander un renouvellement'), findsOneWidget);
    expect(
      find.text('Ordonnance du 2\u00a0nov.\u00a02026 · Dr Rousseau · Pepito'),
      findsOneWidget,
    );
    expect(find.text('Traitements à renouveler'), findsOneWidget);
    expect(find.text('Meloxidyl 1 mg/mL suspension buvable'), findsOneWidget);
    expect(
      find.text('Qté 1 · 0,1 mg/kg, 1×/j, pendant 10 jours, voie per os'),
      findsOneWidget,
    );
    expect(
      find.text("La demande porte sur toute l'ordonnance."),
      findsOneWidget,
    );
    expect(find.byType(Checkbox), findsNothing);
    expect(
      find.text('Comment va Pepito avec ce traitement\u00a0?'),
      findsOneWidget,
    );
    for (final label in [
      'Ça va mieux',
      'Pas d’amélioration',
      'Effets indésirables',
    ]) {
      expect(_chip(label), findsOneWidget, reason: label);
    }
    expect(
      find.text(
        'Précision pour le vétérinaire (facultatif)',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Retrait à la clinique. Le vétérinaire décide si un renouvellement '
        'sans consultation est possible.',
      ),
      findsOneWidget,
    );
    expect(_canSend(tester), isFalse);

    await tapVisible(tester, _chip('Ça va mieux'));
    expect(_canSend(tester), isTrue);
    expect(find.text(_warning), findsNothing);

    await tapVisible(tester, _chip('Pas d’amélioration'));
    expect(find.text(_warning), findsOneWidget);
    await tapVisible(tester, _chip('Effets indésirables'));
    expect(find.text(_warning), findsOneWidget);
  });

  testWidgets('sent (capture): the condition and note with the key; '
      '« Demande envoyée »; the documents read again; « Retour aux '
      'documents » and back: the exit', (tester) async {
    final backend = _backend()..on('POST', _renewal, _accepted());
    await pump(tester, backend);

    await tapVisible(tester, _chip('Effets indésirables'));
    await tester.enterText(
      find.byType(KivetoTextField),
      '  Il se gratte davantage. ',
    );
    await tester.pumpAndSettle();
    await tapVisible(tester, _send());

    final post = backend.requestsTo(_renewal).single;
    expect(post.headers['Idempotency-Key'], 'key-1');
    expect(_jsonOf(post), {
      'petCondition': 'adverse_effects',
      'note': 'Il se gratte davantage.',
    });
    expect(find.text('Demande envoyée'), findsOneWidget);
    expect(
      find.text(
        "La clinique vous préviendra quand l'ordonnance sera prête, ou si une "
        'consultation est nécessaire.',
      ),
      findsOneWidget,
    );
    expect(backend.requestsTo(_documents), hasLength(2));
    expect(backend.requestsTo(_prescriptions), hasLength(2));

    await tester.tap(find.widgetWithText(KivetoButton, 'Retour aux documents'));
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(exits, ['done', 'done']);
  });

  group('refusals', () {
    for (final (name, reply, message, documentReads) in [
      (
        "not renewable online (422, capture): the server's reason too",
        PortalReply.fixture(
          'clinics.paris.prescriptions.renewal-requests.'
          'not-renewable.post.422.json',
          status: 422,
        ),
        'Cette ordonnance ne peut pas être renouvelée en ligne\u00a0: '
            'contactez la clinique. Une demande de renouvellement de cette '
            'ordonnance a été refusée il y a moins de 7 jours.',
        1,
      ),
      (
        'too many requests (429)',
        problem('rate_limited', 429),
        'Vous avez envoyé beaucoup de demandes. Réessayez plus tard ou '
            'contactez la clinique.',
        1,
      ),
      (
        'gone (404): the documents read again',
        problem('not_found', 404),
        "Cette ordonnance n'est plus disponible.",
        2,
      ),
    ]) {
      testWidgets('$name: its message, no retry', (tester) async {
        final backend = _backend()..on('POST', _renewal, reply);
        await pump(tester, backend);

        await tapVisible(tester, _chip('Ça va mieux'));
        await tapVisible(tester, _send());

        // A callout above the button, in the bar.
        expect(
          find.descendant(
            of: find.descendant(
              of: find.byType(StickyCtaBar),
              matching: find.byType(KivetoCallout),
            ),
            matching: find.text(message),
          ),
          findsOneWidget,
        );
        expect(find.text('Réessayer'), findsNothing);
        expect(find.text('Demande envoyée'), findsNothing);
        expect(backend.requestsTo(_documents), hasLength(documentReads));
      });
    }

    testWidgets('a note too long for the server (422): its message under '
        'the note, no callout; an edit drops it', (tester) async {
      final backend = _backend()
        ..on(
          'POST',
          _renewal,
          PortalReply.json(
            jsonEncode({
              'type': 'validation_failed',
              'title': 'Données invalides.',
              'status': 422,
              'violations': [
                {'propertyPath': 'note', 'message': 'La note est trop longue.'},
              ],
            }),
            status: 422,
          ),
        );
      await pump(tester, backend);

      await tapVisible(tester, _chip('Ça va mieux'));
      await tapVisible(tester, _send());

      expect(
        find.descendant(
          of: find.byType(KivetoTextField),
          matching: find.text('La note est trop longue.'),
        ),
        findsOneWidget,
      );
      expect(find.byType(KivetoCallout), findsNothing);

      // The note edited: the server's answer no longer applies.
      await tester.enterText(find.byType(KivetoTextField), 'Plus court');
      await tester.pumpAndSettle();
      expect(find.text('La note est trop longue.'), findsNothing);
      expect(find.byType(KivetoCallout), findsNothing);
    });

    testWidgets('the server fails (503): « Réessayer » sends the same key', (
      tester,
    ) async {
      var failing = true;
      final backend = _backend()
        ..onRequest(
          'POST',
          _renewal,
          (_) => failing ? problem('service_unavailable', 503) : _accepted(),
        );
      await pump(tester, backend);

      await tapVisible(tester, _chip('Ça va mieux'));
      await tapVisible(tester, _send());
      final retry = find.widgetWithText(KivetoButton, 'Réessayer');
      expect(retry, findsOneWidget);

      failing = false;
      await tapVisible(tester, retry);

      expect(
        [
          for (final request in backend.requestsTo(_renewal))
            request.headers['Idempotency-Key'],
        ],
        ['key-1', 'key-1'],
      );
      expect(find.text('Demande envoyée'), findsOneWidget);
    });

    testWidgets('no answer: « Réessayer » sends the same key; another '
        'condition, a new key', (tester) async {
      var offline = true;
      final backend = _backend()
        ..onRequest(
          'POST',
          _renewal,
          (_) => offline ? throw StateError('offline') : _accepted(),
        );
      await pump(tester, backend);

      await tapVisible(tester, _chip('Ça va mieux'));
      // A blank note is no note.
      await tester.enterText(find.byType(KivetoTextField), '   ');
      await tester.pumpAndSettle();
      await tapVisible(tester, _send());
      expect(
        find.text('Vérifiez votre connexion Internet, puis réessayez.'),
        findsOneWidget,
      );
      expect(_jsonOf(backend.requestsTo(_renewal).single), {
        'petCondition': 'improved',
        'note': null,
      });
      await tapVisible(tester, find.widgetWithText(KivetoButton, 'Réessayer'));
      await tapVisible(tester, _send());

      await tapVisible(tester, _chip('Pas d’amélioration'));
      // The warning of the condition; the failure dropped by the change.
      expect(find.text(_warning), findsOneWidget);
      expect(
        find.text('Vérifiez votre connexion Internet, puis réessayez.'),
        findsNothing,
      );
      offline = false;
      await tapVisible(tester, _send());

      expect(
        [
          for (final request in backend.requestsTo(_renewal))
            request.headers['Idempotency-Key'],
        ],
        ['key-1', 'key-1', 'key-1', 'key-2'],
      );
      expect(find.text('Demande envoyée'), findsOneWidget);
    });
  });

  testWidgets('the page left while the request is on its way: the '
      'documents lists read again once it answers', (tester) async {
    final answer = Completer<PortalReply>();
    final shown = ValueNotifier(true);
    final backend = _backend()
      ..onRequest('POST', _renewal, (_) => answer.future);
    await pump(tester, backend, shown: shown);

    await tapVisible(tester, _chip('Ça va mieux'));
    await tester.tap(_send());
    await tester.pump();
    shown.value = false;
    await tester.pumpAndSettle();
    expect(find.byType(RenewalPage), findsNothing);

    answer.complete(_accepted());
    await tester.pumpAndSettle();

    expect(backend.requestsTo(_documents), hasLength(2));
    expect(backend.requestsTo(_prescriptions), hasLength(2));
  });

  testWidgets("the contract's cap: 500 for the note", (tester) async {
    await pump(tester, _backend());

    await tester.enterText(find.byType(KivetoTextField), 'a' * 510);
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text.length,
      500,
    );
  });

  testWidgets('the prescription is gone (404, capture): « Ordonnance '
      'indisponible »; back: the exit', (tester) async {
    final backend = _backend()
      ..on(
        'GET',
        _prescription,
        PortalReply.fixture(
          'clinics.paris.prescriptions.not-found.get.404.json',
          status: 404,
        ),
      );
    await pump(tester, backend);

    expect(find.text('Ordonnance indisponible'), findsOneWidget);
    expect(
      find.text("Cette ordonnance n'est plus disponible."),
      findsOneWidget,
    );
    expect(find.text('Réessayer'), findsNothing);

    await tester.tap(find.byType(KivetoIconButton));
    expect(exits, ['back']);
  });

  testWidgets('the prescription fails (503): an error and its retry', (
    tester,
  ) async {
    var failing = true;
    final backend = _backend()
      ..onRequest(
        'GET',
        _prescription,
        (_) => failing
            ? problem('service_unavailable', 503)
            : PortalReply.fixture(
                'clinics.paris.prescriptions.renewable.get.200.json',
              ),
      );
    await pump(tester, backend);

    expect(find.byType(ErrorView), findsOneWidget);
    failing = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(find.text('Meloxidyl 1 mg/mL suspension buvable'), findsOneWidget);
  });

  testWidgets('/me fails: its error; the retry reads /me again', (
    tester,
  ) async {
    var failing = true;
    final backend = _backend()
      ..onRequest(
        'GET',
        '$api/me',
        (_) => failing
            ? problem('service_unavailable', 503)
            : PortalReply.fixture('me.get.200.json'),
      );
    await pump(tester, backend);

    expect(find.byType(ErrorView), findsOneWidget);
    failing = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(find.text('Meloxidyl 1 mg/mL suspension buvable'), findsOneWidget);
  });

  testWidgets('no active clinic: « Ordonnance indisponible »', (tester) async {
    final backend = _backend()
      ..on('GET', '$api/me', PortalReply.fixture('me.no-clinic.get.200.json'));
    await pump(tester, backend);

    expect(find.text('Ordonnance indisponible'), findsOneWidget);
  });
}
