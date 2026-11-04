// The new-client booking's domain: the venue of a slot (a clinic of the
// account or of the directory, as family keys), the booking requests and
// the lists screen 4 shows of them (confirmed left out, to come from the
// soonest, past from the latest), the listing draft without clinic.

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment_request.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking_draft.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking_venue.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/idempotency_key.dart';
import 'package:kiveto_mobile/shared/domain/listing_id.dart';
import 'package:kiveto_mobile/shared/domain/species.dart';

AppointmentRequest _request(
  String id,
  String startAt, {
  AppointmentRequestStatus status = AppointmentRequestStatus.pending,
  String clinicName = 'Clinique Vétérinaire de Lyon',
}) => AppointmentRequest(
  id: AppointmentRequestId(id),
  clinicName: clinicName,
  motifLabel: 'Consultation',
  startAt: ClinicInstant.parse(startAt),
  status: status,
);

void main() {
  test('BookingVenue: a clinic and a listing of the same id differ; equal '
      'venues are one key', () {
    const clinic = ClinicVenue(ClinicId('x'));
    const listing = ListingVenue(ListingId('x'));

    expect(clinic, const ClinicVenue(ClinicId('x')));
    expect(clinic.hashCode, const ClinicVenue(ClinicId('x')).hashCode);
    expect(clinic, isNot(const ClinicVenue(ClinicId('y'))));
    expect(listing, const ListingVenue(ListingId('x')));
    expect(listing.hashCode, const ListingVenue(ListingId('x')).hashCode);
    expect(listing, isNot(const ListingVenue(ListingId('y'))));
    expect(clinic == listing, isFalse);
    expect(listing == clinic, isFalse);
    expect('$clinic', 'ClinicVenue(x)');
    expect('$listing', 'ListingVenue(x)');
  });

  group('requestsFor', () {
    final now = DateTime.utc(2026, 11, 9, 8);
    final requests = [
      _request('later', '2026-11-12T14:00:00+01:00'),
      _request(
        'confirmed',
        '2026-11-10T09:00:00+01:00',
        status: AppointmentRequestStatus.confirmed,
      ),
      _request(
        'soon',
        '2026-11-10T09:00:00+01:00',
        status: AppointmentRequestStatus.declined,
      ),
      // At now exactly: to come.
      _request('now', '2026-11-09T09:00:00+01:00'),
      _request('old', '2026-11-05T09:00:00+01:00'),
      _request(
        'older',
        '2026-11-04T09:00:00+01:00',
        status: AppointmentRequestStatus.unknown,
      ),
      _request('recent', '2026-11-09T08:59:00+01:00'),
    ];

    List<String> ids(
      AppointmentScope scope,
      List<AppointmentRequest> requests, {
      String? active = 'Clinique Vétérinaire de Lyon',
    }) => [
      for (final request in requestsFor(
        scope,
        requests,
        now,
        activeClinicName: active,
      ))
        request.id.value,
    ];

    test('to come: from now on, the soonest first; a confirmed one of the '
        'active clinic left out', () {
      expect(ids(AppointmentScope.upcoming, requests), [
        'now',
        'soon',
        'later',
      ]);
    });

    test('past: before now, the latest first', () {
      expect(ids(AppointmentScope.past, requests), ['recent', 'old', 'older']);
    });

    test("a confirmed request is kept unless it is the active clinic's "
        '(its name trimmed, case ignored), in the tab of its slot', () {
      final confirmed = [
        _request(
          'lyon',
          '2026-11-10T09:00:00+01:00',
          status: AppointmentRequestStatus.confirmed,
        ),
        _request(
          'paris',
          '2026-11-05T09:00:00+01:00',
          status: AppointmentRequestStatus.confirmed,
          clinicName: 'Clinique Vétérinaire de Paris',
        ),
      ];

      expect(
        ids(
          AppointmentScope.upcoming,
          confirmed,
          active: '  clinique vétérinaire de LYON ',
        ),
        isEmpty,
      );
      expect(ids(AppointmentScope.past, confirmed), ['paris']);
      // No active clinic known: every confirmed request is kept.
      expect(ids(AppointmentScope.upcoming, confirmed, active: null), ['lyon']);
      expect(ids(AppointmentScope.past, confirmed, active: null), ['paris']);
    });
  });

  test('an AppointmentRequest and its page', () {
    final request = AppointmentRequest(
      id: const AppointmentRequestId('r'),
      clinicName: 'Clinique',
      clinicCity: 'Lyon',
      petName: 'Capture',
      petSpecies: Species.cat,
      motifLabel: 'Consultation',
      startAt: ClinicInstant.parse('2026-11-12T14:00:00+01:00'),
      status: AppointmentRequestStatus.declined,
      declineReason: DeclineReason.expired,
      appointmentId: const AppointmentId('a'),
    );
    expect(
      '$request',
      'AppointmentRequest(r, 2026-11-12T14:00:00+01:00, '
          'AppointmentRequestStatus.declined)',
    );
    const page = AppointmentRequestPage();
    expect(page.items, isEmpty);
    expect(page.nextCursor, isNull);
  });

  test('a listing draft has no clinic; its new pet makes the request', () {
    var keys = 0;
    IdempotencyKey next() => IdempotencyKey('key-${++keys}');
    const motif = BookingMotif(
      id: MotifId('m'),
      label: 'Consultation',
      durationMin: 30,
    );
    const lemoine = Practitioner(id: PractitionerId('p'));
    final slot = ClinicInstant.parse('2026-11-12T14:00:00+01:00');
    final draft = BookingDraft.start(null, newKey: next)
        .withMotif(motif)
        .withPractitioner(lemoine)
        .withSlot(slot)
        .withPet(const NewPet('Capture', Species.cat));

    expect(draft.clinicId, isNull);
    expect(draft.request?.pet, const NewPet('Capture', Species.cat));
    // The same pet again: the same intent, the same key.
    expect(draft.withPet(const NewPet('Capture', Species.cat)).key, draft.key);
    expect(
      draft.withPet(const NewPet('Capturé', Species.cat)).key,
      isNot(draft.key),
    );
  });
}
