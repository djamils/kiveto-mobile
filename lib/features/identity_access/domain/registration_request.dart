import 'package:kiveto_mobile/features/identity_access/domain/otp_verification.dart';

/// What `POST /auth/register` sends: the grant of the verified number, the
/// names and the optional email as typed, the version of the terms
/// accepted. The server checks them all (lengths, formats, the version).
final class RegistrationRequest {
  const new({
    required this.grant,
    required this.firstName,
    required this.lastName,
    required this.termsVersion,
    this.email,
  });

  final RegistrationGrant grant;
  final String firstName;
  final String lastName;
  final String? email;
  final String termsVersion;

  @override
  String toString() => 'RegistrationRequest(<redacted>)';
}
