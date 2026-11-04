import 'package:kiveto_mobile/features/client/domain/consent.dart';
import 'package:kiveto_mobile/features/client/domain/data_export.dart';
import 'package:kiveto_mobile/features/client/domain/me.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/presentation/formatters/kiveto_format.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';

// The French texts of the account screen (6) and its sheets, from the codes
// of the API. The account's instants are UTC: they are shown on the
// device's calendar and clock (they belong to no clinic).

/// The device's day of [instant].
LocalDate deviceDateOf(DateTime instant) {
  final local = instant.toLocal();
  return LocalDate(local.year, local.month, local.day);
}

/// The device's time of [instant] (`22:50`).
String deviceTimeOf(DateTime instant) {
  final local = instant.toLocal();
  return KivetoFormat.time(ClinicInstant(instant, local.timeZoneOffset));
}

/// The title of a consent kind (empty for an unknown one, never shown).
String consentKindTitle(AppLocalizations l10n, ConsentKind kind) =>
    switch (kind) {
      ConsentKind.appointmentReminders =>
        l10n.accountConsentAppointmentRemindersTitle,
      ConsentKind.vaccinationReminders =>
        l10n.accountConsentVaccinationRemindersTitle,
      ConsentKind.marketing => l10n.accountConsentMarketingTitle,
      ConsentKind.clinicalDocuments =>
        l10n.accountConsentClinicalDocumentsTitle,
      ConsentKind.billing => l10n.accountConsentBillingTitle,
      ConsentKind.unknown => '',
    };

/// The description of [consent], with « Accordé le … » when it is granted
/// with a date.
String consentDescription(AppLocalizations l10n, Consent consent) {
  final body = switch (consent.kind) {
    ConsentKind.appointmentReminders =>
      l10n.accountConsentAppointmentRemindersBody,
    ConsentKind.vaccinationReminders =>
      l10n.accountConsentVaccinationRemindersBody,
    ConsentKind.marketing => l10n.accountConsentMarketingBody,
    ConsentKind.clinicalDocuments => l10n.accountConsentClinicalDocumentsBody,
    ConsentKind.billing => l10n.accountConsentBillingBody,
    ConsentKind.unknown => '',
  };
  final grantedAt = consent.grantedAt;
  if (!consent.granted || grantedAt == null) return body;
  // « 30 oct. 2026 » stays on one line.
  final granted = l10n.accountConsentGrantedOn(
    KivetoFormat.dayMonthYear(deviceDateOf(grantedAt))
        .replaceAll(' ', '\u00a0'),
  );
  return '$body $granted';
}

String consentChannelLabel(AppLocalizations l10n, ConsentChannel channel) =>
    switch (channel) {
      ConsentChannel.sms => l10n.accountConsentChannelSms,
      ConsentChannel.email => l10n.accountConsentChannelEmail,
    };

/// The meta line of a change of the consent history: what, when, by whom.
String consentHistoryMeta(AppLocalizations l10n, ConsentHistoryEntry entry) {
  final date = KivetoFormat.dayMonthYear(deviceDateOf(entry.at));
  final author = entry.author;
  return switch ((entry.action, entry.approximate)) {
    (ConsentAction.granted, false) => l10n.accountHistoryGranted(date, author),
    (ConsentAction.granted, true) => l10n.accountHistoryGrantedApproximate(
      date,
      author,
    ),
    (ConsentAction.withdrawn, false) => l10n.accountHistoryWithdrawn(
      date,
      author,
    ),
    (ConsentAction.withdrawn, true) => l10n.accountHistoryWithdrawnApproximate(
      date,
      author,
    ),
    (ConsentAction.unknown, _) => l10n.accountHistoryChanged(date, author),
  };
}

/// The pill of an export's status; null for a status this app does not
/// know.
(String label, StatusTone tone)? dataExportPill(
  AppLocalizations l10n,
  DataExportStatus status,
) => switch (status) {
  DataExportStatus.pending => (l10n.accountExportPending, StatusTone.neutral),
  DataExportStatus.ready => (l10n.accountExportReady, StatusTone.success),
  DataExportStatus.failed => (l10n.accountExportFailed, StatusTone.danger),
  DataExportStatus.expired => (l10n.accountExportExpired, StatusTone.neutral),
  DataExportStatus.unknown => null,
};

/// The name of the profile card: the first and last names, or the phone
/// without any name.
String accountDisplayName(Account account) {
  final name = [
    account.firstName?.trim(),
    account.lastName?.trim(),
  ].whereType<String>().where((part) => part.isNotEmpty).join(' ');
  return name.isEmpty ? account.maskedPhone : name;
}

/// The address of the profile card: « {line1}[, {line2}], {postalCode}
/// {city} » (no postal code: « …, {city} »); null without an address.
String? accountAddressLine(PostalAddress? address) {
  if (address == null) return null;
  final postalCode = address.postalCode;
  return [
    address.line1,
    if (address.line2 case final line2? when line2.trim().isNotEmpty) line2,
    if (postalCode == null || postalCode.isEmpty)
      address.city
    else
      '$postalCode ${address.city}',
  ].join(', ');
}

/// The meta line of a clinic of the account: the pets, the tags, when the
/// link was made (« Oslo · rattachée le 2 sept. »); a pending link says it
/// waits for the clinic.
String clinicMeta(AppLocalizations l10n, ClinicLink clinic) {
  if (clinic.linkStatus == LinkStatus.pending) {
    return l10n.accountClinicPendingMeta;
  }
  final linkedAt = clinic.linkedAt;
  return [
    if (clinic.petNames.isNotEmpty) clinic.petNames.join(', '),
    ...clinic.tags,
    if (linkedAt != null)
      l10n.accountClinicLinkedOn(KivetoFormat.dayMonth(deviceDateOf(linkedAt))),
  ].join(' · ');
}
