// PortalMeRepository on the captures (Girard with Paris and Lyon, a new
// account without clinic, Essai's profile patch and its refused fields);
// the preferences store of the active clinic.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/client/domain/me.dart';
import 'package:kiveto_mobile/features/client/domain/profile_update.dart';
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
        expect(paris.phone, '+33142551890');
        expect(paris.address?.line, '18 rue des Abbesses');
        expect(paris.address?.postalCode, '75018');
        expect(paris.address?.city, 'Paris');
        final lyon = me.clinics.last;
        expect(lyon.phone, '+33478920145');
        expect(lyon.address?.line, '7 quai Saint-Antoine, Bâtiment B');
        expect(lyon.address?.postalCode, '69002');
        expect(lyon.address?.city, 'Lyon');
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
      (clinics[1]! as Map<String, Object?>)['phone'] = null;
      (clinics[1]! as Map<String, Object?>)['address'] = null;
      (clinics[0]! as Map<String, Object?>)['address'] = {
        'line': '18 rue des Abbesses',
        'postalCode': null,
        'city': 'Paris',
      };
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
      expect(me.clinics.last.phone, isNull);
      expect(me.clinics.last.address, isNull);
      expect(me.clinics.first.address?.postalCode, isNull);
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

    group('updateProfile', () {
      Map<String, Object?> body(PortalRequest request) =>
          jsonDecode(utf8.decode(request.body)) as Map<String, Object?>;

      test('Essai (capture): a merge patch with the names and the address; '
          'the account it answers', () async {
        harness.backend.on(
          'PATCH',
          _me,
          PortalReply.fixture('me.patch.200.json'),
        );

        final account = await repository.updateProfile(
          ProfileUpdate.fromForm(
            firstName: 'Zoé',
            lastName: 'Essai',
            streetLine1: '12 rue des Lices',
            postalCode: '13006',
            city: 'Marseille',
          ),
        );

        expect(account.id, '01a1a363-4839-75be-ab2c-b36720c2542b');
        expect(account.firstName, 'Zoé');
        expect(account.lastName, 'Essai');
        expect(account.email, isNull);
        expect(account.emailVerified, isFalse);
        expect(account.maskedPhone, '+33 6 •• •• •• 40');
        final address = account.address!;
        expect(address.line1, '12 rue des Lices');
        expect(address.line2, isNull);
        expect(address.postalCode, '13006');
        expect(address.city, 'Marseille');
        expect(address.country, 'FR');
        final request = harness.backend.requestsTo(_me).single;
        expect(request.method, 'PATCH');
        expect(request.contentType, 'application/merge-patch+json');
        expect(body(request), {
          'firstName': 'Zoé',
          'lastName': 'Essai',
          'address': {
            'streetLine1': '12 rue des Lices',
            'postalCode': '13006',
            'city': 'Marseille',
            'countryCode': 'FR',
          },
        });
      });

      test('without an address: the key is left out (unchanged); an account '
          'answered without address', () async {
        final answer = jsonDecode(
          File('$portalFixtures/me.patch.200.json').readAsStringSync(),
        ) as Map<String, Object?>;
        answer['address'] = null;
        harness.backend.on('PATCH', _me, PortalReply.json(jsonEncode(answer)));

        final account = await repository.updateProfile(
          const ProfileUpdate(firstName: 'Julien', lastName: 'Girard'),
        );

        expect(account.address, isNull);
        expect(body(harness.backend.requests.single), {
          'firstName': 'Julien',
          'lastName': 'Girard',
        });
      });

      test(
        'refused fields (capture): a ValidationFailure naming them',
        () async {
          harness.backend.on(
            'PATCH',
            _me,
            PortalReply.fixture('me.patch.fields.422.json', status: 422),
          );

          final failure = await repository
              .updateProfile(
                ProfileUpdate.fromForm(
                  firstName: '',
                  lastName: 'Essai',
                  streetLine1: '',
                  postalCode: '13006',
                  city: '',
                ),
              )
              .then<Object?>((_) => null, onError: (Object error) => error);

          expect(failure, isA<ValidationFailure>());
          expect(
            (failure! as ValidationFailure).violations.map(
              (violation) => violation.propertyPath,
            ),
            ['firstName', 'address.streetLine1', 'address.city'],
          );
        },
      );
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
