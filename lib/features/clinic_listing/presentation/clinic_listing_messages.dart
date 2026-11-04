import 'package:kiveto_mobile/features/clinic_listing/domain/clinic_listing.dart';
import 'package:kiveto_mobile/features/clinic_listing/domain/opening_schedule.dart';
import 'package:kiveto_mobile/features/clinic_listing/presentation/clinic_listing_providers.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/formatters/kiveto_format.dart';

// The French texts of the directory's screens: the server sends the
// clinics, their hours and codes; the labels are the app's.

/// A clinic's address on one line: « 7 quai Saint-Antoine, 69002 Lyon ».
String listingAddressLine(ListingAddress address) => [
  address.line,
  [?address.postalCode, address.city].join(' '),
].join(', ');

/// The meta line of a clinic of a search: its address, its distance from
/// the position searched around, its tags; what is not known left out
/// (« 18 rue des Abbesses, 75018 Paris · 2,1 km · Chats · Chiens »).
String clinicCardMeta(ClinicListingSummary clinic) {
  final address = clinic.address;
  final distance = clinic.distanceM;
  return [
    if (address != null) listingAddressLine(address),
    if (distance != null) KivetoFormat.distance(distance),
    ...clinic.tags,
  ].join(' · ');
}

/// « 08:30 ».
String clockTimeLabel(ClockTime time) =>
    KivetoFormat.clockTime(time.hour, time.minute);

/// The open status of a clinic's sheet and whether it is open: « Ouvert ·
/// ferme à 19:00 », « Fermé · ouvre à 14:00 », « Fermé · ouvre demain à
/// 09:00 », « Fermé · ouvre lundi à 09:00 »; none without opening hours.
(String text, bool open)? openingStatusLine(
  AppLocalizations l10n,
  OpeningStatus status,
) => switch (status) {
  OpenUntil(:final closesAt) => (
    l10n.clinicListingOpenUntil(clockTimeLabel(closesAt)),
    true,
  ),
  OpensLater(:final opensAt) => (
    l10n.clinicListingOpensLater(clockTimeLabel(opensAt)),
    false,
  ),
  OpensOn(:final opensAt, tomorrow: true) => (
    l10n.clinicListingOpensTomorrow(clockTimeLabel(opensAt)),
    false,
  ),
  OpensOn(:final weekday, :final opensAt) => (
    l10n.clinicListingOpensOn(
      KivetoFormat.weekdayName(weekday).toLowerCase(),
      clockTimeLabel(opensAt),
    ),
    false,
  ),
  NoOpeningHours() => null,
};

/// The days of a row of the hours grid: « Samedi » alone, « Lun – Ven »
/// for several.
String openingDaysLabel(OpeningRow row) => row.firstDay == row.lastDay
    ? KivetoFormat.weekdayName(row.firstDay)
    : '${KivetoFormat.weekdayAbbrev(row.firstDay)} – '
          '${KivetoFormat.weekdayAbbrev(row.lastDay)}';

/// A range of the hours grid: « 08:30 – 19:00 ».
String openingRangeLabel(OpeningRange range) =>
    '${clockTimeLabel(range.opensAt)} – ${clockTimeLabel(range.closesAt)}';

/// The SnackBar of a position that could not be read.
String locationMessage(AppLocalizations l10n, LocationProblem problem) =>
    switch (problem) {
      LocationProblem.denied => l10n.clinicSearchLocationDenied,
      LocationProblem.deniedForever => l10n.clinicSearchLocationDeniedForever,
      LocationProblem.disabled => l10n.clinicSearchLocationDisabled,
      LocationProblem.failed => l10n.clinicSearchLocationFailed,
    };
