// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i12;

import 'package:dio/dio.dart' as _i15;
import 'package:kiveto_portal_api/src/model/api_portal_v1_clinics_clinic_id_appointments_parameters_model.dart'
    as _i16;
import 'package:kiveto_portal_api/src/model/appointment_booking.dart' as _i18;
import 'package:kiveto_portal_api/src/model/appointment_booking_with_new_pet.dart'
    as _i20;
import 'package:kiveto_portal_api/src/model/appointment_cancellation.dart'
    as _i24;
import 'package:kiveto_portal_api/src/model/appointment_reschedule.dart'
    as _i26;
import 'package:kiveto_portal_api/src/operation/book_appointment.dart' as _i3;
import 'package:kiveto_portal_api/src/operation/book_appointment_with_new_pet.dart'
    as _i4;
import 'package:kiveto_portal_api/src/operation/cancel_appointment.dart' as _i7;
import 'package:kiveto_portal_api/src/operation/get_appointment.dart' as _i5;
import 'package:kiveto_portal_api/src/operation/get_appointment_calendar.dart'
    as _i6;
import 'package:kiveto_portal_api/src/operation/get_availability.dart' as _i9;
import 'package:kiveto_portal_api/src/operation/list_appointments.dart' as _i2;
import 'package:kiveto_portal_api/src/operation/list_motifs.dart' as _i10;
import 'package:kiveto_portal_api/src/operation/list_practitioners.dart'
    as _i11;
import 'package:kiveto_portal_api/src/operation/reschedule_appointment.dart'
    as _i8;
import 'package:kiveto_portal_api/src/response_wrapper/book_appointment_response.dart'
    as _i17;
import 'package:kiveto_portal_api/src/response_wrapper/book_appointment_with_new_pet_response.dart'
    as _i19;
import 'package:kiveto_portal_api/src/response_wrapper/cancel_appointment_response.dart'
    as _i23;
import 'package:kiveto_portal_api/src/response_wrapper/get_appointment_calendar_response.dart'
    as _i22;
import 'package:kiveto_portal_api/src/response_wrapper/get_appointment_response.dart'
    as _i21;
import 'package:kiveto_portal_api/src/response_wrapper/get_availability_response.dart'
    as _i27;
import 'package:kiveto_portal_api/src/response_wrapper/list_appointments_response.dart'
    as _i14;
import 'package:kiveto_portal_api/src/response_wrapper/list_motifs_response.dart'
    as _i28;
import 'package:kiveto_portal_api/src/response_wrapper/list_practitioners_response.dart'
    as _i29;
import 'package:kiveto_portal_api/src/response_wrapper/reschedule_appointment_response.dart'
    as _i25;
import 'package:kiveto_portal_api/src/server/server.dart' as _i1;
import 'package:tonik_util/tonik_util.dart' as _i13;

/// A practitioner bookable online for the motif; the route answers a plain JSON array of them.
class SchedulingApi {
  SchedulingApi(_i1.Server server)
    : _listAppointments = _i2.ListAppointments(
        server.baseUrl,
        () => server.dio,
      ),
      _bookAppointment = _i3.BookAppointment(server.baseUrl, () => server.dio),
      _bookAppointmentWithNewPet = _i4.BookAppointmentWithNewPet(
        server.baseUrl,
        () => server.dio,
      ),
      _getAppointment = _i5.GetAppointment(server.baseUrl, () => server.dio),
      _getAppointmentCalendar = _i6.GetAppointmentCalendar(
        server.baseUrl,
        () => server.dio,
      ),
      _cancelAppointment = _i7.CancelAppointment(
        server.baseUrl,
        () => server.dio,
      ),
      _rescheduleAppointment = _i8.RescheduleAppointment(
        server.baseUrl,
        () => server.dio,
      ),
      _getAvailability = _i9.GetAvailability(server.baseUrl, () => server.dio),
      _listMotifs = _i10.ListMotifs(server.baseUrl, () => server.dio),
      _listPractitioners = _i11.ListPractitioners(
        server.baseUrl,
        () => server.dio,
      );

  final _i2.ListAppointments _listAppointments;

  final _i3.BookAppointment _bookAppointment;

  final _i4.BookAppointmentWithNewPet _bookAppointmentWithNewPet;

  final _i5.GetAppointment _getAppointment;

  final _i6.GetAppointmentCalendar _getAppointmentCalendar;

  final _i7.CancelAppointment _cancelAppointment;

  final _i8.RescheduleAppointment _rescheduleAppointment;

  final _i9.GetAvailability _getAvailability;

  final _i10.ListMotifs _listMotifs;

  final _i11.ListPractitioners _listPractitioners;

  /// Les rendez-vous du propriétaire dans cette clinique.
  /// Rendez-vous des fiches reliées et de leurs animaux principaux. `upcoming` (par défaut) = rendez-vous qui occupent un créneau et commencent maintenant ou plus tard, du plus proche au plus lointain ; `past` = tous les autres, du plus récent au plus ancien.
  _i12.Future<
    _i13.TonikResult<_i14.ListAppointmentsResponse, _i15.Response<_i12.Object?>>
  >
  listAppointments({
    required _i12.String clinicId,
    _i16.ApiPortalV1ClinicsClinicIdAppointmentsParametersModel scope =
        _i2.ListAppointments.scopeDefault,
    _i12.String? cursor,
    _i12.int? limit,
    _i13.TonikCancellation? cancellation,
  }) async => this._listAppointments(
    clinicId: clinicId,
    scope: scope,
    cursor: cursor,
    limit: limit,
    cancellation: cancellation,
  );

  /// Réserve un créneau en ligne pour un animal du propriétaire.
  /// `status` = `confirmed` ou `pending_clinic_confirmation` selon le motif, `source: portal`. Rejouer la requête avec la même clé Idempotency-Key rend la même réponse sans second rendez-vous.
  _i12.Future<
    _i13.TonikResult<_i17.BookAppointmentResponse, _i15.Response<_i12.Object?>>
  >
  bookAppointment({
    required _i18.AppointmentBooking body,
    required _i12.String clinicId,
    required _i12.String idempotencyKey,
    _i13.TonikCancellation? cancellation,
  }) async => this._bookAppointment(
    body: body,
    clinicId: clinicId,
    idempotencyKey: idempotencyKey,
    cancellation: cancellation,
  );

  /// Réserve un créneau en ligne pour un animal que la clinique ne connaît pas encore.
  /// Crée l'animal du propriétaire (sexe et stérilisation inconnus) dans la même transaction que le rendez-vous : en cas de `slot_taken`, aucun animal ne reste. Seule une nouvelle tentative de la même requête (même Idempotency-Key) réutilise l'animal qu'elle a créé ; un animal créé par la clinique n'est jamais réutilisé. Archivé automatiquement si la demande est refusée ou expire avant tout acte clinique.
  _i12.Future<
    _i13.TonikResult<
      _i19.BookAppointmentWithNewPetResponse,
      _i15.Response<_i12.Object?>
    >
  >
  bookAppointmentWithNewPet({
    required _i20.AppointmentBookingWithNewPet body,
    required _i12.String clinicId,
    required _i12.String idempotencyKey,
    _i13.TonikCancellation? cancellation,
  }) async => this._bookAppointmentWithNewPet(
    body: body,
    clinicId: clinicId,
    idempotencyKey: idempotencyKey,
    cancellation: cancellation,
  );

  /// Un rendez-vous du propriétaire.
  /// `relatedCareItem` = le soin de l'animal du type de soin du motif, sinon `null` (avertissement de l'écran 16).
  _i12.Future<
    _i13.TonikResult<_i21.GetAppointmentResponse, _i15.Response<_i12.Object?>>
  >
  getAppointment({
    required _i12.String clinicId,
    required _i12.String appointmentId,
    _i13.TonikCancellation? cancellation,
  }) async => this._getAppointment(
    clinicId: clinicId,
    appointmentId: appointmentId,
    cancellation: cancellation,
  );

  /// Ajouter un rendez-vous à son agenda.
  /// `METHOD:PUBLISH`, sans participant ni organisateur, même `UID` que l'invitation envoyée par e-mail, `SEQUENCE` de la dernière envoyée, `STATUS:TENTATIVE` tant que le rendez-vous est à confirmer. 404 pour un rendez-vous d'un autre client, annulé, refusé, terminé ou non honoré.
  _i12.Future<
    _i13.TonikResult<
      _i22.GetAppointmentCalendarResponse,
      _i15.Response<_i12.Object?>
    >
  >
  getAppointmentCalendar({
    required _i12.String clinicId,
    required _i12.String appointmentId,
    _i13.TonikCancellation? cancellation,
  }) async => this._getAppointmentCalendar(
    clinicId: clinicId,
    appointmentId: appointmentId,
    cancellation: cancellation,
  );

  /// Annule un rendez-vous dans le délai d'annulation.
  /// Naturellement idempotente : un rendez-vous déjà annulé par le client rend 200 avec le même corps.
  _i12.Future<
    _i13.TonikResult<
      _i23.CancelAppointmentResponse,
      _i15.Response<_i12.Object?>
    >
  >
  cancelAppointment({
    required _i24.AppointmentCancellation body,
    required _i12.String clinicId,
    required _i12.String appointmentId,
    _i13.TonikCancellation? cancellation,
  }) async => this._cancelAppointment(
    body: body,
    clinicId: clinicId,
    appointmentId: appointmentId,
    cancellation: cancellation,
  );

  /// Déplace un rendez-vous pris en ligne.
  /// Seulement un rendez-vous pris en ligne avec un motif, dans le délai d'annulation. Le statut est conservé (une demande à confirmer reste à confirmer et repart pour un nouveau délai). Même créneau et même praticien : 200 sans effet.
  _i12.Future<
    _i13.TonikResult<
      _i25.RescheduleAppointmentResponse,
      _i15.Response<_i12.Object?>
    >
  >
  rescheduleAppointment({
    required _i26.AppointmentReschedule body,
    required _i12.String clinicId,
    required _i12.String appointmentId,
    _i13.TonikCancellation? cancellation,
  }) async => this._rescheduleAppointment(
    body: body,
    clinicId: clinicId,
    appointmentId: appointmentId,
    cancellation: cancellation,
  );

  /// Les créneaux réservables en ligne d'un praticien pour un motif.
  /// Un jour par date demandée (dates locales de la clinique, incluses, 14 jours au plus, `from` ≥ aujourd'hui local). `open` = jour d'ouverture, hors fermeture exceptionnelle, dans l'horizon. Créneaux émis avec le décalage de la clinique.
  _i12.Future<
    _i13.TonikResult<_i27.GetAvailabilityResponse, _i15.Response<_i12.Object?>>
  >
  getAvailability({
    required _i12.String clinicId,
    required _i12.String motifId,
    required _i12.String practitionerId,
    required _i13.Date from,
    required _i13.Date to,
    _i13.TonikCancellation? cancellation,
  }) async => this._getAvailability(
    clinicId: clinicId,
    motifId: motifId,
    practitionerId: practitionerId,
    from: from,
    to: to,
    cancellation: cancellation,
  );

  /// Les motifs de rendez-vous réservables en ligne.
  /// Dans l'ordre de la clinique. Avec `petId`, un motif est `suggested` quand l'animal a un soin en retard ou à prévoir du type de soin du motif (`suggestionReason` : « Rappel de vaccin en retard », « Rappel de vaccin à prévoir »…).
  _i12.Future<
    _i13.TonikResult<_i28.ListMotifsResponse, _i15.Response<_i12.Object?>>
  >
  listMotifs({
    required _i12.String clinicId,
    _i12.String? petId,
    _i13.TonikCancellation? cancellation,
  }) async => this._listMotifs(
    clinicId: clinicId,
    petId: petId,
    cancellation: cancellation,
  );

  /// Les praticiens réservables en ligne pour un motif.
  /// Par nom. Un praticien qui a quitté la clinique depuis l'enregistrement du motif n'apparaît plus.
  _i12.Future<
    _i13.TonikResult<
      _i29.ListPractitionersResponse,
      _i15.Response<_i12.Object?>
    >
  >
  listPractitioners({
    required _i12.String clinicId,
    required _i12.String motifId,
    _i13.TonikCancellation? cancellation,
  }) async => this._listPractitioners(
    clinicId: clinicId,
    motifId: motifId,
    cancellation: cancellation,
  );
}
