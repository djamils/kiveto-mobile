// The French texts of screen 5: the pet names, the meta line of each kind,
// the payment labels, the tiles, the filters and their empty titles, the
// renewal control decided from the server's answer only.

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kiveto_mobile/features/document/domain/document.dart';
import 'package:kiveto_mobile/features/document/presentation/document_messages.dart';
import 'package:kiveto_mobile/l10n/app_localizations_fr.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/domain/money.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';

final _l10n = AppLocalizationsFr();

Document _document({
  DocumentKind kind = DocumentKind.report,
  List<String> petIds = const [],
  InvoiceSummary? invoice,
  PrescriptionSummary? prescription,
}) => Document(
  id: const DocumentId('d'),
  kind: kind,
  title: 'Document',
  issuedAt: ClinicInstant.parse('2026-08-31T23:30:00+02:00'),
  petIds: petIds,
  invoice: invoice,
  prescription: prescription,
);

PrescriptionSummary _summary({bool renewable = true, RenewalStatus? status}) =>
    PrescriptionSummary(
      id: const PrescriptionId('p'),
      renewable: renewable,
      renewal: status == null ? null : RenewalRequest(status: status),
    );

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  test('joinPetNames: none, one, two, three', () {
    expect(joinPetNames(_l10n, []), '');
    expect(joinPetNames(_l10n, ['Moka']), 'Moka');
    expect(joinPetNames(_l10n, ['Moka', 'Oslo']), 'Moka et Oslo');
    expect(
      joinPetNames(_l10n, ['Moka', 'Oslo', 'Pistache']),
      'Moka, Oslo et Pistache',
    );
  });

  test('documentMeta: the pets known, then the clinic-local date', () {
    final names = {'a': 'Moka', 'b': 'Oslo'};

    expect(
      documentMeta(_l10n, _document(petIds: ['a', 'x', 'b']), names),
      // 23:30 in the clinic: still 31 August there.
      'Moka et Oslo · 31 août 2026',
    );
    expect(
      documentMeta(_l10n, _document(petIds: ['x']), names),
      '31 août 2026',
    );
  });

  test('documentMeta: a prescription, valid until or issued on', () {
    final valid = PrescriptionSummary(
      id: const PrescriptionId('p'),
      validUntil: LocalDate(2027, 1, 14),
    );

    expect(
      documentMeta(
        _l10n,
        _document(
          kind: DocumentKind.prescription,
          petIds: ['a'],
          prescription: valid,
        ),
        {'a': 'Moka'},
      ),
      "Moka · valable jusqu'au 14 janv. 2027",
    );
    expect(
      documentMeta(
        _l10n,
        _document(kind: DocumentKind.prescription, prescription: _summary()),
        const {},
      ),
      '31 août 2026',
    );
  });

  test('documentMeta: an invoice, never its pets; no unknown status', () {
    String meta(PaymentStatus status) => documentMeta(
      _l10n,
      _document(
        kind: DocumentKind.invoice,
        petIds: ['a'],
        invoice: InvoiceSummary(
          total: Money(123456, 'EUR'),
          paymentStatus: status,
        ),
      ),
      {'a': 'Moka'},
    );

    expect(meta(PaymentStatus.paid), '1 234,56 € · Payée · 31 août');
    expect(meta(PaymentStatus.unpaid), '1 234,56 € · Non payée · 31 août');
    expect(
      meta(PaymentStatus.partiallyPaid),
      '1 234,56 € · Partiellement payée · 31 août',
    );
    expect(meta(PaymentStatus.credited), '1 234,56 € · Avoir · 31 août');
    expect(meta(PaymentStatus.unknown), '1 234,56 € · 31 août');
  });

  test('documentTile: the mockup colours and glyphs; a file icon for an '
      'unknown kind', () {
    expect(documentTile(_l10n, DocumentKind.report), (
      KivetoColorSets.indigo,
      'CR',
    ));
    expect(documentTile(_l10n, DocumentKind.prescription), (
      KivetoColorSets.orange,
      'Rx',
    ));
    expect(documentTile(_l10n, DocumentKind.invoice), (
      KivetoColorSets.green,
      '€',
    ));
    expect(documentTile(_l10n, DocumentKind.labResult), (
      KivetoColorSets.neutral,
      'Lab',
    ));
    expect(documentTile(_l10n, DocumentKind.certificate), (
      KivetoColorSets.indigo,
      'Cert',
    ));
    expect(documentTile(_l10n, DocumentKind.unknown), (
      KivetoColorSets.neutral,
      null,
    ));
  });

  test('the filters, their labels and empty titles', () {
    expect(documentFilters.map((kind) => filterLabel(_l10n, kind)), [
      'Tous',
      'Comptes-rendus',
      'Ordonnances',
      'Factures',
      'Résultats',
    ]);
    expect(documentFilters.map((kind) => emptyTitle(_l10n, kind)), [
      'Aucun document',
      'Aucun compte-rendu',
      'Aucune ordonnance',
      'Aucune facture',
      "Aucun résultat d'analyse",
    ]);
  });

  test('renewalControlOf: the server decides', () {
    expect(renewalControlOf(null), RenewalControl.none);
    expect(renewalControlOf(_summary()), RenewalControl.request);
    expect(renewalControlOf(_summary(renewable: false)), RenewalControl.none);
    for (final status in [
      RenewalStatus.rejected,
      RenewalStatus.closed,
      RenewalStatus.unknown,
    ]) {
      expect(
        renewalControlOf(_summary(status: status)),
        RenewalControl.request,
        reason: status.name,
      );
      expect(
        renewalControlOf(_summary(renewable: false, status: status)),
        RenewalControl.none,
        reason: status.name,
      );
    }
    expect(
      renewalControlOf(_summary(status: RenewalStatus.submitted)),
      RenewalControl.requested,
    );
    expect(
      renewalControlOf(_summary(status: RenewalStatus.done)),
      RenewalControl.done,
    );
  });
}
