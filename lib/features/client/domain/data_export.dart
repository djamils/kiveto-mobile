/// How far an export of the account's data went: being built, ready to
/// download (until `expiresAt`), failed, expired; [unknown] for a status
/// this app does not know.
enum DataExportStatus { pending, ready, failed, expired, unknown }

/// An export of the account's data (a ZIP archive).
final class DataExport {
  const new({
    required this.id,
    required this.status,
    required this.requestedAt,
    this.readyAt,
    this.expiresAt,
  });

  final String id;
  final DataExportStatus status;

  /// The instants, in UTC.
  final DateTime requestedAt;
  final DateTime? readyAt;
  final DateTime? expiresAt;

  @override
  String toString() => 'DataExport($id, ${status.name})';
}
