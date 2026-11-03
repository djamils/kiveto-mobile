// The domain imports no package (rule 1), so package:meta's @immutable is
// out of reach: the value objects below have only final fields.
// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

/// The current terms of use of the Portal (`GET /legal/terms/current`):
/// [version] is what the acceptances send back (`termsVersion`), [url]
/// the page the links open.
final class Terms {
  const new({required this.version, required this.url});

  final String version;
  final String url;

  @override
  bool operator ==(Object other) =>
      other is Terms && other.version == version && other.url == url;

  @override
  int get hashCode => Object.hash(version, url);

  @override
  String toString() => 'Terms($version)';
}
