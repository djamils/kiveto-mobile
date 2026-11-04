import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart'
    show AsyncNotifierProviderFamily, FutureProviderFamily;
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/patient/patient.dart'
    show careItemsProvider, petsProvider;
import 'package:kiveto_mobile/features/scheduling/di.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment_request.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking_venue.dart';
import 'package:kiveto_mobile/features/scheduling/domain/questionnaire.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/listing_id.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/domain/portal_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// The state of the scheduling screens. Every provider belongs to the
// account: each watches the session and only the id of the active clinic
// (`selectAsync` notifies neither while `/me` reloads nor for the same id).
// Read them through `AsyncData` patterns or `AsyncValueView`, never
// `.value`.

/// The changes the owner made to the appointments in this run (a booking,
/// a reschedule, a cancellation, a questionnaire sent; or an appointment
/// found closed or gone on the way): the appointments lists and the home
/// watch it, so they reload after each change; [AppointmentsRevision.bump]
/// also reloads the pets' care items (and the pets after a new one). Kept
/// alive: a change that answers after its screen closed still refreshes.
final appointmentsRevisionProvider =
    NotifierProvider<AppointmentsRevision, int>(AppointmentsRevision.new);

final class AppointmentsRevision extends Notifier<int> {
  @override
  int build() => 0;

  /// An appointment was booked (for a new pet: [newPet]), moved or
  /// cancelled, or its questionnaire was sent (or found closed or gone).
  void bump({bool newPet = false}) {
    state++;
    ref.invalidate(careItemsProvider);
    if (newPet) ref.invalidate(petsProvider);
  }
}

/// The id of the active clinic, for the account of the session.
Future<ClinicId?> activeClinicIdOf(Ref ref) {
  ref.watch(sessionStatusProvider);
  return ref.watch(
    activeClinicProvider.selectAsync((clinic) => clinic?.clinicId),
  );
}

/// The motifs a clinic opens to online booking, for a pet (its id: the
/// server suggests the motifs of its care items due) or a new one (null).
final FutureProviderFamily<List<BookingMotif>, (ClinicId, String?)>
bookingMotifsProvider = FutureProvider.autoDispose
    .family<List<BookingMotif>, (ClinicId, String?)>((ref, key) {
      ref.watch(sessionStatusProvider);
      final (clinicId, petId) = key;
      return ref
          .watch(schedulingRepositoryProvider)
          .motifs(clinicId, petId: petId);
    });

/// The motifs a clinic of the directory opens online to new clients, in
/// its order.
final FutureProviderFamily<List<BookingMotif>, ListingId>
listingMotifsProvider = FutureProvider.autoDispose
    .family<List<BookingMotif>, ListingId>((ref, listingId) {
      ref.watch(sessionStatusProvider);
      return ref.watch(newClientBookingRepositoryProvider).motifs(listingId);
    });

/// The practitioners bookable online for a motif of a venue: a clinic of
/// the account, or a clinic of the directory for a new client.
final FutureProviderFamily<List<Practitioner>, (BookingVenue, MotifId)>
practitionersProvider = FutureProvider.autoDispose
    .family<List<Practitioner>, (BookingVenue, MotifId)>((ref, key) {
      ref.watch(sessionStatusProvider);
      final (venue, motifId) = key;
      return switch (venue) {
        ClinicVenue(:final clinicId) =>
          ref
              .watch(schedulingRepositoryProvider)
              .practitioners(clinicId, motifId),
        ListingVenue(:final listingId) =>
          ref
              .watch(newClientBookingRepositoryProvider)
              .practitioners(listingId, motifId),
      };
    });

/// The days one availability request covers (the API's maximum).
const availabilityWindowDays = 14;

/// The availability of a practitioner for a motif of a venue from a day
/// on.
typedef AvailabilityKey = (BookingVenue, MotifId, PractitionerId, LocalDate);

/// The answer of one availability request: [availabilityWindowDays] days
/// from [from].
@immutable
final class AvailabilityWindow {
  const new({required this.from, required this.days});

  /// The first day asked for (the next day after a `from` refused as past).
  final LocalDate from;
  final List<AvailabilityDay> days;

  /// The first day of the next window.
  LocalDate get next => from.addDays(availabilityWindowDays);
}

/// The availability of a practitioner for a motif of a venue,
/// [availabilityWindowDays] days from a day. The day comes from the
/// device's clock: the clinic, in another zone, may still be on the day
/// before and refuse it as past (`422 validation_failed` on `from`), so
/// it is asked once more from the next day (both venues).
final FutureProviderFamily<AvailabilityWindow, AvailabilityKey>
availabilityProvider = FutureProvider.autoDispose
    .family<AvailabilityWindow, AvailabilityKey>((ref, key) async {
      ref.watch(sessionStatusProvider);
      final (venue, motifId, practitionerId, from) = key;
      final Future<List<AvailabilityDay>> Function(LocalDate from, LocalDate to)
      days;
      switch (venue) {
        case ClinicVenue(:final clinicId):
          final repository = ref.watch(schedulingRepositoryProvider);
          days = (from, to) => repository.availability(
            clinicId,
            motifId,
            practitionerId,
            from,
            to,
          );
        case ListingVenue(:final listingId):
          final repository = ref.watch(newClientBookingRepositoryProvider);
          days = (from, to) => repository.availability(
            listingId,
            motifId,
            practitionerId,
            from,
            to,
          );
      }
      Future<AvailabilityWindow> read(LocalDate start) async =>
          AvailabilityWindow(
            from: start,
            days: await days(start, start.addDays(availabilityWindowDays - 1)),
          );
      try {
        return await read(from);
      } on ValidationFailure catch (failure) {
        if (!failure.violations.any((v) => v.propertyPath == 'from')) rethrow;
        return await read(from.addDays(1));
      }
    });

/// The booking requests of the account as a new client (its first page:
/// enough for the few a new client may have), for the account of the
/// session; reloaded after every change the owner makes
/// ([appointmentsRevisionProvider]). Signed out, it fails with an
/// [UnauthorizedFailure] without calling the API.
final FutureProvider<List<AppointmentRequest>> appointmentRequestsProvider =
    FutureProvider<List<AppointmentRequest>>((ref) async {
      ref.watch(appointmentsRevisionProvider);
      if (ref.watch(sessionStatusProvider) == SessionStatus.signedOut) {
        throw const UnauthorizedFailure();
      }
      final page = await ref
          .watch(newClientBookingRepositoryProvider)
          .requests(limit: appointmentRequestsLimit);
      return page.items;
    });

/// The requests read on screen 4 (the API's maximum page).
const appointmentRequestsLimit = 50;

/// An appointment of the active clinic, with the clinic it belongs to (a
/// [NotFoundFailure] without an active clinic).
typedef ClinicAppointment = ({ClinicId clinicId, Appointment appointment});

final FutureProviderFamily<ClinicAppointment, AppointmentId>
appointmentProvider = FutureProvider.autoDispose
    .family<ClinicAppointment, AppointmentId>((ref, id) async {
      final repository = ref.watch(schedulingRepositoryProvider);
      final clinicId = await activeClinicIdOf(ref);
      if (clinicId == null) throw const NotFoundFailure();
      return (
        clinicId: clinicId,
        appointment: await repository.appointment(clinicId, id),
      );
    });

/// The pre-visit questionnaire of an appointment of the active clinic, with
/// the clinic it belongs to (a [NotFoundFailure] without an active clinic).
typedef ClinicQuestionnaire = ({
  ClinicId clinicId,
  Questionnaire questionnaire,
});

final FutureProviderFamily<ClinicQuestionnaire, AppointmentId>
questionnaireProvider = FutureProvider.autoDispose
    .family<ClinicQuestionnaire, AppointmentId>((ref, id) async {
      final repository = ref.watch(questionnaireRepositoryProvider);
      final clinicId = await activeClinicIdOf(ref);
      if (clinicId == null) throw const NotFoundFailure();
      return (
        clinicId: clinicId,
        questionnaire: await repository.questionnaire(clinicId, id),
      );
    });

/// The appointments of the active clinic for one scope, page after page;
/// each scope keeps its own list. Reloaded after every change the owner
/// makes ([appointmentsRevisionProvider]).
final AsyncNotifierProviderFamily<
  AppointmentListNotifier,
  AppointmentListState,
  AppointmentScope
>
appointmentListProvider =
    AsyncNotifierProvider.family<
      AppointmentListNotifier,
      AppointmentListState,
      AppointmentScope
    >(AppointmentListNotifier.new);

/// The pages read so far of one scope.
@immutable
final class AppointmentListState {
  const new({
    this.clinicId,
    this.items = const [],
    this.nextCursor,
    this.loadingMore = false,
    this.moreError,
  });

  /// No active clinic: nothing to list.
  const new empty() : this();

  /// The clinic the items belong to (null: no active clinic).
  final ClinicId? clinicId;
  final List<Appointment> items;

  /// Reads the next page; null after the last one.
  final String? nextCursor;

  /// A next page is on its way.
  final bool loadingMore;

  /// Why the last next page failed (the items read so far stay).
  final Object? moreError;
}

final class AppointmentListNotifier
    extends AsyncNotifier<AppointmentListState> {
  new(this.scope);

  final AppointmentScope scope;

  @override
  Future<AppointmentListState> build() async {
    ref.watch(appointmentsRevisionProvider);
    final repository = ref.watch(schedulingRepositoryProvider);
    final clinicId = await activeClinicIdOf(ref);
    if (clinicId == null) return const AppointmentListState.empty();
    final page = await repository.appointments(clinicId, scope);
    return AppointmentListState(
      clinicId: clinicId,
      items: page.items,
      nextCursor: page.nextCursor,
    );
  }

  /// Reads the next page (nothing on the last page, while a page loads, or
  /// while the list reloads). A failure keeps the items and sets
  /// `moreError`; a `400 cursor_invalid` reloads the list from its first
  /// page.
  Future<void> loadMore() async {
    final current = switch (state) {
      AsyncData(:final value, isLoading: false) => value,
      _ => null,
    };
    final clinicId = current?.clinicId;
    final cursor = current?.nextCursor;
    if (current == null ||
        clinicId == null ||
        cursor == null ||
        current.loadingMore) {
      return;
    }
    // A rebuild meanwhile (another session or clinic, a change) gives the
    // notifier a new ref: the answer for this one is dropped.
    final built = ref;
    state = AsyncData(
      AppointmentListState(
        clinicId: clinicId,
        items: current.items,
        nextCursor: cursor,
        loadingMore: true,
      ),
    );
    try {
      final page = await ref
          .read(schedulingRepositoryProvider)
          .appointments(clinicId, scope, cursor: cursor);
      if (!built.mounted) return;
      if (state case AsyncData(:final value)) {
        state = AsyncData(
          AppointmentListState(
            clinicId: clinicId,
            items: [...value.items, ...page.items],
            nextCursor: page.nextCursor,
          ),
        );
      }
    } on Object catch (error) {
      if (!built.mounted) return;
      if (error case BusinessFailure(code: 'cursor_invalid')) {
        ref.invalidateSelf();
        return;
      }
      if (state case AsyncData(:final value)) {
        state = AsyncData(
          AppointmentListState(
            clinicId: clinicId,
            items: value.items,
            nextCursor: cursor,
            moreError: error,
          ),
        );
      }
    }
  }
}

/// Hands an `.ics` to the system share sheet (a seam for the tests:
/// share_plus talks to the platform). Android has no `text/calendar` VIEW
/// handler worth relying on; its share sheet (ACTION_SEND) and iOS's (with
/// « Ajouter au calendrier ») take the file. `origin` is the global rect of
/// the tapped control: on iPad the sheet is a popover anchored to it
/// (`sharePositionOrigin`); the phones ignore it.
final calendarSharerProvider =
    Provider<Future<void> Function(PortalFile file, Rect origin)>(
      (ref) => (file, origin) async {
        await SharePlus.instance.share(
          ShareParams(
            files: [
              XFile.fromData(
                Uint8List.fromList(file.bytes),
                mimeType: file.contentType,
              ),
            ],
            fileNameOverrides: [file.fileName ?? 'rendez-vous.ics'],
            sharePositionOrigin: origin,
          ),
        );
      },
    );

/// Opens a `tel:` link; true when an app took it (a seam for the tests:
/// url_launcher talks to the platform).
final phoneDialerProvider = Provider<Future<bool> Function(Uri uri)>(
  (ref) => launchUrl,
);
