import 'package:kiveto_mobile/shared/domain/care_status.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/document_kind.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/domain/money.dart';
import 'package:kiveto_mobile/shared/domain/payment_status.dart';
import 'package:kiveto_mobile/shared/domain/species.dart';

/// The home of the owner in a clinic (`GET /clinics/{c}/home`), as the
/// server composes it: the next appointment, the pets alive, the closest
/// care due dates, the latest documents. An empty section is an empty
/// list (no appointment: null).
final class HomeOverview {
  const new({
    this.nextAppointment,
    this.pets = const [],
    this.careItems = const [],
    this.latestDocuments = const [],
  });

  final NextAppointment? nextAppointment;
  final List<HomePet> pets;
  final List<HomeCareItem> careItems;
  final List<HomeDocument> latestDocuments;
}

/// Where the next appointment stands, as far as the home shows it; [other]
/// for any other status (the server picks which appointment is next).
enum AppointmentState { confirmed, pendingClinicConfirmation, other }

/// Whether the owner filled the questionnaire before the visit; [unknown]
/// for a status this app does not know yet.
enum QuestionnaireState { notStarted, submitted, unknown }

/// The next appointment of the owner in the clinic.
final class NextAppointment {
  const new({
    required this.id,
    required this.startAt,
    required this.motifLabel,
    required this.status,
    required this.questionnaire,
    this.petName,
    this.practitionerName,
  });

  final String id;
  final ClinicInstant startAt;

  /// Null when the appointment is not about one pet.
  final String? petName;
  final String motifLabel;
  final String? practitionerName;
  final AppointmentState status;
  final QuestionnaireState questionnaire;
}

/// A pet of the home (alive: the server leaves the others out).
final class HomePet {
  const new({
    required this.id,
    required this.name,
    required this.initial,
    required this.species,
    this.birthDate,
  });

  final String id;
  final String name;

  /// The letter of its avatar, chosen by the server.
  final String initial;
  final Species species;
  final LocalDate? birthDate;
}

/// A care due date of the home; its [status] is the server's.
final class HomeCareItem {
  const new({
    required this.petName,
    required this.label,
    required this.dueOn,
    required this.status,
    this.petId,
  });

  /// Null for a pet without an id in the answer.
  final String? petId;
  final String petName;
  final String label;
  final LocalDate dueOn;
  final CareStatus status;
}

/// One of the latest documents of the home.
final class HomeDocument {
  const new({
    required this.id,
    required this.kind,
    required this.title,
    required this.issuedAt,
    this.petIds = const [],
    this.invoice,
  });

  final String id;
  final DocumentKind kind;

  /// As the clinic named it (`Facture PAR-2026-000067`).
  final String title;

  /// The pets it is about; empty for some invoices.
  final List<String> petIds;
  final ClinicInstant issuedAt;

  /// The amount and payment of an invoice.
  final HomeInvoice? invoice;
}

/// The invoice part of a home document.
final class HomeInvoice {
  const new({required this.total, required this.paymentStatus});

  final Money total;
  final PaymentStatus paymentStatus;
}
