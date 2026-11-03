// PortalMeRepository on the captures (Girard with Paris and Lyon, a new
// account without clinic); the preferences store of the active clinic.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/client/domain/me.dart';
import 'package:kiveto_mobile/features/client/infrastructure/portal_me_repository.dart';
import 'package:kiveto_mobile/features/client/infrastructure/preferences_active_clinic_store.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../support/fakes.dart';
import '../../../../support/portal_api/fake_portal_backend.dart';
import '../../../../support/portal_api/portal_http_harness.dart';

const _me = '$api/me';

final class _MockPreferences extends Mock implements SharedPreferencesAsync;

void main() {
  group('PortalMeRepository', () {
    late PortalHarness harness;
    late PortalMeRepository repository;

    setUp(() async {
      harness = await PortalHarness.create(tokens: pair('A'));
      repository = PortalMeRepository(harness.http.server, harness.failures);
    });

    test(
      'Girard (capture): the account and both clinics, linkedAt in UTC',
      () async {
        harness.backend.on('GET', _me, PortalReply.fixture('me.get.200.json'));

        final me = await repository.me();

        expect(me.account.id, '01a19a10-d011-70c8-8daf-26e4db824374');
        expect(me.account.firstName, 'Julien');
        expect(me.account.lastName, 'Girard');
        expect(me.account.email, isNull);
        expect(me.account.emailVerified, isFalse);
        expect(me.account.maskedPhone, '+33 6 •• •• •• 78');
        expect(me.account.address, isNull);
        expect(me.account.initials, 'JG');
        expect(me.clinics.map((clinic) => clinic.clinicId), const [
          ClinicId('01960000-0000-7000-8000-000000000001'),
          ClinicId('01960000-0000-7000-8000-000000000101'),
        ]);
        final paris = me.clinics.first;
        expect(paris.name, 'Clinique Vétérinaire de Paris');
        expect(paris.city, 'Paris');
        expect(paris.timezone, 'Europe/Paris');
        expect(paris.linkStatus, LinkStatus.confirmed);
        expect(paris.linkedAt, DateTime.utc(2026, 9, 2, 2, 22, 35));
        expect(paris.petNames, ['Oslo']);
        expect(paris.tags, isEmpty);
        expect(paris.unreadDocuments, 1);
        expect(me.activeClinic(), paris);
      },
    );

    test('a new account (capture): no clinic', () async {
      harness.backend.on(
        'GET',
        _me,
        PortalReply.fixture('me.no-clinic.get.200.json'),
      );

      final me = await repository.me();

      expect(me.account.firstName, 'Test');
      expect(me.clinics, isEmpty);
      expect(me.hasConfirmedClinic, isFalse);
    });

    test('an address, the pending and unknown links', () async {
      final body = jsonDecode(
        File('$portalFixtures/me.get.200.json').readAsStringSync(),
      ) as Map<String, Object?>;
      final account = body['account']! as Map<String, Object?>;
      account['address'] = {
        'line1': '1 rue de la Paix',
        'line2': null,
        'postalCode': '75002',
        'city': 'Paris',
        'country': 'FR',
      };
      final clinics = body['clinics']! as List<Object?>;
      (clinics[0]! as Map<String, Object?>)['linkStatus'] = 'pending';
      (clinics[1]! as Map<String, Object?>)['linkStatus'] = 'archived';
      (clinics[1]! as Map<String, Object?>)['linkedAt'] = null;
      harness.backend.on('GET', _me, PortalReply.json(jsonEncode(body)));

      final me = await repository.me();

      final address = me.account.address!;
      expect(address.line1, '1 rue de la Paix');
      expect(address.line2, isNull);
      expect(address.postalCode, '75002');
      expect(address.city, 'Paris');
      expect(address.country, 'FR');
      expect(me.clinics.map((clinic) => clinic.linkStatus), [
        LinkStatus.pending,
        LinkStatus.unknown,
      ]);
      expect(me.clinics.last.linkedAt, isNull);
      expect(me.hasConfirmedClinic, isFalse);
    });

    test('a refusal (capture): unauthorized', () async {
      harness.backend.on(
        'GET',
        _me,
        PortalReply.fixture('me.get.401.json', status: 401),
      );
      harness.backend.on(
        'POST',
        '$api/auth/refresh',
        problem('refresh_revoked', 401),
      );

      await expectLater(repository.me(), throwsA(isA<UnauthorizedFailure>()));
    });
  });

  group('PreferencesActiveClinicStore', () {
    test('one key per account', () async {
      final preferences = _MockPreferences();
      when(() => preferences.getString('client.activeClinic.acc'))
          .thenAnswer((_) async => 'lyon');
      when(() => preferences.setString('client.activeClinic.acc', 'paris'))
          .thenAnswer((_) async {});
      var opened = 0;
      final store = PreferencesActiveClinicStore(() {
        opened++;
        return preferences;
      });

      expect(await store.read('acc'), 'lyon');
      await store.write('acc', 'paris');

      verify(() => preferences.setString('client.activeClinic.acc', 'paris'))
          .called(1);
      expect(
        PreferencesActiveClinicStore.keyOf('other'),
        'client.activeClinic.other',
      );
      expect(opened, 1);
    });

    test('preferences that cannot open fail the call, not the '
        'construction', () async {
      final store = PreferencesActiveClinicStore(
        () => throw StateError('no platform'),
      );

      await expectLater(store.read('acc'), throwsStateError);
      await expectLater(store.write('acc', 'paris'), throwsStateError);
    });
  });
}
