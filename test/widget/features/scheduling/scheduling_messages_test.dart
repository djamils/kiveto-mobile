// The French texts of scheduling: the status pills, the slots on the
// clinic's clock, the window's line, the practitioner, the motifs, the pet
// of a booking, the care warning by kind, the failure messages and their
// kinds; the questionnaire's chips, its date sent and its failures.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kiveto_mobile/features/patient/patient.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking.dart';
import 'package:kiveto_mobile/features/scheduling/domain/questionnaire.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_messages.dart';
import 'package:kiveto_mobile/l10n/app_localizations_fr.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/care_status.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/domain/species.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';

final _l10n = AppLocalizationsFr();
final _today = LocalDate(2026, 11, 3);

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  test('the status pills and their tones; none for an unknown status', () {
    expect(
      [
        for (final status in AppointmentStatus.values)
          appointmentStatusPill(_l10n, status),
      ],
      [
        ('Confirmé', StatusTone.success),
        ('En attente', StatusTone.neutral),
        ('Annulé', StatusTone.neutral),
        ('Annulé par la clinique', StatusTone.neutral),
        ('Refusé', StatusTone.neutral),
        ('Terminé', StatusTone.neutral),
        ('Non honoré', StatusTone.warning),
        null,
      ],
    );
  });

  test("slots and windows on the clinic's clock", () {
    final slot = ClinicInstant.parse('2026-11-09T10:00:00+01:00');
    expect(slotShort(_l10n, slot), 'Lun. 9 nov. à 10:00');
    expect(slotShort(_l10n, slot, capitalized: false), 'lun. 9 nov. à 10:00');
    expect(slotLong(_l10n, slot), 'Lundi 9 novembre à 10:00');
    expect(
      cancellableUntilLine(
        _l10n,
        ClinicInstant.parse('2026-11-08T10:00:00+01:00'),
      ),
      "Annulation en ligne possible jusqu'au dim. 8 nov. à 10:00.",
    );
  });

  test('a practitioner, a motif', () {
    expect(practitionerLabel(_l10n, ' Dr Marc Dupont '), 'Dr Marc Dupont');
    expect(practitionerLabel(_l10n, null), 'Vétérinaire');
    expect(practitionerLabel(_l10n, '  '), 'Vétérinaire');
    expect(
      motifWithDuration(_l10n, 'Consultation', 30),
      'Consultation · 30 min',
    );

    const motif = BookingMotif(
      id: MotifId('m'),
      label: 'Vaccination',
      durationMin: 20,
      description: 'Primo-vaccination ou rappel annuel.',
    );
    expect(
      motifMeta(_l10n, motif),
      '20 min · Primo-vaccination ou rappel annuel.',
    );
    expect(
      motifMeta(
        _l10n,
        const BookingMotif(
          id: MotifId('m'),
          label: 'Vaccination',
          durationMin: 20,
          description: 'Primo-vaccination ou rappel annuel.',
          suggested: true,
          suggestionReason: 'Rappel de vaccin à prévoir',
        ),
      ),
      '20 min · Rappel de vaccin à prévoir',
    );
    expect(
      motifMeta(
        _l10n,
        const BookingMotif(
          id: MotifId('m'),
          label: 'Vaccination',
          durationMin: 20,
          description: 'Primo-vaccination.',
          suggested: true,
        ),
      ),
      '20 min · Primo-vaccination.',
    );
    expect(
      motifMeta(
        _l10n,
        const BookingMotif(
          id: MotifId('m'),
          label: 'Autre',
          durationMin: 15,
          description: ' ',
        ),
      ),
      '15 min',
    );
  });

  test('the pet of a booking: species · breed · age', () {
    PetSummary pet({String? breed, LocalDate? birthDate}) => PetSummary(
      id: const PetId('p'),
      name: 'Oslo',
      species: Species.dog,
      breed: breed,
      birthDate: birthDate,
      initial: 'O',
    );

    expect(
      bookingPetLine(
        _l10n,
        pet(breed: 'Labrador', birthDate: LocalDate(2020, 3, 2)),
        _today,
      ),
      'Chien · Labrador · 6 ans',
    );
    expect(bookingPetLine(_l10n, pet(breed: ' '), _today), 'Chien');
  });

  test('the care warning by kind, its date in the year or not', () {
    RelatedCareItem item(String kind, LocalDate dueOn) => RelatedCareItem(
      kind: kind,
      label: 'CHPL',
      dueOn: dueOn,
      status: CareStatus.booked,
    );
    final nextYear = LocalDate(2027, 9, 5);

    expect(
      careWarning(_l10n, item('vaccination', nextYear), 'Oslo', _today),
      'Le rappel CHPL est à faire avant le 5 sept. 2027 pour Oslo. Reporter '
      'évite un retard de vaccination.',
    );
    expect(
      careWarning(
        _l10n,
        item('internal_parasite', LocalDate(2026, 12, 1)),
        'Oslo',
        _today,
      ),
      'Le traitement CHPL est à faire avant le 1 déc. pour Oslo. Reporter '
      'évite un retard de vermifugation.',
    );
    expect(
      careWarning(_l10n, item('external_parasite', nextYear), 'Oslo', _today),
      'Le traitement CHPL est à faire avant le 5 sept. 2027 pour Oslo. '
      'Reporter évite un retard de traitement antiparasitaire.',
    );
    expect(
      careWarning(_l10n, item('dental', nextYear), 'Oslo', _today),
      'Le soin CHPL est à faire avant le 5 sept. 2027 pour Oslo. Reporter '
      'évite un retard de soin.',
    );
  });

  test('the failure messages: the codes, the first violation, the shared '
      'message; through a provider too', () async {
    String message(Object error) => schedulingFailureMessage(_l10n, error);

    expect(
      message(const ConflictFailure(code: 'slot_taken')),
      "Ce créneau vient d'être pris. Choisissez-en un autre.",
    );
    expect(
      message(
        const ValidationFailure(
          code: 'validation_failed',
          violations: [
            Violation(propertyPath: 'newPet.name', message: 'Nom requis.'),
          ],
        ),
      ),
      'Nom requis.',
    );
    expect(
      message(const ValidationFailure(code: 'validation_failed')),
      'Certaines informations ne sont pas valides. Corrigez-les, puis '
      'réessayez.',
    );
    expect(
      message(const BusinessFailure(code: 'pet_not_bookable', statusCode: 422)),
      'Cet animal ne peut plus prendre rendez-vous en ligne.',
    );
    expect(
      message(const BusinessFailure(code: 'booking_not_open', statusCode: 422)),
      "La réservation en ligne n'est pas ouverte pour ce motif. Contactez la "
      'clinique.',
    );
    expect(
      message(
        const BusinessFailure(
          code: 'appointment_not_modifiable',
          statusCode: 422,
        ),
      ),
      'Ce rendez-vous ne peut plus être modifié.',
    );
    expect(
      message(
        const BusinessFailure(
          code: 'cancellation_window_closed',
          statusCode: 422,
        ),
      ),
      "Le délai d'annulation en ligne est dépassé\u00a0: contactez la "
      'clinique.',
    );
    expect(
      message(const NotFoundFailure(code: 'not_found')),
      "Ce choix n'est plus disponible. Recommencez la réservation.",
    );
    expect(
      message(
        const BusinessFailure(code: 'idempotency_key_reused', statusCode: 422),
      ),
      "Cette action n'a pas pu aboutir.",
    );
    // A failure that reached a provider through another one (wrapped).
    final source = FutureProvider<int>(
      (ref) => Future.error(const NetworkFailure()),
    );
    final dependent = FutureProvider<int>(
      (ref) => ref.watch(source.selectAsync((value) => value)),
    );
    final container = ProviderContainer(retry: (_, _) => null);
    addTearDown(container.dispose);
    final wrapped = await container
        .read(dependent.future)
        .then<Object>((_) => fail('no error'), onError: (Object e) => e);
    expect(wrapped, isNot(isA<NetworkFailure>()));
    expect(failureCause(wrapped), isA<NetworkFailure>());
    expect(
      message(wrapped),
      'Vérifiez votre connexion Internet, puis réessayez.',
    );
  });

  test('the kinds of failures: the pet to change, worth a retry', () {
    expect(
      isPetFailure(
        const BusinessFailure(code: 'pet_not_bookable', statusCode: 422),
      ),
      isTrue,
    );
    expect(
      isPetFailure(
        const ValidationFailure(
          violations: [
            Violation(propertyPath: 'newPet.name', message: 'Nom requis.'),
          ],
        ),
      ),
      isTrue,
    );
    expect(
      isPetFailure(
        const ValidationFailure(
          violations: [Violation(propertyPath: 'startAt', message: 'Passé.')],
        ),
      ),
      isFalse,
    );
    expect(isPetFailure(const NetworkFailure()), isFalse);
    expect(isTransientFailure(const NetworkFailure()), isTrue);
    expect(isTransientFailure(const ServerFailure(statusCode: 503)), isTrue);
    expect(isTransientFailure(const NotFoundFailure()), isFalse);
  });

  test('the questionnaire: its chips (none for an unknown value), the day '
      'its answers were sent, its failures', () async {
    await initializeDateFormatting('fr_FR');

    expect(
      [for (final symptom in Symptom.values) symptomLabel(_l10n, symptom)],
      [
        'Rien de particulier',
        'Toux',
        'Vomissements',
        'Diarrhée',
        'Baisse d’appétit',
        'Démangeaisons',
        'Boiterie',
        null,
      ],
    );
    expect(
      [
        for (final temperament in Temperament.values)
          temperamentLabel(_l10n, temperament),
      ],
      ['Calme', 'Stressé(e)', 'Peut mordre ou griffer', null],
    );
    expect(
      questionnaireSentAt(ClinicInstant.parse('2026-11-04T02:00:06+01:00')),
      ('mer.\u00a04\u00a0nov.', '02:00'),
    );
    expect(
      questionnaireFailureMessage(
        _l10n,
        const ValidationFailure(
          violations: [Violation(propertyPath: 'symptoms', message: 'Non.')],
        ),
      ),
      'Non.',
    );
    expect(
      questionnaireFailureMessage(_l10n, const NotFoundFailure()),
      "Ce rendez-vous a été annulé ou n'existe plus.",
    );
    expect(
      questionnaireFailureMessage(_l10n, const NetworkFailure()),
      'Vérifiez votre connexion Internet, puis réessayez.',
    );
  });
}
