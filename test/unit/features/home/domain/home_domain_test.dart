// The domain of home: an empty home by default, the next appointment, a
// pet, a care due date, a document and its invoice.

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/home/domain/home_overview.dart';
import 'package:kiveto_mobile/shared/domain/care_status.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/document_kind.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/domain/money.dart';
import 'package:kiveto_mobile/shared/domain/payment_status.dart';
import 'package:kiveto_mobile/shared/domain/species.dart';

void main() {
  test('an empty home: no appointment, no section', () {
    const home = HomeOverview();

    expect(home.nextAppointment, isNull);
    expect(home.pets, isEmpty);
    expect(home.careItems, isEmpty);
    expect(home.latestDocuments, isEmpty);
  });

  test('a full home', () {
    final startAt = ClinicInstant.parse('2026-11-11T10:30:00+01:00');
    final appointment = NextAppointment(
      id: 'a',
      startAt: startAt,
      motifLabel: 'Rendez-vous',
      status: AppointmentState.pendingClinicConfirmation,
      questionnaire: QuestionnaireState.notStarted,
      petName: 'Oslo',
      practitionerName: 'Dr Éric Rousseau',
    );
    final pet = HomePet(
      id: 'oslo',
      name: 'Oslo',
      initial: 'O',
      species: Species.dog,
      birthDate: LocalDate(2020, 3, 2),
    );
    final care = HomeCareItem(
      petName: 'Oslo',
      label: 'CHPL',
      dueOn: LocalDate(2027, 9, 5),
      status: CareStatus.upToDate,
      petId: 'oslo',
    );
    final invoice = HomeInvoice(
      total: Money(5200, 'EUR'),
      paymentStatus: PaymentStatus.paid,
    );
    final document = HomeDocument(
      id: 'd',
      kind: DocumentKind.invoice,
      title: 'Facture PAR-2026-000067',
      issuedAt: startAt,
      petIds: const ['oslo'],
      invoice: invoice,
    );
    final home = HomeOverview(
      nextAppointment: appointment,
      pets: [pet],
      careItems: [care],
      latestDocuments: [document],
    );

    expect(home.nextAppointment, same(appointment));
    expect(appointment.id, 'a');
    expect(appointment.startAt, startAt);
    expect(appointment.motifLabel, 'Rendez-vous');
    expect(appointment.status, AppointmentState.pendingClinicConfirmation);
    expect(appointment.questionnaire, QuestionnaireState.notStarted);
    expect(appointment.petName, 'Oslo');
    expect(appointment.practitionerName, 'Dr Éric Rousseau');
    expect(home.pets.single, same(pet));
    expect(pet.id, 'oslo');
    expect(pet.name, 'Oslo');
    expect(pet.initial, 'O');
    expect(pet.species, Species.dog);
    expect(pet.birthDate, LocalDate(2020, 3, 2));
    expect(home.careItems.single, same(care));
    expect(care.petId, 'oslo');
    expect(care.petName, 'Oslo');
    expect(care.label, 'CHPL');
    expect(care.dueOn, LocalDate(2027, 9, 5));
    expect(care.status, CareStatus.upToDate);
    expect(home.latestDocuments.single, same(document));
    expect(document.id, 'd');
    expect(document.kind, DocumentKind.invoice);
    expect(document.title, 'Facture PAR-2026-000067');
    expect(document.issuedAt, startAt);
    expect(document.petIds, ['oslo']);
    expect(document.invoice, same(invoice));
    expect(invoice.total, Money(5200, 'EUR'));
    expect(invoice.paymentStatus, PaymentStatus.paid);
  });

  test('the defaults of the optional parts', () {
    final date = ClinicInstant.parse('2026-11-05T09:00:00+01:00');
    final appointment = NextAppointment(
      id: 'a',
      startAt: date,
      motifLabel: 'Rendez-vous',
      status: AppointmentState.other,
      questionnaire: QuestionnaireState.unknown,
    );
    const pet = HomePet(
      id: 'p',
      name: 'Moka',
      initial: 'M',
      species: Species.unknown,
    );
    final care = HomeCareItem(
      petName: 'Moka',
      label: 'Rage',
      dueOn: LocalDate(2026, 11, 9),
      status: CareStatus.dueSoon,
    );
    final document = HomeDocument(
      id: 'd',
      kind: DocumentKind.report,
      title: 'Compte rendu',
      issuedAt: date,
    );

    expect(appointment.petName, isNull);
    expect(appointment.practitionerName, isNull);
    expect(pet.birthDate, isNull);
    expect(care.petId, isNull);
    expect(document.petIds, isEmpty);
    expect(document.invoice, isNull);
  });
}
