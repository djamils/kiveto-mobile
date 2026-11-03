import 'package:kiveto_mobile/shared/domain/care_status.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';

/// The id of an appointment, as the Portal API sends it.
extension type const AppointmentId(String value);

/// The id of a booking motif (« Consultation », « Vaccination »…).
extension type const MotifId(String value);

/// The id of a practitioner of the clinic.
extension type const PractitionerId(String value);

/// Where an appointment stands, as the server says; [unknown] for a status
/// this app does not know yet.
enum AppointmentStatus {
  confirmed,
  pendingClinicConfirmation,
  cancelledByClient,
  cancelledByClinic,
  declined,
  completed,
  noShow,
  unknown,
}

/// Who booked the appointment: the clinic, or the owner on the portal.
enum AppointmentSource { clinic, portal, unknown }

/// Whether the pre-visit questionnaire was sent.
enum QuestionnaireStatus { notStarted, submitted, unknown }

/// Why the owner cancels (screen 16).
enum CancellationReason { unavailable, noLongerNeeded, seenElsewhere, other }

/// The two lists of screen 4: the appointments still to come (they hold a
/// slot and start now or later), and every other one.
enum AppointmentScope { upcoming, past }

/// The preventive care item an appointment's motif covers (the warning of
/// screen 16): its kind (`vaccination`, `internal_parasite`…), label and
/// due date, its status as the server decides it.
final class RelatedCareItem {
  const new({
    required this.kind,
    required this.label,
    required this.dueOn,
    required this.status,
  });

  final String kind;
  final String label;
  final LocalDate dueOn;
  final CareStatus status;
}

/// An appointment of the owner in a clinic, on the clinic's clock.
final class Appointment {
  const new({
    required this.id,
    required this.startAt,
    required this.endAt,
    required this.motifLabel,
    required this.practitionerId,
    required this.status,
    required this.source,
    required this.questionnaire,
    this.petId,
    this.petName,
    this.motifId,
    this.practitionerName,
    this.cancellableUntil,
    this.relatedCareItem,
  });

  final AppointmentId id;
  final ClinicInstant startAt;
  final ClinicInstant endAt;

  /// The pet (a plain id: the pets are another feature's); null for an
  /// appointment without pet.
  final String? petId;
  final String? petName;

  /// Null for an appointment the clinic booked without a portal motif.
  final MotifId? motifId;
  final String motifLabel;
  final PractitionerId practitionerId;
  final String? practitionerName;
  final AppointmentStatus status;
  final AppointmentSource source;

  /// Until when the owner may move or cancel it online (the clinic's
  /// window, decided by the server); null when they may not.
  final ClinicInstant? cancellableUntil;
  final QuestionnaireStatus questionnaire;
  final RelatedCareItem? relatedCareItem;

  /// The length of the appointment, in minutes.
  int get durationMinutes =>
      endAt.instant.difference(startAt.instant).inMinutes;

  /// Waiting for the clinic's confirmation.
  bool get isPending => status == AppointmentStatus.pendingClinicConfirmation;

  /// Still holding its slot: confirmed or waiting for the clinic.
  bool get isActive =>
      status == AppointmentStatus.confirmed ||
      status == AppointmentStatus.pendingClinicConfirmation;

  /// The owner may still cancel it online at [now] (UTC): before
  /// [cancellableUntil].
  bool isModifiableAt(DateTime now) {
    final until = cancellableUntil;
    return until != null && now.isBefore(until.instant);
  }

  /// The owner may still move it online at [now]: within the window, and
  /// booked on the portal with a motif (the server refuses any other
  /// reschedule with `booking_not_open`).
  bool isReschedulableAt(DateTime now) =>
      isModifiableAt(now) &&
      source == AppointmentSource.portal &&
      motifId != null;

  @override
  String toString() => 'Appointment(${id.value}, $startAt, $status)';
}

/// One page of a list of appointments.
final class AppointmentPage {
  const new({this.items = const [], this.nextCursor});

  final List<Appointment> items;

  /// Reads the next page; null on the last one.
  final String? nextCursor;
}
