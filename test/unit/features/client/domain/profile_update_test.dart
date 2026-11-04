// The intent of the profile form: the names trimmed, the address sent only
// when one of its fields is filled, its country kept (FR when none).

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/client/domain/profile_update.dart';

ProfileUpdate _form({
  String firstName = ' Zoé ',
  String lastName = 'Essai ',
  String street = '',
  String postalCode = '',
  String city = '',
  String? country,
}) => ProfileUpdate.fromForm(
  firstName: firstName,
  lastName: lastName,
  streetLine1: street,
  postalCode: postalCode,
  city: city,
  currentCountry: country,
);

void main() {
  test('the names trimmed; an empty address is not sent', () {
    final update = _form(street: '  ', postalCode: ' ');

    expect(update.firstName, 'Zoé');
    expect(update.lastName, 'Essai');
    expect(update.address, isNull);
    expect(update.toString(), 'ProfileUpdate(address: false)');
  });

  test('a filled address, trimmed, its country kept', () {
    final address = _form(
      street: ' 12 rue des Lices ',
      postalCode: ' 13006',
      city: 'Marseille ',
      country: 'BE',
    ).address!;

    expect(address.streetLine1, '12 rue des Lices');
    expect(address.postalCode, '13006');
    expect(address.city, 'Marseille');
    expect(address.countryCode, 'BE');
  });

  test('one field is enough to send the address (the server says what is '
      'missing); no postal code is null; FR without a country', () {
    final update = _form(city: 'Lyon');

    final address = update.address!;
    expect(address.streetLine1, isEmpty);
    expect(address.postalCode, isNull);
    expect(address.city, 'Lyon');
    expect(address.countryCode, ProfileUpdate.defaultCountry);
    expect(ProfileUpdate.defaultCountry, 'FR');
    expect(update.toString(), 'ProfileUpdate(address: true)');
    expect(_form(postalCode: '75002').address?.postalCode, '75002');
  });

  test('empty names stay empty: the server refuses them', () {
    final update = _form(firstName: '  ', lastName: '');

    expect(update.firstName, isEmpty);
    expect(update.lastName, isEmpty);
  });
}
