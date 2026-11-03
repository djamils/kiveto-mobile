// The scheduling domain: the appointment's window and its reschedule
// rule, the booking values, and the booking draft's key rule (same content,
// same key; any change of the clinic, the pet, the motif, the practitioner
// or the slot, a new key) with its downstream resets.

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking_draft.dart';
import 'package:kiveto_mobile/shared/domain/care_status.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/idempotency_key.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/domain/species.dart';

const _paris = ClinicId('paris');
const _lyon = ClinicId('lyon');
final _nine = ClinicInstant.parse('2026-11-09T09:00:00+01:00');
final _ten = ClinicInstant.parse('2026-11-09T10:00:00+01:00');
const _consult = BookingMotif(
  id: MotifId('consult'),
  label: 'Consultation',
  durationMin: 30,
);
const _vacc = BookingMotif(
  id: MotifId('vacc'),
  label: 'Vaccination',
  durationMin: 20,
);
const _dupont = Practitioner(
  id: PractitionerId('dupont'),
  displayName: 'Dr Marc Dupont',
);
const _rousseau = Practitioner(id: PractitionerId('rousseau'));

/// Numbered keys: `key-1`, `key-2`…
final class _Keys {
  var _count = 0;

  IdempotencyKey next() => IdempotencyKey('key-${++_count}');
}

Appointment _appointment({
  AppointmentSource source = AppointmentSource.portal,
  MotifId? motifId = const MotifId('consult'),
  ClinicInstant? cancellableUntil,
  AppointmentStatus status = AppointmentStatus.confirmed,
}) => Appointment(
  id: const AppointmentId('a'),
  startAt: _ten,
  endAt: ClinicInstant.parse('2026-11-09T10:30:00+01:00'),
  motifId: motifId,
  motifLabel: 'Consultation',
  practitionerId: const PractitionerId('dupont'),
  status: status,
  source: source,
  questionnaire: QuestionnaireStatus.notStarted,
  cancellableUntil: cancellableUntil,
);

void main() {
  group('Appointment', () {
    final until = ClinicInstant.parse('2026-11-08T10:00:00+01:00');
    final before = DateTime.utc(2026, 11, 8, 8, 59);
    final at = DateTime.utc(2026, 11, 8, 9);

    test('its length, its status, its fields', () {
      final appointment = _appointment(cancellableUntil: until);

      expect(appointment.durationMinutes, 30);
      expect(appointment.isPending, isFalse);
      expect(appointment.isActive, isTrue);
      expect(appointment.petId, isNull);
      expect(appointment.petName, isNull);
      expect(appointment.practitionerName, isNull);
      expect(appointment.relatedCareItem, isNull);
      expect('$appointment', contains('Appointment(a, 2026-11-09T10:00'));
      expect(
        _appointment(status: AppointmentStatus.pendingClinicConfirmation)
            .isPending,
        isTrue,
      );
      expect(
        _appointment(status: AppointmentStatus.pendingClinicConfirmation)
            .isActive,
        isTrue,
      );
      for (final status in [
        AppointmentStatus.cancelledByClient,
        AppointmentStatus.cancelledByClinic,
        AppointmentStatus.declined,
        AppointmentStatus.completed,
        AppointmentStatus.noShow,
        AppointmentStatus.unknown,
      ]) {
        expect(
          _appointment(status: status).isActive,
          isFalse,
          reason: '$status',
        );
      }
    });

    test('modifiable before cancellableUntil only, never without it', () {
      final appointment = _appointment(cancellableUntil: until);

      expect(appointment.isModifiableAt(before), isTrue);
      expect(appointment.isModifiableAt(at), isFalse);
      expect(_appointment().isModifiableAt(before), isFalse);
    });

    test('reschedulable: a portal booking with a motif, in the window', () {
      expect(
        _appointment(cancellableUntil: until).isReschedulableAt(before),
        isTrue,
      );
      expect(
        _appointment(cancellableUntil: until).isReschedulableAt(at),
        isFalse,
      );
      expect(
        _appointment(
          cancellableUntil: until,
          source: AppointmentSource.clinic,
        ).isReschedulableAt(before),
        isFalse,
      );
      expect(
        _appointment(
          cancellableUntil: until,
          source: AppointmentSource.unknown,
        ).isReschedulableAt(before),
        isFalse,
      );
      expect(
        _appointment(
          cancellableUntil: until,
          motifId: null,
        ).isReschedulableAt(before),
        isFalse,
      );
    });

    test('a related care item, a page', () {
      final item = RelatedCareItem(
        kind: 'vaccination',
        label: 'CHPL',
        dueOn: LocalDate(2027, 9, 5),
        status: CareStatus.booked,
      );
      expect(item.kind, 'vaccination');
      expect(item.label, 'CHPL');
      expect(item.dueOn, LocalDate(2027, 9, 5));
      expect(item.status, CareStatus.booked);

      const empty = AppointmentPage();
      expect(empty.items, isEmpty);
      expect(empty.nextCursor, isNull);
      final page = AppointmentPage(items: [_appointment()], nextCursor: 'c');
      expect(page.items, hasLength(1));
      expect(page.nextCursor, 'c');
    });

    test('the enums of the contract', () {
      expect(AppointmentStatus.values, hasLength(8));
      expect(AppointmentSource.values, hasLength(3));
      expect(QuestionnaireStatus.values, hasLength(3));
      expect(CancellationReason.values, [
        CancellationReason.unavailable,
        CancellationReason.noLongerNeeded,
        CancellationReason.seenElsewhere,
        CancellationReason.other,
      ]);
      expect(AppointmentScope.values, [
        AppointmentScope.upcoming,
        AppointmentScope.past,
      ]);
    });
  });

  group('booking values', () {
    test('a motif, a practitioner, a day', () {
      expect(_consult.description, isNull);
      expect(_consult.suggested, isFalse);
      expect(_consult.suggestionReason, isNull);
      expect('$_consult', 'BookingMotif(consult, Consultation)');
      expect(_rousseau.displayName, isNull);
      expect('$_dupont', 'Practitioner(dupont)');
      final day = AvailabilityDay(date: LocalDate(2026, 11, 8), open: false);
      expect(day.slots, isEmpty);
      expect(day.open, isFalse);
    });

    test('pets compare by content', () {
      const oslo = ExistingPet('oslo', 'Oslo');
      expect(oslo, const ExistingPet('oslo', 'Oslo'));
      expect(oslo.hashCode, const ExistingPet('oslo', 'Oslo').hashCode);
      expect(oslo, isNot(const ExistingPet('pixel', 'Oslo')));
      expect(oslo.name, 'Oslo');
      expect('$oslo', 'ExistingPet(oslo)');

      const plume = NewPet('Plume', Species.cat);
      expect(plume, const NewPet('Plume', Species.cat));
      expect(plume.hashCode, const NewPet('Plume', Species.cat).hashCode);
      expect(plume, isNot(const NewPet('Plume', Species.dog)));
      expect(plume, isNot(const NewPet('Plumette', Species.cat)));
      expect(plume, isNot(oslo));
      expect('$plume', 'NewPet(Plume, Species.cat)');
      const BookingPet pet = plume;
      expect(pet.name, 'Plume');
    });
  });

  group('BookingDraft', () {
    late _Keys keys;
    late BookingDraft draft;

    setUp(() {
      keys = _Keys();
      draft = BookingDraft.start(_paris, newKey: keys.next)
          .withPet(const ExistingPet('oslo', 'Oslo'))
          .withMotif(_consult)
          .withPractitioner(_dupont)
          .withSlot(_nine);
    });

    test('the golden example: same content, same key; a new slot, a new '
        'key; a new motif clears the choices after it', () {
      expect(draft.withSlot(_nine).key, draft.key);
      expect(draft.withSlot(_ten).key, isNot(draft.key));
      expect(draft.withMotif(_vacc).practitioner, isNull);
    });

    test('an empty draft: its first key, no request', () {
      final empty = BookingDraft.start(_paris, newKey: keys.next);

      expect(empty.clinicId, _paris);
      expect(empty.key, const IdempotencyKey('key-6'));
      expect(empty.pet, isNull);
      expect(empty.motif, isNull);
      expect(empty.practitioner, isNull);
      expect(empty.slot, isNull);
      expect(empty.takenSlots, isEmpty);
      expect(empty.request, isNull);
    });

    test('by default, a UUID v4 key per intent', () {
      final first = BookingDraft.start(null);
      final second = first.withPet(const ExistingPet('oslo', 'Oslo'));

      expect(first.clinicId, isNull);
      expect(
        first.key.value,
        matches(RegExp('^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-')),
      );
      expect(second.key, isNot(first.key));
    });

    test('complete: the request, the slot as chosen', () {
      final request = draft.request!;

      expect(request.pet, const ExistingPet('oslo', 'Oslo'));
      expect(request.motifId, const MotifId('consult'));
      expect(request.practitionerId, const PractitionerId('dupont'));
      expect(request.startAt, _nine);
      expect(draft.withSlot(null).request, isNull);
      expect(draft.withPractitioner(null).request, isNull);
      expect(draft.withMotif(null).request, isNull);
      expect(draft.withPet(null).request, isNull);
    });

    test('the clinic: the same keeps everything, another starts over', () {
      expect(draft.withClinic(_paris), same(draft));

      final lyon = draft.withClinic(_lyon);
      expect(lyon.clinicId, _lyon);
      expect(lyon.pet, isNull);
      expect(lyon.motif, isNull);
      expect(lyon.practitioner, isNull);
      expect(lyon.slot, isNull);
      expect(lyon.key, isNot(draft.key));
    });

    test("the pet: the same keeps the key; another (or the new pet's name "
        'or species) makes a new key and keeps the other choices', () {
      expect(draft.withPet(const ExistingPet('oslo', 'Oslo')), same(draft));

      final plume = draft.withPet(const NewPet('Plume', Species.cat));
      expect(plume.key, isNot(draft.key));
      expect(plume.pet, const NewPet('Plume', Species.cat));
      expect(plume.motif, _consult);
      expect(plume.practitioner, _dupont);
      expect(plume.slot, _nine);
      expect(plume.withPet(const NewPet('Plume', Species.cat)).key, plume.key);
      expect(
        plume.withPet(const NewPet('Plume', Species.dog)).key,
        isNot(plume.key),
      );
      expect(
        plume.withPet(const NewPet('Plumette', Species.cat)).key,
        isNot(plume.key),
      );
    });

    test('the motif: the same id keeps everything; another clears the '
        'practitioner, the slot and the taken slots', () {
      const sameId = BookingMotif(
        id: MotifId('consult'),
        label: 'Consultation',
        durationMin: 30,
        suggested: true,
      );
      expect(draft.withMotif(sameId), same(draft));

      final vacc = draft.markTaken(_ten).withMotif(_vacc);
      expect(vacc.motif, _vacc);
      expect(vacc.pet, const ExistingPet('oslo', 'Oslo'));
      expect(vacc.practitioner, isNull);
      expect(vacc.slot, isNull);
      expect(vacc.takenSlots, isEmpty);
      expect(vacc.key, isNot(draft.key));
    });

    test('the practitioner: the same keeps everything; another clears the '
        'slot and the taken slots', () {
      expect(draft.withPractitioner(_dupont), same(draft));

      final rousseau = draft.markTaken(_ten).withPractitioner(_rousseau);
      expect(rousseau.practitioner, _rousseau);
      expect(rousseau.motif, _consult);
      expect(rousseau.slot, isNull);
      expect(rousseau.takenSlots, isEmpty);
      expect(rousseau.key, isNot(draft.key));
    });

    test('the slot: another keeps the taken slots', () {
      final taken = draft.markTaken(_ten);

      final ten = taken.withSlot(
        ClinicInstant.parse('2026-11-09T11:00:00+01:00'),
      );
      expect(ten.isTaken(_ten), isTrue);
      expect(ten.practitioner, _dupont);
    });

    test('a taken slot: cleared if chosen, kept once, compared by instant', () {
      final taken = draft.markTaken(_nine);

      expect(taken.slot, isNull);
      expect(taken.key, draft.key);
      expect(taken.request, isNull);
      expect(taken.takenSlots, {_nine});
      // The same moment with another offset.
      expect(
        taken.isTaken(ClinicInstant.parse('2026-11-09T08:00:00Z')),
        isTrue,
      );
      expect(taken.isTaken(_ten), isFalse);
      expect(taken.markTaken(_nine).takenSlots, hasLength(1));
      expect(taken.withSlot(_ten).key, isNot(draft.key));

      final other = draft.markTaken(_ten);
      expect(other.slot, _nine);
      expect(other.takenSlots, {_ten});
      expect(other.request, isNotNull);
      expect(other.pet, draft.pet);
      expect(other.motif, draft.motif);
      expect(other.clinicId, _paris);

      final none = BookingDraft.start(
        _paris,
        newKey: keys.next,
      ).markTaken(_nine);
      expect(none.slot, isNull);
      expect(none.isTaken(_nine), isTrue);
    });
  });
}
