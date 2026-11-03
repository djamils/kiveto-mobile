// The domain imports no package (rule 1), so package:meta's @immutable is
// out of reach: the value objects below have only final fields.
// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

/// A mobile number as the user typed it: a dialling prefix (`+33`) and the
/// national digits, sent to the Portal API in E.164 (`+33612345678`).
///
/// Only the digits are kept and one leading trunk `0` is dropped
/// (`06 12 34 56 78` → `612345678`). Whether the number is covered, or
/// even valid, is the server's answer (`422 phone_not_supported`,
/// `validation_failed`), never checked here.
final class PhoneNumber {
  const new _(this.countryCode, this.national);

  /// The number of [national] behind [countryCode] (`+33` or `33`), or
  /// null when [national] holds no digit.
  static PhoneNumber? fromNational({
    required String countryCode,
    required String national,
  }) {
    final digits = national.replaceAll(_nonDigits, '');
    final trimmed = digits.startsWith('0') ? digits.substring(1) : digits;
    if (trimmed.isEmpty) return null;
    return PhoneNumber._('+${countryCode.replaceAll(_nonDigits, '')}', trimmed);
  }

  static final _nonDigits = RegExp(r'\D');

  /// The dialling prefix, `+` included: `+33`.
  final String countryCode;

  /// The national digits without the trunk `0`: `612345678`.
  final String national;

  /// `+33612345678`.
  String get e164 => '$countryCode$national';

  @override
  bool operator ==(Object other) =>
      other is PhoneNumber &&
      other.countryCode == countryCode &&
      other.national == national;

  @override
  int get hashCode => Object.hash(countryCode, national);

  @override
  String toString() => 'PhoneNumber($e164)';
}
