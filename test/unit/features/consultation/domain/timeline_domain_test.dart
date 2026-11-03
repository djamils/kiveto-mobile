// The domain of consultation: a visit, its documents, a page and their
// defaults.

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/consultation/domain/timeline.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/document_kind.dart';

void main() {
  final date = ClinicInstant.parse('2026-08-31T11:30:00+02:00');

  test('a visit and its documents', () {
    const document = TimelineDocument(id: 'd', kind: DocumentKind.report);
    final entry = TimelineEntry(
      visitId: 'v',
      date: date,
      title: 'Boiterie',
      vet: 'Dr Éric Rousseau',
      documents: [document],
    );

    expect(entry.visitId, 'v');
    expect(entry.date, date);
    expect(entry.title, 'Boiterie');
    expect(entry.vet, 'Dr Éric Rousseau');
    expect(entry.documents.single, same(document));
    expect(document.id, 'd');
    expect(document.kind, DocumentKind.report);
  });

  test('the defaults: no vet, no document; an empty last page', () {
    final entry = TimelineEntry(visitId: 'v', date: date, title: 'Bilan');
    final page = TimelinePage(items: [entry], nextCursor: 'next');

    expect(entry.vet, isNull);
    expect(entry.documents, isEmpty);
    expect(page.items.single, same(entry));
    expect(page.nextCursor, 'next');
    expect(const TimelinePage().items, isEmpty);
    expect(const TimelinePage().nextCursor, isNull);
  });
}
