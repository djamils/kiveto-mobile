import 'package:intl/intl.dart';
import 'package:kiveto_mobile/features/patient/domain/care_item.dart';
import 'package:kiveto_mobile/features/patient/domain/pet.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/care_status.dart';
import 'package:kiveto_mobile/shared/domain/clock.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/domain/species.dart';
import 'package:kiveto_mobile/shared/presentation/formatters/kiveto_format.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:material_ui/material_ui.dart';

// The French texts of the pet sheet and of the care items (shared with the
// home): the server sends codes and dates, the labels and the tone of a
// pill are the app's. Which status a care item has is the server's answer.

/// Today on the device: the local date of [clock]'s instant (countdowns,
/// ages, whether a date shows its year).
LocalDate deviceToday(Clock clock) {
  final now = clock.now().toLocal();
  return LocalDate(now.year, now.month, now.day);
}

/// « Chien », « Chat », « NAC », « Autre »; none for a species this app
/// does not know.
String? speciesLabel(AppLocalizations l10n, Species species) =>
    switch (species) {
      Species.dog => l10n.petSpeciesDog,
      Species.cat => l10n.petSpeciesCat,
      Species.nac => l10n.petSpeciesNac,
      Species.other => l10n.petSpeciesOther,
      Species.unknown => null,
    };

/// « Mâle castré », « Femelle stérilisée », « Mâle », « Femelle », or
/// « Stérilisé » when only the sterilization is known; none when nothing
/// is.
String? sexLabel(AppLocalizations l10n, Sex sex, Sterilization sterilization) =>
    switch ((sex, sterilization)) {
      (Sex.male, Sterilization.neutered) => l10n.petSexMaleNeutered,
      (Sex.female, Sterilization.neutered) => l10n.petSexFemaleNeutered,
      (Sex.male, _) => l10n.petSexMale,
      (Sex.female, _) => l10n.petSexFemale,
      (Sex.unknown, Sterilization.neutered) => l10n.petSexUnknownNeutered,
      (Sex.unknown, _) => null,
    };

/// The line under a pet's name: species · breed · sex (« Chien · Labrador
/// retriever · Mâle castré »), what is not known left out.
String petLine(AppLocalizations l10n, PetSummary pet) => [
  ?speciesLabel(l10n, pet.species),
  if (pet.breed?.trim() case final String breed when breed.isNotEmpty) breed,
  ?sexLabel(l10n, pet.sex, pet.sterilization),
].join(' · ');

/// The pill of a pet no longer followed (« Décédé », « Disparue »…); none
/// for a pet alive.
String? lifeStatusLabel(AppLocalizations l10n, LifeStatus status, Sex sex) {
  final female = sex == Sex.female;
  return switch (status) {
    LifeStatus.deceased =>
      female ? l10n.petDeceasedFemale : l10n.petDeceasedMale,
    LifeStatus.missing => female ? l10n.petMissingFemale : l10n.petMissingMale,
    LifeStatus.alive || LifeStatus.unknown => null,
  };
}

/// The label of a birth date: « Née le » for a female, « Né le »
/// otherwise.
String bornLabel(AppLocalizations l10n, Sex sex) =>
    sex == Sex.female ? l10n.petBornFemale : l10n.petBornMale;

/// A weight in kilograms: « 34,9 kg », « 4,25 kg ».
String weightLabel(AppLocalizations l10n, PetWeight weight) =>
    l10n.petWeightValue(
      NumberFormat('#,##0.##', 'fr_FR').format(weight.grams / 1000),
    );

/// A pet's age on [today]: « 6 ans », « 4 mois », « Moins d'un mois »;
/// none without a birth date, or for one after [today].
String? petAgeLabel(
  AppLocalizations l10n,
  LocalDate? birthDate,
  LocalDate today,
) {
  if (birthDate == null || today.isBefore(birthDate)) return null;
  var months =
      (today.year - birthDate.year) * 12 + today.month - birthDate.month;
  if (today.day < birthDate.day) months--;
  if (months >= 12) return l10n.petAgeYears(months ~/ 12);
  if (months >= 1) return l10n.petAgeMonths(months);
  return l10n.petAgeUnderOneMonth;
}

/// The meta line of a pet card: species · age (« Chien · 6 ans »).
String petCardMeta(
  AppLocalizations l10n,
  Species species,
  LocalDate? birthDate,
  LocalDate today,
) => [
  ?speciesLabel(l10n, species),
  ?petAgeLabel(l10n, birthDate, today),
].join(' · ');

/// A date of a care item or a weighing: « 13 oct. » in [today]'s year,
/// « 16 avr. 2027 » otherwise.
String careDate(LocalDate date, LocalDate today) => date.year == today.year
    ? KivetoFormat.dayMonth(date)
    : KivetoFormat.dayMonthYear(date);

/// The line under a care item's label, by its status: « À faire depuis le
/// 13 oct. » (overdue), the last act and the due date (booked), « Valide
/// jusqu'au 16 avr. 2027 » (up to date, due beyond 60 days, as its pill),
/// « Prochain avant le 9 nov. » otherwise.
String careSubLine(AppLocalizations l10n, CareItem item, LocalDate today) {
  final due = careDate(item.dueOn, today);
  return switch (item.status) {
    CareStatus.overdue => l10n.careOverdueSince(due),
    CareStatus.booked => l10n.careDoneAndDue(
      careDate(item.lastDoneOn, today),
      due,
    ),
    CareStatus.upToDate when today.daysUntil(item.dueOn) > 60 =>
      l10n.careValidUntil(due),
    CareStatus.dueSoon ||
    CareStatus.upToDate ||
    CareStatus.unknown => l10n.careDueBefore(due),
  };
}

/// The time left until [dueOn]: « Aujourd'hui » (or past), « Demain »,
/// « Dans 6 j », « Dans 3 sem. ».
String careCountdown(AppLocalizations l10n, LocalDate dueOn, LocalDate today) {
  final days = today.daysUntil(dueOn);
  if (days <= 0) return l10n.careToday;
  if (days == 1) return l10n.careTomorrow;
  if (days < 14) return l10n.careInDays(days);
  return l10n.careInWeeks(days ~/ 7);
}

/// The pill of a care item: « RDV pris » (amber), « En retard » (danger),
/// the countdown of a care due soon (amber), of an up-to-date care due
/// within 60 days (neutral), « À jour » beyond (green); none for a status
/// this app does not know.
(String label, StatusTone tone)? careStatusPill(
  AppLocalizations l10n,
  CareStatus status,
  LocalDate dueOn,
  LocalDate today,
) => switch (status) {
  CareStatus.booked => (l10n.careBooked, StatusTone.warning),
  CareStatus.overdue => (l10n.careOverdue, StatusTone.danger),
  CareStatus.dueSoon => (careCountdown(l10n, dueOn, today), StatusTone.warning),
  CareStatus.upToDate when today.daysUntil(dueOn) <= 60 => (
    careCountdown(l10n, dueOn, today),
    StatusTone.neutral,
  ),
  CareStatus.upToDate => (l10n.careUpToDate, StatusTone.success),
  CareStatus.unknown => null,
};

/// The pill of a care item ([careStatusPill]); nothing for an unknown
/// status.
class CareStatusPill extends StatelessWidget {
  const new({
    required this.status,
    required this.dueOn,
    required this.today,
    super.key,
  });

  final CareStatus status;
  final LocalDate dueOn;
  final LocalDate today;

  @override
  Widget build(BuildContext context) => switch (careStatusPill(
    AppLocalizations.of(context),
    status,
    dueOn,
    today,
  )) {
    (final label, final tone) => StatusPill(label, tone: tone),
    null => const SizedBox.shrink(),
  };
}
