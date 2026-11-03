// PortalConsentRepository on the real chain and the captures: Julien's,
// Marchand's and an empty account's consents of Paris, a marketing change
// (the PUT body in the order sms, email), the 422 of an emptied billing,
// a 409, the history's pages (the cursor in the query), Marchand's portal,
// clinic and system rows; the enums by name, unknown kept, an unknown
// channel dropped.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/client/domain/consent.dart';
import 'package:kiveto_mobile/features/client/infrastructure/portal_consent_repository.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';

import '../../../../support/fakes.dart';
import '../../../../support/portal_api/fake_portal_backend.dart';
import '../../../../support/portal_api/portal_http_harness.dart';

const _parisId = '01960000-0000-7000-8000-000000000001';
const _paris = ClinicId(_parisId);
const _consents = '$api/clinics/$_parisId/consents';
const _history = '$_consents/history';

Map<String, Object?> _fixture(String name) =>
    jsonDecode(File('$portalFixtures/$name').readAsStringSync())
        as Map<String, Object?>;

void main() {
  late PortalHarness harness;
  late PortalConsentRepository repository;

  setUp(() async {
    harness = await PortalHarness.create(tokens: pair('A'));
    repository = PortalConsentRepository(harness.http.server, harness.failures);
  });

  group('consents', () {
    test('Julien (capture): the five kinds in the API order, SMS, the '
        'grant dates in UTC, the effects', () async {
      harness.backend.on(
        'GET',
        _consents,
        PortalReply.fixture('clinics.paris.consents.get.200.json'),
      );

      final consents = await repository.consents(_paris);

      expect(consents.consents.map((consent) => consent.kind), const [
        ConsentKind.appointmentReminders,
        ConsentKind.vaccinationReminders,
        ConsentKind.clinicalDocuments,
        ConsentKind.billing,
        ConsentKind.marketing,
      ]);
      for (final consent in consents.consents) {
        expect(consent.channels, {ConsentChannel.sms});
        expect(consent.grantedAt?.isUtc, isTrue);
      }
      expect(
        consents.of(ConsentKind.vaccinationReminders)?.grantedAt,
        DateTime.utc(2026, 10, 3, 2, 24, 25),
      );
      expect(
        consents.of(ConsentKind.marketing)?.effect,
        ConsentEffect.sendControl,
      );
      expect(
        consents.of(ConsentKind.billing)?.effect,
        ConsentEffect.channelPreference,
      );
      expect(bearerOf(harness.backend.requests.single), 'Bearer A');
    });

    test('Marchand (capture): both channels, email only', () async {
      harness.backend.on(
        'GET',
        _consents,
        PortalReply.fixture('clinics.paris.consents.marchand.get.200.json'),
      );

      final consents = await repository.consents(_paris);

      expect(consents.of(ConsentKind.appointmentReminders)?.channels, {
        ConsentChannel.sms,
        ConsentChannel.email,
      });
      expect(consents.of(ConsentKind.clinicalDocuments)?.channels, {
        ConsentChannel.email,
      });
      expect(
        consents.of(ConsentKind.clinicalDocuments)?.grantedAt,
        DateTime.utc(2020, 7, 1, 22),
      );
    });

    test('an empty account (capture): nothing granted, no date', () async {
      harness.backend.on(
        'GET',
        _consents,
        PortalReply.fixture('clinics.paris.consents.empty.get.200.json'),
      );

      final consents = await repository.consents(_paris);

      expect(consents.consents, hasLength(5));
      expect(consents.consents.any((consent) => consent.granted), isFalse);
      expect(
        consents.consents.every((consent) => consent.grantedAt == null),
        isTrue,
      );
    });

    test('a kind, a channel and an effect this app does not know: unknown '
        'kept, the channel dropped', () async {
      final body = _fixture('clinics.paris.consents.get.200.json');
      final first = (body['consents']! as List<Object?>).first!;
      (first as Map<String, Object?>)
        ..['kind'] = 'newsletters'
        ..['channels'] = ['sms', 'push']
        ..['effect'] = 'mandatory';
      harness.backend.on('GET', _consents, PortalReply.json(jsonEncode(body)));

      final consent = (await repository.consents(_paris)).consents.first;

      expect(consent.kind, ConsentKind.unknown);
      expect(consent.channels, {ConsentChannel.sms});
      expect(consent.effect, ConsentEffect.unknown);
    });

    test('404: a NotFoundFailure', () async {
      harness.backend.on('GET', _consents, problem('not_found', 404));

      await expectLater(
        repository.consents(_paris),
        throwsA(isA<NotFoundFailure>()),
      );
    });
  });

  group('update', () {
    test('marketing on SMS and email (capture): the PUT body in the order '
        'sms, email; the consents the server stored', () async {
      harness.backend.on(
        'PUT',
        '$_consents/marketing',
        PortalReply.fixture('clinics.paris.consents.marketing.put.200.json'),
      );

      final stored = await repository.update(_paris, ConsentKind.marketing, {
        ConsentChannel.email,
        ConsentChannel.sms,
      });

      expect(stored.of(ConsentKind.marketing)?.channels, {
        ConsentChannel.sms,
        ConsentChannel.email,
      });
      expect(
        stored.of(ConsentKind.marketing)?.grantedAt,
        DateTime.utc(2026, 11, 3, 21, 50, 35),
      );
      expect(stored.of(ConsentKind.billing)?.granted, isFalse);
      final request = harness.backend.requests.single;
      expect(request.method, 'PUT');
      expect(utf8.decode(request.body), '{"channels":["sms","email"]}');
    });

    test(
      'every kind on its wire name; a withdrawal sends no channel',
      () async {
        final sent = <String, String>{};
        for (final wire in [
          'appointment_reminders',
          'vaccination_reminders',
          'marketing',
          'clinical_documents',
          'billing',
        ]) {
          harness.backend.onRequest('PUT', '$_consents/$wire', (request) {
            sent[wire] = utf8.decode(request.body);
            return PortalReply.fixture(
              'clinics.paris.consents.marketing.put.200.json',
            );
          });
        }

        for (final kind in ConsentKind.known) {
          await repository.update(_paris, kind, const {});
        }

        expect(sent.keys, [
          'appointment_reminders',
          'vaccination_reminders',
          'marketing',
          'clinical_documents',
          'billing',
        ]);
        expect(sent.values.toSet(), {'{"channels":[]}'});
      },
    );

    test('an unknown kind: an ArgumentError, no request', () async {
      expect(
        () => repository.update(_paris, ConsentKind.unknown, const {}),
        throwsArgumentError,
      );
      expect(harness.backend.requests, isEmpty);
    });

    test('billing emptied (capture): the 422 of the server', () async {
      harness.backend.on(
        'PUT',
        '$_consents/billing',
        PortalReply.fixture(
          'clinics.paris.consents.billing-empty.put.422.json',
          status: 422,
        ),
      );

      await expectLater(
        repository.update(_paris, ConsentKind.billing, const {}),
        throwsA(
          isA<ValidationFailure>().having(
            (failure) => failure.violations.single.propertyPath,
            'propertyPath',
            'channels',
          ),
        ),
      );
    });

    test('409: a ConflictFailure', () async {
      harness.backend.on(
        'PUT',
        '$_consents/marketing',
        problem('conflict', 409),
      );

      await expectLater(
        repository.update(_paris, ConsentKind.marketing, const {}),
        throwsA(isA<ConflictFailure>()),
      );
    });
  });

  group('history', () {
    test('two pages (captures): the cursor of the first in the query of '
        'the second', () async {
      final cursor =
          _fixture(
                'clinics.paris.consents.history.page1.get.200.json',
              )['nextCursor']!
              as String;
      harness.backend
        ..on(
          'GET',
          _history,
          PortalReply.fixture(
            'clinics.paris.consents.history.page1.get.200.json',
          ),
        )
        ..on(
          'GET',
          '$_history?cursor=$cursor',
          PortalReply.fixture(
            'clinics.paris.consents.history.page2.get.200.json',
          ),
        );

      final first = await repository.history(_paris);
      final second = await repository.history(_paris, cursor: cursor);

      expect(first.items, hasLength(3));
      final withdrawn = first.items.first;
      expect(withdrawn.kind, ConsentKind.marketing);
      expect(withdrawn.channel, ConsentChannel.email);
      expect(withdrawn.action, ConsentAction.withdrawn);
      expect(withdrawn.at, DateTime.utc(2026, 11, 3, 21, 50, 36));
      expect(withdrawn.at.isUtc, isTrue);
      expect(withdrawn.source, ConsentSource.portal);
      expect(withdrawn.author, 'Zoé Essai');
      expect(withdrawn.approximate, isFalse);
      expect(first.nextCursor, cursor);
      expect(second.items.single.action, ConsentAction.granted);
      expect(second.nextCursor, isNull);
      expect(
        harness.backend.requests.last.pathWithQuery,
        '$_history?cursor=$cursor',
      );
    });

    test(
      'Marchand (capture): portal, clinic and approximate system rows',
      () async {
        harness.backend.on(
          'GET',
          _history,
          PortalReply.fixture(
            'clinics.paris.consents.history.marchand.get.200.json',
          ),
        );

        final page = await repository.history(_paris);

        expect(page.items.map((entry) => entry.source).toSet(), {
          ConsentSource.portal,
          ConsentSource.clinic,
          ConsentSource.system,
        });
        final clinic = page.items[1];
        expect(clinic.kind, ConsentKind.billing);
        expect(clinic.author, 'La clinique');
        final system = page.items[4];
        expect(system.source, ConsentSource.system);
        expect(system.author, 'Reprise');
        expect(system.approximate, isTrue);
        expect(system.at, DateTime.utc(2020, 7, 1, 22));
        expect(page.nextCursor, isNull);
      },
    );

    test('values this app does not know: unknown kind, action and source '
        'kept; a change on an unknown channel dropped', () async {
      final body = _fixture(
        'clinics.paris.consents.history.page1.get.200.json',
      );
      final items = body['items']! as List<Object?>;
      (items[0]! as Map<String, Object?>)
        ..['kind'] = 'newsletters'
        ..['action'] = 'renewed'
        ..['source'] = 'import';
      (items[1]! as Map<String, Object?>)['channel'] = 'push';
      harness.backend.on('GET', _history, PortalReply.json(jsonEncode(body)));

      final page = await repository.history(_paris);

      expect(page.items, hasLength(2));
      expect(page.items.first.kind, ConsentKind.unknown);
      expect(page.items.first.action, ConsentAction.unknown);
      expect(page.items.first.source, ConsentSource.unknown);
    });

    test('400 cursor_invalid: a BusinessFailure', () async {
      harness.backend.on(
        'GET',
        '$_history?cursor=bad',
        problem('cursor_invalid', 400),
      );

      await expectLater(
        repository.history(_paris, cursor: 'bad'),
        throwsA(
          isA<BusinessFailure>().having(
            (failure) => failure.code,
            'code',
            'cursor_invalid',
          ),
        ),
      );
    });
  });
}
