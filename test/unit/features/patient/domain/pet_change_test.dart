// The change request of a pet: its draft compares by content (one
// Idempotency-Key per content), the sterilization values the clinic takes,
// a request pending until the clinic answers.

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/patient/domain/pet.dart';
import 'package:kiveto_mobile/features/patient/domain/pet_change.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';

void main() {
  test('a draft equals another with the same field, value, day and note', () {
    final draft = PetChangeDraft(
      field: PetChangeField.weight,
      proposedValue: '12,4',
      measuredOn: LocalDate(2026, 11, 2),
      note: 'Pesé à la maison',
    );
    final same = PetChangeDraft(
      field: PetChangeField.weight,
      proposedValue: ['12', '4'].join(','),
      measuredOn: LocalDate(2026, 11, 2),
      note: 'Pesé à la maison',
    );

    expect(draft, same);
    expect(draft.hashCode, same.hashCode);
    for (final other in [
      PetChangeDraft(
        field: PetChangeField.other,
        proposedValue: '12,4',
        measuredOn: LocalDate(2026, 11, 2),
        note: 'Pesé à la maison',
      ),
      PetChangeDraft(
        field: PetChangeField.weight,
        proposedValue: '12,5',
        measuredOn: LocalDate(2026, 11, 2),
        note: 'Pesé à la maison',
      ),
      const PetChangeDraft(
        field: PetChangeField.weight,
        proposedValue: '12,4',
        note: 'Pesé à la maison',
      ),
      PetChangeDraft(
        field: PetChangeField.weight,
        proposedValue: '12,4',
        measuredOn: LocalDate(2026, 11, 2),
      ),
    ]) {
      expect(draft, isNot(other));
    }
    expect(draft == Object(), isFalse);
  });

  test('the sterilization values the clinic takes: neutered and intact', () {
    expect(sterilizationValues, {
      Sterilization.neutered: 'neutered',
      Sterilization.intact: 'intact',
    });
  });

  test('a request is pending until the clinic answers', () {
    PetChangeRequest request(PortalRequestStatus status) => PetChangeRequest(
      id: 'r-1',
      petId: const PetId('p-1'),
      field: PetChangeField.weight,
      status: status,
      submittedAt: ClinicInstant.parse('2026-11-02T03:24:30+01:00'),
      proposedValue: '25,1',
    );

    expect(request(PortalRequestStatus.submitted).isPending, isTrue);
    for (final status in [
      PortalRequestStatus.done,
      PortalRequestStatus.rejected,
      PortalRequestStatus.closed,
      PortalRequestStatus.unknown,
    ]) {
      expect(request(status).isPending, isFalse, reason: '$status');
    }
    final pending = request(PortalRequestStatus.submitted);
    expect(pending.id, 'r-1');
    expect(pending.petId, const PetId('p-1'));
    expect(pending.proposedValue, '25,1');
  });
}
