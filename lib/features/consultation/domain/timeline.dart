import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/document_kind.dart';

/// A visit of a pet whose report the clinic shared with the owner.
final class TimelineEntry {
  const new({
    required this.visitId,
    required this.date,
    required this.title,
    this.vet,
    this.documents = const [],
  });

  final String visitId;

  /// The start of the consultation, with the clinic's offset.
  final ClinicInstant date;

  /// The vet's name as it was when the report was shared.
  final String? vet;

  /// As the clinic named the visit (`Bilan thyroïdien`).
  final String title;

  /// The documents of the visit the owner may open.
  final List<TimelineDocument> documents;
}

/// A document of a visit: its id (the documents' id) and its kind.
final class TimelineDocument {
  const new({required this.id, required this.kind});

  final String id;
  final DocumentKind kind;
}

/// One page of a pet's visits, newest first; [nextCursor] reads the next
/// one (null on the last page).
final class TimelinePage {
  const new({this.items = const [], this.nextCursor});

  final List<TimelineEntry> items;
  final String? nextCursor;
}
