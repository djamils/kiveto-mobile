// Me: the confirmed clinics, the active clinic (the stored choice when it is
// still a confirmed one, else the first confirmed), the initials.

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/client/domain/me.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';

ClinicLink _clinic(String id, {LinkStatus status = LinkStatus.confirmed}) =>
    ClinicLink(
      clinicId: ClinicId(id),
      name: 'Clinique $id',
      timezone: 'Europe/Paris',
      linkStatus: status,
    );

Account _account({String? firstName, String? lastName}) => Account(
  id: 'acc',
  maskedPhone: '+33 6 •• •• •• 78',
  firstName: firstName,
  lastName: lastName,
);

void main() {
  final pending = _clinic('pending', status: LinkStatus.pending);
  final paris = _clinic('paris');
  final lyon = _clinic('lyon');
  final unknown = _clinic('unknown', status: LinkStatus.unknown);

  group('the clinics', () {
    final me = Me(
      account: _account(),
      clinics: [pending, paris, lyon, unknown],
    );

    test('confirmed ones, in the API order', () {
      expect(me.confirmedClinics, [paris, lyon]);
      expect(me.hasConfirmedClinic, isTrue);
    });

    test('the active clinic: the stored one when still confirmed, else the '
        'first confirmed', () {
      expect(me.activeClinic(preferredClinicId: 'lyon'), lyon);
      expect(me.activeClinic(preferredClinicId: 'paris'), paris);
      expect(me.activeClinic(), paris);
      expect(me.activeClinic(preferredClinicId: 'gone'), paris);
      // A pending link is never active.
      expect(me.activeClinic(preferredClinicId: 'pending'), paris);
    });

    test('no confirmed clinic: none active', () {
      final newcomer = Me(account: _account(), clinics: [pending]);

      expect(newcomer.hasConfirmedClinic, isFalse);
      expect(newcomer.activeClinic(preferredClinicId: 'pending'), isNull);
      expect(Me(account: _account()).activeClinic(), isNull);
    });

    test('readable, without personal data', () {
      expect('$me', 'Me(acc, 4 clinics)');
      expect('${me.account}', 'Account(acc)');
      expect('$paris', 'ClinicLink(paris, Clinique paris)');
    });
  });

  test('initials: the first letters of the names, upper case', () {
    expect(_account(firstName: 'julien', lastName: 'Girard').initials, 'JG');
    expect(_account(firstName: ' Élodie ').initials, 'É');
    expect(_account(lastName: 'Moreau').initials, 'M');
    expect(_account(firstName: ' ', lastName: '').initials, isNull);
    expect(_account().initials, isNull);
    // A first character outside the BMP: its whole code point.
    expect(_account(firstName: '\u{1D49C}lice').initials, '\u{1D49C}');
    expect(
      _account(firstName: '\u{1F436} Rex', lastName: 'Ng').initials,
      '\u{1F436}N',
    );
  });

  test('the defaults of a clinic link and an account', () {
    expect(paris.petNames, isEmpty);
    expect(paris.tags, isEmpty);
    expect(paris.unreadDocuments, 0);
    expect(paris.linkedAt, isNull);
    expect(_account().emailVerified, isFalse);
    const address = PostalAddress(
      line1: '1 rue de la Paix',
      city: 'Paris',
      country: 'FR',
    );
    expect(address.line2, isNull);
    expect(address.postalCode, isNull);
  });
}
