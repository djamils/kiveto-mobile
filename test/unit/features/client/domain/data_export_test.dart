// An export of the account's data.

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/client/domain/data_export.dart';

void main() {
  test('a ready export and its instants', () {
    final export = DataExport(
      id: 'e1',
      status: DataExportStatus.ready,
      requestedAt: DateTime.utc(2026, 11, 3, 12),
      readyAt: DateTime.utc(2026, 11, 3, 12, 2),
      expiresAt: DateTime.utc(2026, 11, 5, 12, 2),
    );

    expect(export.status, DataExportStatus.ready);
    expect(export.expiresAt, DateTime.utc(2026, 11, 5, 12, 2));
    expect(export.toString(), 'DataExport(e1, ready)');
  });

  test('a pending export has no ready or expiry instant', () {
    final export = DataExport(
      id: 'e2',
      status: DataExportStatus.pending,
      requestedAt: DateTime.utc(2026, 11, 3, 12),
    );

    expect(export.readyAt, isNull);
    expect(export.expiresAt, isNull);
    expect(DataExportStatus.values.last, DataExportStatus.unknown);
  });
}
