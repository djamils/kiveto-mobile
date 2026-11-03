/// A file of the Portal API (a document, a vaccination booklet, a data
/// export): its bytes, and what the server said about them.
///
/// Shared by the features that open or keep a file (document, patient,
/// client); the bytes stay a plain `List<int>` (the domain imports no
/// `dart:typed_data`), the presentation hands them to its viewer.
final class PortalFile {
  const new(this.bytes, {this.contentType, this.fileName});

  final List<int> bytes;

  /// `application/pdf`…
  final String? contentType;

  /// From `Content-Disposition: …; filename="…"`.
  final String? fileName;

  @override
  String toString() =>
      'PortalFile(${bytes.length} bytes, $contentType, $fileName)';
}
