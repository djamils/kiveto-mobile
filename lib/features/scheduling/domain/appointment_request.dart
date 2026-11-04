import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/species.dart';

/// The id of a booking request, as the Portal API sends it.
extension type const AppointmentRequestId(String value);

/// Where a new client's booking request stands, as the server says;
/// [unknown] for a status this app does not know yet.
enum AppointmentRequestStatus { pending, confirmed, declined, unknown }

/// Why a request was not confirmed: refused by the clinic, expired without
/// an answer, cancelled, the account deleted; [unknown] for a reason this
/// app does not know yet.
enum DeclineReason { declined, expired, cancelled, accountDeleted, unknown }

/// A booking request of the account as a new client of a clinic of the
/// directory (`GET /me/booking-requests`): the slot it holds while the
/// clinic decides, on the clinic's clock.
final class AppointmentRequest {
  const new({
    required this.id,
    required this.clinicName,
    required this.motifLabel,
    required this.startAt,
    required this.status,
    this.clinicCity,
    this.petName,
    this.petSpecies,
    this.declineReason,
    this.appointmentId,
  });

  final AppointmentRequestId id;
  final String clinicName;
  final String? clinicCity;

  /// The new pet described with the request.
  final String? petName;
  final Species? petSpecies;
  final String motifLabel;
  final ClinicInstant startAt;
  final AppointmentRequestStatus status;

  /// Set when the request was [AppointmentRequestStatus.declined].
  final DeclineReason? declineReason;

  /// The appointment the clinic made of it, once confirmed.
  final AppointmentId? appointmentId;

  @override
  String toString() => 'AppointmentRequest(${id.value}, $startAt, $status)';
}

/// One page of the booking requests of the account.
final class AppointmentRequestPage {
  const new({this.items = const [], this.nextCursor});

  final List<AppointmentRequest> items;

  /// Reads the next page; null on the last one.
  final String? nextCursor;
}

/// The requests screen 4 shows in [scope] at [now] (UTC): a confirmed one
/// of the active clinic ([activeClinicName], trimmed, case ignored) is left
/// out (its appointment shows in that clinic's list), any other is kept;
/// they are to come when they start at [now] or later (the soonest first),
/// past otherwise (the latest first).
List<AppointmentRequest> requestsFor(
  AppointmentScope scope,
  List<AppointmentRequest> requests,
  DateTime now, {
  String? activeClinicName,
}) {
  String normalized(String name) => name.trim().toLowerCase();
  final active = switch (activeClinicName) {
    final String name => normalized(name),
    null => null,
  };
  bool listed(AppointmentRequest request) =>
      request.status != AppointmentRequestStatus.confirmed ||
      normalized(request.clinicName) != active;
  bool upcoming(AppointmentRequest request) =>
      !request.startAt.instant.isBefore(now);
  final shown = [
    for (final request in requests)
      if (listed(request) &&
          upcoming(request) == (scope == AppointmentScope.upcoming))
        request,
  ];
  return switch (scope) {
    AppointmentScope.upcoming =>
      shown..sort((a, b) => a.startAt.compareTo(b.startAt)),
    AppointmentScope.past =>
      shown..sort((a, b) => b.startAt.compareTo(a.startAt)),
  };
}
