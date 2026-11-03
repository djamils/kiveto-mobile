// PortalFile: the bytes of a Portal API file and what the server said about
// them.

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/shared/domain/portal_file.dart';

void main() {
  test('keeps the bytes, the content type and the file name', () {
    final bytes = [0x25, 0x50, 0x44, 0x46];
    final file = PortalFile(
      bytes,
      contentType: 'application/pdf',
      fileName: 'facture.pdf',
    );

    expect(file.bytes, same(bytes));
    expect(file.contentType, 'application/pdf');
    expect(file.fileName, 'facture.pdf');
    expect(
      file.toString(),
      'PortalFile(4 bytes, application/pdf, facture.pdf)',
    );
  });

  test('the content type and file name are optional', () {
    final file = PortalFile(List<int>.filled(2, 0));

    expect(file.contentType, isNull);
    expect(file.fileName, isNull);
    expect(file.toString(), 'PortalFile(2 bytes, null, null)');
  });
}
