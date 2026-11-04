// The French texts of the pet sheet and the care items: today on the
// device, the species, sex and life labels, the pet's line, weights, ages,
// care dates and sub-lines, the countdown and the care pill rule; the
// fields and values of the change requests.

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kiveto_mobile/features/patient/domain/care_item.dart';
import 'package:kiveto_mobile/features/patient/domain/pet.dart';
import 'package:kiveto_mobile/features/patient/domain/pet_change.dart';
import 'package:kiveto_mobile/features/patient/presentation/pet_messages.dart';
import 'package:kiveto_mobile/l10n/app_localizations_fr.dart';
import 'package:kiveto_mobile/shared/domain/care_status.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/domain/species.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/fakes.dart';

final _l10n = AppLocalizationsFr();
final _today = LocalDate(2026, 11, 3);

PetSummary _pet({
  Species species = Species.dog,
  String? breed,
  Sex sex = Sex.unknown,
  Sterilization sterilization = Sterilization.unknown,
}) => PetSummary(
  id: const PetId('p'),
  name: 'Moka',
  species: species,
  initial: 'M',
  breed: breed,
  sex: sex,
  sterilization: sterilization,
);

CareItem _care(CareStatus status, LocalDate dueOn) => CareItem(
  kind: 'vaccination',
  label: 'Rage',
  lastDoneOn: LocalDate(2026, 5, 2),
  dueOn: dueOn,
  status: status,
);

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  test("deviceToday: the device's local date of the clock", () {
    final today = deviceToday(FixedClock(testNow));
    final local = testNow.toLocal();

    expect(today, LocalDate(local.year, local.month, local.day));
    expect(today, _today);
  });

  test('speciesLabel: none for an unknown species', () {
    expect(Species.values.map((s) => speciesLabel(_l10n, s)), [
      'Chien',
      'Chat',
      'NAC',
      'Autre',
      null,
    ]);
  });

  test('sexLabel: sex and sterilization, what is not known dropped', () {
    String? label(Sex sex, Sterilization sterilization) =>
        sexLabel(_l10n, sex, sterilization);

    expect(label(Sex.male, Sterilization.neutered), 'Mâle castré');
    expect(label(Sex.female, Sterilization.neutered), 'Femelle stérilisée');
    expect(label(Sex.male, Sterilization.intact), 'Mâle');
    expect(label(Sex.male, Sterilization.unknown), 'Mâle');
    expect(label(Sex.female, Sterilization.intact), 'Femelle');
    expect(label(Sex.female, Sterilization.unknown), 'Femelle');
    expect(label(Sex.unknown, Sterilization.neutered), 'Stérilisé');
    expect(label(Sex.unknown, Sterilization.intact), isNull);
    expect(label(Sex.unknown, Sterilization.unknown), isNull);
  });

  test('petLine: species · breed · sex; what is not known left out', () {
    expect(
      petLine(
        _l10n,
        _pet(
          breed: 'Labrador retriever',
          sex: Sex.male,
          sterilization: Sterilization.neutered,
        ),
      ),
      'Chien · Labrador retriever · Mâle castré',
    );
    expect(
      petLine(
        _l10n,
        _pet(
          species: Species.cat,
          breed: 'Européen',
          sex: Sex.female,
          sterilization: Sterilization.neutered,
        ),
      ),
      'Chat · Européen · Femelle stérilisée',
    );
    expect(petLine(_l10n, _pet(breed: 'Labrador')), 'Chien · Labrador');
    expect(petLine(_l10n, _pet(species: Species.unknown, breed: ' ')), '');
  });

  test('lifeStatusLabel: by sex; none for a pet alive', () {
    expect(lifeStatusLabel(_l10n, LifeStatus.deceased, Sex.male), 'Décédé');
    expect(lifeStatusLabel(_l10n, LifeStatus.deceased, Sex.unknown), 'Décédé');
    expect(lifeStatusLabel(_l10n, LifeStatus.deceased, Sex.female), 'Décédée');
    expect(lifeStatusLabel(_l10n, LifeStatus.missing, Sex.male), 'Disparu');
    expect(lifeStatusLabel(_l10n, LifeStatus.missing, Sex.female), 'Disparue');
    expect(lifeStatusLabel(_l10n, LifeStatus.alive, Sex.female), isNull);
    expect(lifeStatusLabel(_l10n, LifeStatus.unknown, Sex.male), isNull);
  });

  test('bornLabel and weightLabel', () {
    expect(bornLabel(_l10n, Sex.female), 'Née le');
    expect(bornLabel(_l10n, Sex.male), 'Né le');
    expect(bornLabel(_l10n, Sex.unknown), 'Né le');
    String weight(int grams) =>
        weightLabel(_l10n, PetWeight(grams: grams, at: _today));
    expect(weight(34900), '34,9 kg');
    expect(weight(4250), '4,25 kg');
    expect(weight(24300), '24,3 kg');
    expect(weight(5000), '5 kg');
    expect(weight(1234), '1,23 kg');
  });

  test('petAgeLabel: full years, else full months, else under a month', () {
    String? age(LocalDate? birthDate) => petAgeLabel(_l10n, birthDate, _today);

    expect(age(null), isNull);
    expect(age(LocalDate(2020, 3, 2)), '6 ans');
    expect(age(LocalDate(2015, 8, 2)), '11 ans');
    expect(age(LocalDate(2021, 11, 2)), '5 ans');
    expect(age(LocalDate(2021, 11, 4)), '4 ans');
    expect(age(LocalDate(2025, 11, 3)), '1 an');
    expect(age(LocalDate(2025, 11, 4)), '11 mois');
    expect(age(LocalDate(2026, 10, 3)), '1 mois');
    expect(age(LocalDate(2026, 10, 4)), "Moins d'un mois");
    expect(age(_today), "Moins d'un mois");
    // A birth date after today (a typing error at the clinic): no age.
    expect(age(LocalDate(2026, 11, 4)), isNull);
    expect(age(LocalDate(2027, 1, 1)), isNull);
  });

  test('petCardMeta: species · age, what is not known left out', () {
    expect(
      petCardMeta(_l10n, Species.dog, LocalDate(2020, 3, 2), _today),
      'Chien · 6 ans',
    );
    expect(petCardMeta(_l10n, Species.nac, null, _today), 'NAC');
    expect(
      petCardMeta(_l10n, Species.unknown, LocalDate(2024, 9, 2), _today),
      '2 ans',
    );
  });

  test("careDate: no year in today's year", () {
    expect(careDate(LocalDate(2026, 10, 13), _today), '13 oct.');
    expect(careDate(LocalDate(2027, 9, 5), _today), '5 sept. 2027');
    expect(careDate(LocalDate(2025, 12, 22), _today), '22 déc. 2025');
  });

  test('careSubLine: by status; up to date within 60 days reads as due', () {
    expect(
      careSubLine(
        _l10n,
        _care(CareStatus.overdue, LocalDate(2026, 10, 13)),
        _today,
      ),
      'À faire depuis le 13 oct.',
    );
    expect(
      careSubLine(
        _l10n,
        _care(CareStatus.dueSoon, LocalDate(2026, 11, 9)),
        _today,
      ),
      'Prochain avant le 9 nov.',
    );
    expect(
      careSubLine(
        _l10n,
        _care(CareStatus.upToDate, LocalDate(2027, 4, 16)),
        _today,
      ),
      "Valide jusqu'au 16 avr. 2027",
    );
    // The pill's threshold: 60 days still due (« Dans 8 sem. »), 61 valid.
    expect(
      careSubLine(
        _l10n,
        _care(CareStatus.upToDate, _today.addDays(60)),
        _today,
      ),
      'Prochain avant le 2 janv. 2027',
    );
    expect(
      careSubLine(
        _l10n,
        _care(CareStatus.upToDate, _today.addDays(61)),
        _today,
      ),
      "Valide jusqu'au 3 janv. 2027",
    );
    expect(
      careSubLine(
        _l10n,
        _care(CareStatus.unknown, LocalDate(2026, 11, 4)),
        _today,
      ),
      'Prochain avant le 4 nov.',
    );
    expect(
      careSubLine(
        _l10n,
        _care(CareStatus.booked, LocalDate(2026, 11, 4)),
        _today,
      ),
      'Fait le 2 mai · prochain avant le 4 nov.',
    );
  });

  test('careCountdown: today or past, tomorrow, days, full weeks', () {
    String countdown(int days) =>
        careCountdown(_l10n, _today.addDays(days), _today);

    expect(countdown(-3), "Aujourd'hui");
    expect(countdown(0), "Aujourd'hui");
    expect(countdown(1), 'Demain');
    expect(countdown(2), 'Dans 2 j');
    expect(countdown(6), 'Dans 6 j');
    expect(countdown(13), 'Dans 13 j');
    expect(countdown(14), 'Dans 2 sem.');
    expect(countdown(20), 'Dans 2 sem.');
    expect(countdown(21), 'Dans 3 sem.');
    expect(countdown(42), 'Dans 6 sem.');
  });

  test('careStatusPill: the rule of the matrix', () {
    (String, StatusTone)? pill(CareStatus status, int days) =>
        careStatusPill(_l10n, status, _today.addDays(days), _today);

    expect(pill(CareStatus.booked, 1), ('RDV pris', StatusTone.warning));
    expect(pill(CareStatus.overdue, -21), ('En retard', StatusTone.danger));
    expect(pill(CareStatus.dueSoon, 6), ('Dans 6 j', StatusTone.warning));
    expect(pill(CareStatus.dueSoon, 0), ("Aujourd'hui", StatusTone.warning));
    expect(pill(CareStatus.upToDate, 60), ('Dans 8 sem.', StatusTone.neutral));
    expect(pill(CareStatus.upToDate, 1), ('Demain', StatusTone.neutral));
    expect(pill(CareStatus.upToDate, 61), ('À jour', StatusTone.success));
    expect(pill(CareStatus.upToDate, 306), ('À jour', StatusTone.success));
    expect(pill(CareStatus.unknown, 6), isNull);
  });

  testWidgets('CareStatusPill: the pill, or nothing', (tester) async {
    await pumpKit(
      tester,
      Column(
        children: [
          CareStatusPill(
            status: CareStatus.overdue,
            dueOn: LocalDate(2026, 10, 13),
            today: _today,
          ),
          CareStatusPill(
            status: CareStatus.unknown,
            dueOn: LocalDate(2026, 10, 13),
            today: _today,
          ),
        ],
      ),
    );

    expect(find.byType(StatusPill), findsOneWidget);
    expect(
      tester.widget<StatusPill>(find.byType(StatusPill)).tone,
      StatusTone.danger,
    );
    expect(find.text('En retard'), findsOneWidget);
  });

  test('the change requests: the field labels, the sterilization by sex, '
      'the values', () {
    expect(
      [
        for (final field in PetChangeField.values)
          petChangeFieldLabel(_l10n, field),
      ],
      ['Nom', 'Poids', 'Stérilisation', 'Puce', 'Autre', 'Autre'],
    );
    expect(
      [
        for (final sex in Sex.values)
          for (final state in Sterilization.values)
            sterilizationChoiceLabel(_l10n, state, sex),
      ],
      [
        'Non castré',
        'Castré',
        '—',
        'Non stérilisée',
        'Stérilisée',
        '—',
        'Non stérilisé(e)',
        'Stérilisé(e)',
        '—',
      ],
    );
    expect(
      petChangeValueLabel(_l10n, PetChangeField.weight, '12,4', Sex.male),
      '12,4\u00a0kg',
    );
    expect(
      petChangeValueLabel(
        _l10n,
        PetChangeField.sterilization,
        'neutered',
        Sex.female,
      ),
      'Stérilisée',
    );
    expect(
      petChangeValueLabel(_l10n, PetChangeField.sterilization, 'x', Sex.male),
      'x',
    );
    for (final field in [
      PetChangeField.name,
      PetChangeField.chipNumber,
      PetChangeField.other,
      PetChangeField.unknown,
    ]) {
      expect(petChangeValueLabel(_l10n, field, 'Oslo', Sex.male), 'Oslo');
    }
  });
}
