// The latest documents of the home: the tile of every kind (mockup 01),
// the meta line of an invoice and of another document (the home's pet
// names, an unknown id left out, the year when it is not this one).

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kiveto_mobile/features/home/domain/home_overview.dart';
import 'package:kiveto_mobile/features/home/presentation/latest_documents.dart';
import 'package:kiveto_mobile/l10n/app_localizations_fr.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/document_kind.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/domain/money.dart';
import 'package:kiveto_mobile/shared/domain/payment_status.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';

final _l10n = AppLocalizationsFr();
final _today = LocalDate(2026, 11, 3);

HomeDocument _document({
  DocumentKind kind = DocumentKind.report,
  List<String> petIds = const [],
  String issuedAt = '2026-11-02T03:24:29+01:00',
  HomeInvoice? invoice,
}) => HomeDocument(
  id: 'd',
  kind: kind,
  title: 'Document',
  issuedAt: ClinicInstant.parse(issuedAt),
  petIds: petIds,
  invoice: invoice,
);

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  test('homeDocumentTile: a colour set and a glyph or a text per kind', () {
    final tiles = {
      for (final kind in DocumentKind.values)
        kind: homeDocumentTile(_l10n, kind),
    };

    expect(
      [for (final tile in tiles.values) (tile.colors, tile.glyph, tile.text)],
      [
        (KivetoColorSets.indigo, LucideGlyph.fileText, null),
        (KivetoColorSets.orange, null, 'Rx'),
        (KivetoColorSets.green, null, '€'),
        (KivetoColorSets.neutral, null, 'Lab'),
        (KivetoColorSets.indigo, null, 'Cert'),
        (KivetoColorSets.neutral, LucideGlyph.fileText, null),
      ],
    );
    expect(tiles.values.map((tile) => tile.size), everyElement(36));
  });

  test('homeDocumentMeta: an invoice, its total and payment; none for an '
      'unknown payment', () {
    String meta(PaymentStatus status) => homeDocumentMeta(
      _l10n,
      _document(
        kind: DocumentKind.invoice,
        petIds: const ['pepito'],
        invoice: HomeInvoice(total: Money(9600, 'EUR'), paymentStatus: status),
      ),
      const {'pepito': 'Pepito'},
      _today,
    );

    expect(meta(PaymentStatus.unpaid), '96,00 € · Non payée');
    expect(meta(PaymentStatus.paid), '96,00 € · Payée');
    expect(meta(PaymentStatus.unknown), '96,00 €');
  });

  test('homeDocumentMeta: the pets of the home and the day; an unknown pet '
      'left out; the year of another year', () {
    const names = {'pepito': 'Pepito', 'oscar': 'Oscar'};

    expect(
      homeDocumentMeta(
        _l10n,
        _document(petIds: const ['pepito']),
        names,
        _today,
      ),
      'Pepito · 2 nov.',
    );
    expect(
      homeDocumentMeta(
        _l10n,
        _document(petIds: const ['oscar', 'gone', 'pepito']),
        names,
        _today,
      ),
      'Oscar et Pepito · 2 nov.',
    );
    expect(
      homeDocumentMeta(
        _l10n,
        _document(
          petIds: const ['gone'],
          issuedAt: '2025-12-22T11:30:00+01:00',
        ),
        names,
        _today,
      ),
      '22 déc. 2025',
    );
  });
}
