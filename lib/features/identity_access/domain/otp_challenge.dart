// The domain imports no package (rule 1), so package:meta's @immutable is
// out of reach: the value objects below have only final fields.
// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

/// A code sent by SMS (sign-in or invitation): the challenge to verify it
/// against, until when the code is valid and from when a new one may be
/// asked (instants in UTC). The server decides both.
final class OtpChallenge {
  const new({
    required this.id,
    required this.expiresAt,
    required this.resendAvailableAt,
  });

  final String id;
  final DateTime expiresAt;
  final DateTime resendAvailableAt;

  @override
  bool operator ==(Object other) =>
      other is OtpChallenge &&
      other.id == id &&
      other.expiresAt == expiresAt &&
      other.resendAvailableAt == resendAvailableAt;

  @override
  int get hashCode => Object.hash(id, expiresAt, resendAvailableAt);

  @override
  String toString() =>
      'OtpChallenge($id, expiresAt: $expiresAt, '
      'resendAvailableAt: $resendAvailableAt)';
}
