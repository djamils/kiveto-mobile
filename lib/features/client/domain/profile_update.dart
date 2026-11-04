/// What the owner asks `PATCH /me` to change: the names, and the postal
/// address when the form holds one. The server checks every value (lengths,
/// required fields) and answers which fields it refused.
final class ProfileUpdate {
  const new({required this.firstName, required this.lastName, this.address});

  /// The intent of the profile form: the names trimmed; an address only
  /// when one of its three fields is filled (an empty form leaves the
  /// stored address as it is: the API cannot clear it), with
  /// [currentCountry] (the address's country so far) or `FR`.
  factory fromForm({
    required String firstName,
    required String lastName,
    required String streetLine1,
    required String postalCode,
    required String city,
    String? currentCountry,
  }) {
    final (street, postal, town) = (
      streetLine1.trim(),
      postalCode.trim(),
      city.trim(),
    );
    final hasAddress = [street, postal, town].any((part) => part.isNotEmpty);
    return ProfileUpdate(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      address: hasAddress
          ? ProfileAddressInput(
              streetLine1: street,
              postalCode: postal.isEmpty ? null : postal,
              city: town,
              countryCode: currentCountry ?? defaultCountry,
            )
          : null,
    );
  }

  /// The country of an address the profile did not have yet.
  static const defaultCountry = 'FR';

  final String firstName;
  final String lastName;

  /// Null: the address is not sent (unchanged).
  final ProfileAddressInput? address;

  @override
  String toString() => 'ProfileUpdate(address: ${address != null})';
}

/// The postal address of a [ProfileUpdate], as typed.
final class ProfileAddressInput {
  const new({
    required this.streetLine1,
    required this.city,
    required this.countryCode,
    this.postalCode,
  });

  final String streetLine1;
  final String? postalCode;
  final String city;

  /// ISO 3166-1 alpha-2 (`FR`).
  final String countryCode;
}
