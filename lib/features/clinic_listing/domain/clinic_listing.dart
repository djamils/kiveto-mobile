// The domain imports no package (rule 1), so package:meta's @immutable is
// out of reach: the value objects below have only final fields.
// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/listing_id.dart';

/// The postal address of a clinic of the directory, as the clinic set it.
final class ListingAddress {
  const new({required this.line, required this.city, this.postalCode});

  /// The street line (`7 quai Saint-Antoine, Bâtiment B`).
  final String line;
  final String? postalCode;
  final String city;
}

/// A clinic of the directory as a search lists it (screen 10).
final class ClinicListingSummary {
  const new({
    required this.id,
    required this.name,
    required this.onKiveto,
    required this.onlineBooking,
    this.address,
    this.phone,
    this.distanceM,
    this.tags = const [],
    this.nextAvailableAt,
  });

  final ListingId id;
  final String name;

  /// Null when the clinic gave none.
  final ListingAddress? address;

  /// E.164 (`+33478920145`); null when the clinic gave none.
  final String? phone;

  /// From the position searched around, in metres; null for a search
  /// without position.
  final int? distanceM;

  /// On Kiveto (its sheet opens); false for a clinic only listed.
  final bool onKiveto;

  /// The clinic takes online booking requests of new clients now (the
  /// server computes it).
  final bool onlineBooking;
  final List<String> tags;

  /// The next slot open to a new client; always null in v1.
  final ClinicInstant? nextAvailableAt;

  @override
  String toString() => 'ClinicListingSummary(${id.value}, $name)';
}

/// One page of a search of the directory.
final class ClinicListingPage {
  const new({this.items = const [], this.nextCursor});

  /// In the server's order (by name, or by distance around a position).
  final List<ClinicListingSummary> items;

  /// Reads the next page; null on the last one.
  final String? nextCursor;
}

/// A time of day on the clinic's clock (`08:30`), without zone.
final class ClockTime implements Comparable<ClockTime> {
  /// [hour] 0–24 and [minute] 0–59 (`24:00` ends a day); [ArgumentError]
  /// otherwise.
  new(this.hour, this.minute) {
    if (hour < 0 || hour > 24 || minute < 0 || minute > 59) {
      throw ArgumentError('invalid time $hour:$minute');
    }
    if (hour == 24 && minute != 0) {
      throw ArgumentError('invalid time $hour:$minute');
    }
  }

  /// `HH:MM` as the API sends it; null for any other shape or an
  /// impossible time.
  static ClockTime? parse(String text) {
    final match = _format.firstMatch(text);
    if (match == null) return null;
    final (hour, minute) = (int.parse(match[1]!), int.parse(match[2]!));
    if (hour > 24 || minute > 59 || (hour == 24 && minute != 0)) return null;
    return ClockTime(hour, minute);
  }

  static final _format = RegExp(r'^(\d{2}):(\d{2})$');

  final int hour;
  final int minute;

  /// Minutes since midnight.
  int get minutes => hour * 60 + minute;

  bool isBefore(ClockTime other) => minutes < other.minutes;

  @override
  int compareTo(ClockTime other) => minutes.compareTo(other.minutes);

  @override
  bool operator ==(Object other) =>
      other is ClockTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() =>
      '${'$hour'.padLeft(2, '0')}:${'$minute'.padLeft(2, '0')}';
}

/// One opening range of a day of the week, on the clinic's clock: open
/// from [opensAt] (included) to [closesAt] (excluded).
final class OpeningHours {
  const new({required this.day, required this.opensAt, required this.closesAt});

  /// The ISO day of the week: 1 = Monday … 7 = Sunday.
  final int day;
  final ClockTime opensAt;
  final ClockTime closesAt;

  @override
  bool operator ==(Object other) =>
      other is OpeningHours &&
      other.day == day &&
      other.opensAt == opensAt &&
      other.closesAt == closesAt;

  @override
  int get hashCode => Object.hash(day, opensAt, closesAt);

  @override
  String toString() => 'OpeningHours($day, $opensAt–$closesAt)';
}

/// The sheet of a clinic of the directory (screen 11).
final class ClinicListingDetail {
  const new({
    required this.id,
    required this.name,
    required this.timezone,
    required this.acceptsNewClients,
    required this.onlineBooking,
    this.address,
    this.phone,
    this.openingHours = const [],
    this.tags = const [],
  });

  final ListingId id;
  final String name;
  final ListingAddress? address;
  final String? phone;

  /// The clinic's IANA zone (`Europe/Paris`).
  final String timezone;

  /// The ranges of a typical week, by day then opening time; exceptional
  /// closures are not in it.
  final List<OpeningHours> openingHours;

  /// The clinic takes new clients (online or not).
  final bool acceptsNewClients;

  /// The clinic takes online booking requests of new clients now.
  final bool onlineBooking;
  final List<String> tags;

  @override
  String toString() => 'ClinicListingDetail(${id.value}, $name)';
}

/// A position on Earth, in decimal degrees.
final class GeoPoint {
  const new(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  @override
  bool operator ==(Object other) =>
      other is GeoPoint &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'GeoPoint($latitude, $longitude)';
}

/// A search of the directory: the text typed (by name or city) and the
/// position searched around, if any. Two searches of the same text (once
/// trimmed) around the same position are equal.
final class ListingQuery {
  /// [text] is kept trimmed.
  new({String text = '', this.near}) : text = text.trim();

  final String text;
  final GeoPoint? near;

  /// The `q` to send: the text, none when it is empty.
  String? get q => text.isEmpty ? null : text;

  @override
  bool operator ==(Object other) =>
      other is ListingQuery && other.text == text && other.near == near;

  @override
  int get hashCode => Object.hash(text, near);

  @override
  String toString() => 'ListingQuery($text, $near)';
}
