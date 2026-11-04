// Screen 15 on the fake backend and the captures: the questionnaire of
// Oslo's appointment not started (« Rien de particulier » chosen, the
// treatment and the temperament to answer), the exclusivity of « Rien de
// particulier », « Lequel ? » for a treatment, the answers sent (the
// revision bumped, the message, the exit; the revision bumped too when
// the page was left before the answer), the answers already sent filling
// the form, the closed questionnaire read-only (with and without answers,
// and when it closes on send), the refusals and failures, the 404 of a
// cancelled appointment, no active clinic, the appointment unread.

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/questionnaire_page.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_providers.dart';
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
import 'scheduling_support.dart';

const _appointment = '$parisBase/appointments/$bookedId';
const _questionnaire = '$_appointment/questionnaire';
const _fixtures = 'clinics.paris.appointment.questionnaire';

/// The capture `<route>.<name>.json`, with the status its name ends with.
PortalReply _capture(String name) => PortalReply.fixture(
  '$_fixtures.$name.json',
  status: int.parse(name.substring(name.length - 3)),
);

/// Julien signed in, Paris active, Oslo's appointment and its
/// questionnaire as [questionnaire] (default: not started).
FakePortalBackend _backend({String questionnaire = 'get.200'}) =>
    julienBackend()
      ..on(
        'GET',
        _appointment,
        PortalReply.fixture('clinics.paris.appointment.get.200.json'),
      )
      ..on('GET', _questionnaire, _capture(questionnaire));

Map<String, Object?> _jsonOf(PortalRequest request) =>
    jsonDecode(utf8.decode(request.body)) as Map<String, Object?>;

Finder _chip(String label) => find.widgetWithText(KivetoChoiceChip, label);

Finder _sendButton() =>
    find.widgetWithText(KivetoButton, 'Envoyer à la clinique');

/// The scrollable of the page itself (FlowScaffold's).
ScrollableState _pageScroll(WidgetTester tester) => tester.state(
  find
      .descendant(
        of: find.byType(KeyboardDismissOnDrag),
        matching: find.byType(Scrollable),
      )
      .first,
);

void main() {
  late List<String> exits;

  setUp(() => exits = []);

  /// Screen 15 for Oslo's appointment on [backend] while [shown]
  /// (default: always).
  Future<ProviderContainer> pump(
    WidgetTester tester,
    FakePortalBackend backend, {
    ValueNotifier<bool>? shown,
  }) => pumpStep(
    tester,
    ValueListenableBuilder<bool>(
      valueListenable: shown ?? ValueNotifier(true),
      builder: (context, visible, _) => visible
          ? QuestionnairePage(
              appointmentId: bookedId,
              onBack: (context) => exits.add('back'),
              onSent: (context) => exits.add('sent'),
            )
          : const SizedBox.shrink(),
    ),
    backend: backend,
  );

  bool selected(WidgetTester tester, String label) =>
      tester.widget<KivetoChoiceChip>(_chip(label)).selected;

  bool canSend(WidgetTester tester) =>
      tester.widget<KivetoButton>(_sendButton()).onPressed != null;

  /// Sends the form: the page keeps its spinner once sent (its exit
  /// leaves it in the app; no router here).
  Future<void> send(WidgetTester tester) async {
    await tester.ensureVisible(_sendButton());
    await tester.pumpAndSettle();
    await tester.tap(_sendButton());
    await pumpBriefly(tester);
  }

  Future<void> fill(WidgetTester tester) async {
    await tapVisible(tester, _chip('Non'));
    await tapVisible(tester, _chip('Calme'));
  }

  testWidgets('not started (capture): the appointment, « Rien de '
      'particulier » chosen; « Envoyer à la clinique » once the treatment '
      'and the temperament are answered', (tester) async {
    await pump(tester, _backend());

    expect(find.text('Avant la consultation'), findsOneWidget);
    expect(
      find.text(
        'Oslo · Consultation · lun.\u00a09\u00a0nov.\u00a0à\u00a010:00',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        "2 minutes. Vos réponses sont transmises à l'équipe soignante.",
      ),
      findsOneWidget,
    );
    expect(
      find.text('Depuis la dernière visite, avez-vous remarqué\u00a0:'),
      findsOneWidget,
    );
    for (final label in [
      'Rien de particulier',
      'Toux',
      'Vomissements',
      'Diarrhée',
      'Baisse d’appétit',
      'Démangeaisons',
      'Boiterie',
    ]) {
      expect(_chip(label), findsOneWidget, reason: label);
      expect(selected(tester, label), label == 'Rien de particulier');
    }
    expect(
      find.text('Un traitement en cours pour Oslo\u00a0?'),
      findsOneWidget,
    );
    expect(selected(tester, 'Non'), isFalse);
    expect(selected(tester, 'Oui'), isFalse);
    expect(
      find.text('Comment se passent les visites pour Oslo\u00a0?'),
      findsOneWidget,
    );
    for (final label in ['Calme', 'Stressé(e)', 'Peut mordre ou griffer']) {
      expect(selected(tester, label), isFalse, reason: label);
    }
    expect(
      find.text('Autre chose à signaler (facultatif)', findRichText: true),
      findsOneWidget,
    );
    expect(canSend(tester), isFalse);

    await tapVisible(tester, _chip('Non'));
    expect(canSend(tester), isFalse);
    await tapVisible(tester, _chip('Stressé(e)'));
    expect(canSend(tester), isTrue);

    await tapVisible(tester, _chip('Rien de particulier'));
    expect(canSend(tester), isFalse);
  });

  testWidgets('a symptom replaces « Rien de particulier »; « Rien de '
      'particulier » again clears the others', (tester) async {
    await pump(tester, _backend());

    await tapVisible(tester, _chip('Toux'));
    expect(selected(tester, 'Toux'), isTrue);
    expect(selected(tester, 'Rien de particulier'), isFalse);
    await tapVisible(tester, _chip('Boiterie'));
    expect(selected(tester, 'Toux'), isTrue);
    expect(selected(tester, 'Boiterie'), isTrue);

    await tapVisible(tester, _chip('Rien de particulier'));
    expect(selected(tester, 'Rien de particulier'), isTrue);
    expect(selected(tester, 'Toux'), isFalse);
    expect(selected(tester, 'Boiterie'), isFalse);
  });

  testWidgets(
    'iOS: a multiline field has no dismiss key, a drag on the page (the '
    'flow scaffold) closes the keyboard',
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    (tester) async {
      await pump(tester, _backend());
      await tapVisible(tester, _chip('Oui'));

      await expectDragClosesKeyboard(
        tester,
        field: find.widgetWithText(KivetoTextField, 'Lequel\u00a0?'),
        from: _chip('Non'),
      );
    },
  );

  testWidgets(
    'iOS: a drag that scrolls the text of « Lequel ? » keeps the keyboard; '
    'a drag on the page closes it',
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    (tester) async {
      await pump(tester, _backend());
      await tapVisible(tester, _chip('Oui'));

      await expectTextScrollKeepsKeyboard(
        tester,
        field: find.widgetWithText(KivetoTextField, 'Lequel ?'),
        from: _chip('Non'),
      );
    },
  );

  testWidgets(
    'iOS: a page that fits (a tall screen) still closes the keyboard on a '
    'drag (always-scrollable physics)',
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    (tester) async {
      await pump(tester, _backend());
      tester.view.physicalSize = const Size(390 * 3, 2600 * 3);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpAndSettle();
      await tapVisible(tester, _chip('Oui'));

      await expectDragClosesKeyboard(
        tester,
        field: find.widgetWithText(KivetoTextField, 'Lequel ?'),
        from: _chip('Non'),
        beforeDrag: () => expect(
          _pageScroll(tester).position.maxScrollExtent,
          0,
          reason: 'the page fits: nothing to scroll',
        ),
      );
    },
  );

  testWidgets('« Oui » asks « Lequel ? »; « Non » hides it', (tester) async {
    await pump(tester, _backend());

    expect(find.text('Lequel\u00a0?'), findsNothing);
    await tapVisible(tester, _chip('Oui'));
    expect(find.text('Lequel\u00a0?'), findsOneWidget);
    expect(find.text('Nom du médicament, dose'), findsOneWidget);

    await tapVisible(tester, _chip('Non'));
    expect(find.text('Lequel\u00a0?'), findsNothing);
  });

  testWidgets('sent (capture): the answers PUT, the revision bumped, '
      '« Questionnaire envoyé à la clinique. », the exit', (tester) async {
    final backend = _backend()..on('PUT', _questionnaire, _capture('put.200'));
    final container = await pump(tester, backend);

    await tapVisible(tester, _chip('Toux'));
    await tapVisible(tester, _chip('Démangeaisons'));
    await tapVisible(tester, _chip('Oui'));
    await tester.enterText(
      find.widgetWithText(KivetoTextField, 'Lequel\u00a0?'),
      'Antibiotique, 1 comprimé matin et soir',
    );
    await tapVisible(tester, _chip('Stressé(e)'));
    await tester.enterText(
      find.byType(KivetoTextField).last,
      ' Tousse surtout la nuit depuis une semaine. ',
    );
    await send(tester);

    expect(_jsonOf(backend.requestsTo(_questionnaire).last), {
      'version': 1,
      'symptoms': ['cough', 'itching'],
      'ongoingTreatment': {
        'has': true,
        'details': 'Antibiotique, 1 comprimé matin et soir',
      },
      'temperament': 'stressed',
      'notes': 'Tousse surtout la nuit depuis une semaine.',
    });
    expect(container.read(appointmentsRevisionProvider), 1);
    expect(find.text('Questionnaire envoyé à la clinique.'), findsOneWidget);
    expect(exits, ['sent']);
  });

  testWidgets('answers already sent (capture): the form filled, the day '
      'they were sent; sending again PUTs', (tester) async {
    final backend = _backend(questionnaire: 'submitted.get.200')
      ..on('PUT', _questionnaire, _capture('put.200'));
    await pump(tester, backend);

    expect(
      find.text(
        'Réponses envoyées le mer.\u00a04\u00a0nov. à 02:00. Vous pouvez '
        "les modifier jusqu'au rendez-vous.",
      ),
      findsOneWidget,
    );
    expect(selected(tester, 'Toux'), isTrue);
    expect(selected(tester, 'Démangeaisons'), isTrue);
    expect(selected(tester, 'Rien de particulier'), isFalse);
    expect(selected(tester, 'Oui'), isTrue);
    expect(find.text('Antibiotique, 1 comprimé matin et soir'), findsOneWidget);
    expect(selected(tester, 'Stressé(e)'), isTrue);
    expect(
      find.text('Tousse surtout la nuit depuis une semaine.'),
      findsOneWidget,
    );
    expect(canSend(tester), isTrue);

    await send(tester);
    expect(backend.requestsTo(_questionnaire).last.method, 'PUT');
    expect(exits, ['sent']);
  });

  testWidgets("closed (Garnier's visit, capture): the answers read-only, "
      'the info callout, no bar', (tester) async {
    await pump(tester, _backend(questionnaire: 'locked.get.200'));

    expect(find.text('Questionnaire clos'), findsOneWidget);
    expect(
      find.text('Ce questionnaire ne peut plus être modifié.'),
      findsOneWidget,
    );
    expect(
      find.text('Réponses envoyées le mar.\u00a020\u00a0oct. à 21:30.'),
      findsOneWidget,
    );
    expect(selected(tester, 'Baisse d’appétit'), isTrue);
    expect(selected(tester, 'Diarrhée'), isTrue);
    expect(selected(tester, 'Toux'), isFalse);
    expect(selected(tester, 'Non'), isTrue);
    expect(selected(tester, 'Stressé(e)'), isTrue);
    for (final chip in tester.widgetList<KivetoChoiceChip>(
      find.byType(KivetoChoiceChip),
    )) {
      expect(chip.onSelected, isNull, reason: chip.label);
    }
    expect(find.text('Autre chose à signaler'), findsOneWidget);
    expect(
      find.text('Elle mange moins de foin depuis trois jours.'),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(StickyCtaBar), findsNothing);
  });

  testWidgets('closed with a treatment: « Lequel ? » and its answer', (
    tester,
  ) async {
    final backend = _backend()
      ..on(
        'GET',
        _questionnaire,
        editedReply('$_fixtures.submitted.get.200.json', (body) {
          (body! as Map<String, Object?>)['editable'] = false;
        }),
      );
    await pump(tester, backend);

    expect(find.text('Questionnaire clos'), findsOneWidget);
    expect(selected(tester, 'Oui'), isTrue);
    expect(find.text('Lequel\u00a0?'), findsOneWidget);
    expect(find.text('Antibiotique, 1 comprimé matin et soir'), findsOneWidget);
  });

  testWidgets('closed without answers (capture): the line saying so', (
    tester,
  ) async {
    await pump(tester, _backend(questionnaire: 'locked-not-started.get.200'));

    expect(find.text('Questionnaire clos'), findsOneWidget);
    expect(find.text("Le questionnaire n'a pas été rempli."), findsOneWidget);
    expect(find.byType(KivetoChoiceChip), findsNothing);
    expect(find.byType(StickyCtaBar), findsNothing);
  });

  testWidgets('closed on send (422 questionnaire_locked, capture): the '
      'questionnaire read again (loading meanwhile, not the form), '
      'read-only; the revision bumped', (tester) async {
    var locked = false;
    final reread = Completer<PortalReply>();
    final backend = _backend()
      ..onRequest('PUT', _questionnaire, (_) {
        locked = true;
        return _capture('locked.put.422');
      })
      ..onRequest(
        'GET',
        _questionnaire,
        (_) => locked ? reread.future : _capture('get.200'),
      );
    final container = await pump(tester, backend);

    await fill(tester);
    await send(tester);

    expect(find.byType(LoadingView), findsOneWidget);
    expect(_sendButton(), findsNothing);
    expect(find.byType(KivetoChoiceChip), findsNothing);

    reread.complete(_capture('locked-not-started.get.200'));
    await tester.pumpAndSettle();

    expect(find.text('Questionnaire clos'), findsOneWidget);
    expect(find.byType(KivetoCallout), findsOneWidget);
    expect(container.read(appointmentsRevisionProvider), 1);
    expect(exits, isEmpty);
  });

  testWidgets('refused (422 validation_failed, capture): the violation, the '
      'form kept, no retry', (tester) async {
    final backend = _backend()
      ..on('PUT', _questionnaire, _capture('validation.put.422'));
    final container = await pump(tester, backend);

    await fill(tester);
    await send(tester);

    // Above the button, in the bar: seen wherever the body is scrolled.
    expect(
      find.descendant(
        of: find.byType(StickyCtaBar),
        matching: find.text(
          '« Aucun symptôme » ne se combine pas avec un autre symptôme.',
        ),
      ),
      findsOneWidget,
    );
    expect(find.text('Réessayer'), findsNothing);
    expect(selected(tester, 'Calme'), isTrue);
    expect(canSend(tester), isTrue);
    expect(container.read(appointmentsRevisionProvider), 0);

    // An edit drops the server's answer.
    await tapVisible(tester, _chip('Stressé(e)'));
    expect(find.byType(KivetoCallout), findsNothing);
  });

  testWidgets('a text edited after a refusal drops the callout: the notes, '
      'the treatment details', (tester) async {
    final backend = _backend()
      ..on('PUT', _questionnaire, _capture('validation.put.422'));
    await pump(tester, backend);

    await fill(tester);
    await send(tester);
    expect(find.byType(KivetoCallout), findsOneWidget);
    await tester.enterText(find.byType(KivetoTextField).last, 'La nuit');
    await tester.pumpAndSettle();
    expect(find.byType(KivetoCallout), findsNothing);

    await tapVisible(tester, _chip('Oui'));
    await send(tester);
    expect(find.byType(KivetoCallout), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(KivetoTextField, 'Lequel\u00a0?'),
      'Antibiotique',
    );
    await tester.pumpAndSettle();
    expect(find.byType(KivetoCallout), findsNothing);
  });

  testWidgets("the contract's caps: 500 for the details, 1000 for the "
      'notes', (tester) async {
    await pump(tester, _backend());
    await tapVisible(tester, _chip('Oui'));

    await tester.enterText(
      find.widgetWithText(KivetoTextField, 'Lequel\u00a0?'),
      'a' * 510,
    );
    await tester.enterText(find.byType(KivetoTextField).last, 'b' * 1010);
    await tester.pumpAndSettle();

    final inputs = tester.widgetList<TextField>(find.byType(TextField));
    expect(inputs.map((input) => input.controller!.text.length), [500, 1000]);
  });

  testWidgets('no answer: the failure and « Réessayer », which sends '
      'again', (tester) async {
    var offline = true;
    final backend = _backend()
      ..onRequest(
        'PUT',
        _questionnaire,
        (_) => offline ? throw StateError('offline') : _capture('put.200'),
      );
    await pump(tester, backend);

    await fill(tester);
    await send(tester);
    expect(
      find.text('Vérifiez votre connexion Internet, puis réessayez.'),
      findsOneWidget,
    );

    offline = false;
    final retry = find.widgetWithText(KivetoButton, 'Réessayer');
    await tester.ensureVisible(retry);
    await tester.pumpAndSettle();
    await tester.tap(retry);
    await pumpBriefly(tester);
    expect(
      backend.requestsTo(_questionnaire).where((r) => r.method == 'PUT'),
      hasLength(2),
    );
    expect(exits, ['sent']);
  });

  testWidgets('the page left while the answers are on their way: the '
      'revision bumped once they are saved', (tester) async {
    final answer = Completer<PortalReply>();
    final shown = ValueNotifier(true);
    final backend = _backend()
      ..onRequest('PUT', _questionnaire, (_) => answer.future);
    final container = await pump(tester, backend, shown: shown);

    await fill(tester);
    await send(tester);
    shown.value = false;
    await tester.pumpAndSettle();
    expect(find.byType(QuestionnairePage), findsNothing);
    expect(container.read(appointmentsRevisionProvider), 0);

    answer.complete(_capture('put.200'));
    await tester.pumpAndSettle();

    expect(container.read(appointmentsRevisionProvider), 1);
    expect(exits, isEmpty);
  });

  testWidgets('no active clinic: « Rendez-vous introuvable », no retry', (
    tester,
  ) async {
    final backend = _backend()
      ..on('GET', '$api/me', PortalReply.fixture('me.no-clinic.get.200.json'));
    await pump(tester, backend);

    expect(find.text('Rendez-vous introuvable'), findsOneWidget);
    expect(find.text('Réessayer'), findsNothing);
  });

  testWidgets('the appointment cancelled (404, capture): « Rendez-vous '
      'introuvable »; back: the exit', (tester) async {
    await pump(tester, _backend(questionnaire: 'cancelled.get.404'));

    expect(find.text('Rendez-vous introuvable'), findsOneWidget);
    expect(
      find.text("Ce rendez-vous a été annulé ou n'existe plus."),
      findsOneWidget,
    );

    await tester.tap(find.byType(KivetoIconButton));
    expect(exits, ['back']);
  });

  testWidgets('a 404 on send: the appointment gone; the revision bumped', (
    tester,
  ) async {
    final backend = _backend()
      ..on('PUT', _questionnaire, problem('not_found', 404));
    final container = await pump(tester, backend);

    await fill(tester);
    await send(tester);

    expect(container.read(appointmentsRevisionProvider), 1);

    expect(
      find.descendant(
        of: find.byType(KivetoCallout),
        matching: find.text("Ce rendez-vous a été annulé ou n'existe plus."),
      ),
      findsOneWidget,
    );
  });

  testWidgets('the questionnaire fails (503): an error and its retry', (
    tester,
  ) async {
    var failing = true;
    final backend = _backend()
      ..onRequest(
        'GET',
        _questionnaire,
        (_) =>
            failing ? problem('service_unavailable', 503) : _capture('get.200'),
      );
    await pump(tester, backend);

    expect(find.byType(ErrorView), findsOneWidget);
    failing = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(_chip('Rien de particulier'), findsOneWidget);
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

    expect(find.text('Avant la consultation'), findsOneWidget);
  });

  testWidgets('the appointment unread: the form without the pet nor the '
      'slot', (tester) async {
    final backend = _backend()
      ..on('GET', _appointment, problem('service_unavailable', 503));
    await pump(tester, backend);

    expect(find.text('Avant la consultation'), findsOneWidget);
    expect(find.textContaining('Consultation ·'), findsNothing);
    expect(find.text('Un traitement en cours\u00a0?'), findsOneWidget);
    expect(find.text('Comment se passent les visites\u00a0?'), findsOneWidget);
  });

  testWidgets('an appointment without pet: its motif and slot', (tester) async {
    final backend = _backend()
      ..on(
        'GET',
        _appointment,
        editedReply('clinics.paris.appointment.get.200.json', (body) {
          (body! as Map<String, Object?>)['pet'] = null;
        }),
      );
    await pump(tester, backend);

    expect(
      find.text('Consultation · lun.\u00a09\u00a0nov.\u00a0à\u00a010:00'),
      findsOneWidget,
    );
  });
}
