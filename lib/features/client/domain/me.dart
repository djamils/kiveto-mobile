import 'package:kiveto_mobile/shared/domain/clinic_id.dart';

/// The signed-in account and its clinics (`GET /me`).
final class Me {
  const new({required this.account, this.clinics = const []});

  final Account account;

  /// In the API's order.
  final List<ClinicLink> clinics;

  /// The clinics whose link the clinic confirmed, in the API's order.
  List<ClinicLink> get confirmedClinics => [
    for (final clinic in clinics)
      if (clinic.linkStatus == LinkStatus.confirmed) clinic,
  ];

  /// False sends the clinic-scoped tabs to the clinic search.
  bool get hasConfirmedClinic =>
      clinics.any((clinic) => clinic.linkStatus == LinkStatus.confirmed);

  /// The clinic the app works on: [preferredClinicId] (the one chosen on
  /// this device) when it is still a confirmed clinic of this account, else
  /// the first confirmed one, else null.
  ClinicLink? activeClinic({String? preferredClinicId}) {
    final confirmed = confirmedClinics;
    for (final clinic in confirmed) {
      if (clinic.clinicId.value == preferredClinicId) return clinic;
    }
    return confirmed.firstOrNull;
  }

  @override
  String toString() => 'Me(${account.id}, ${clinics.length} clinics)';
}

/// The Portal account.
final class Account {
  const new({
    required this.id,
    required this.maskedPhone,
    this.firstName,
    this.lastName,
    this.email,
    this.emailVerified = false,
    this.address,
  });

  final String id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final bool emailVerified;

  /// As the server masks it (`+33 6 •• •• •• 78`): shown as received.
  final String maskedPhone;
  final PostalAddress? address;

  /// The first letters of the first and last names, upper case (`JG`),
  /// or null without any name.
  String? get initials {
    final letters = [
      for (final name in [firstName, lastName])
        if (name?.trim() case final String trimmed when trimmed.isNotEmpty)
          String.fromCharCode(trimmed.runes.first).toUpperCase(),
    ].join();
    return letters.isEmpty ? null : letters;
  }

  @override
  String toString() => 'Account($id)';
}

/// The postal address of the profile, as typed.
final class PostalAddress {
  const new({
    required this.line1,
    required this.city,
    required this.country,
    this.line2,
    this.postalCode,
  });

  final String line1;
  final String? line2;
  final String? postalCode;
  final String city;
  final String country;
}

/// How far the link with a clinic went: confirmed by the clinic, pending,
/// or a status this app does not know.
enum LinkStatus { confirmed, pending, unknown }

/// A clinic of the account.
final class ClinicLink {
  const new({
    required this.clinicId,
    required this.name,
    required this.timezone,
    required this.linkStatus,
    this.city,
    this.linkedAt,
    this.petNames = const [],
    this.tags = const [],
    this.unreadDocuments = 0,
  });

  final ClinicId clinicId;
  final String name;
  final String? city;

  /// The clinic's IANA zone (`Europe/Paris`).
  final String timezone;
  final LinkStatus linkStatus;

  /// When the link was made (UTC).
  final DateTime? linkedAt;
  final List<String> petNames;
  final List<String> tags;
  final int unreadDocuments;

  @override
  String toString() => 'ClinicLink(${clinicId.value}, $name)';
}
