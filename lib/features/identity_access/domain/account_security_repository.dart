import 'package:kiveto_mobile/features/identity_access/domain/otp_challenge.dart';

/// The changes of the signed-in account that a code sent by SMS to the
/// account's phone confirms: the e-mail change (then a second code sent to
/// the new address) and the account's deletion. Every method throws an
/// `ApiFailure` (shared/domain): the server decides the codes (`otp_invalid`,
/// `otp_expired`, `otp_attempts_exceeded`), their quotas
/// (`otp_rate_limited`) and the address (`validation_failed`,
/// `email_taken`).
abstract interface class AccountSecurityRepository {
  /// `POST /me/email-change/otp`: a code by SMS for the e-mail change.
  Future<OtpChallenge> requestEmailChangeCode();

  /// `POST /me/email-change`: checks the SMS [code] and sends a code to
  /// [email]; the id of that e-mail challenge.
  Future<String> startEmailChange({
    required String challengeId,
    required String code,
    required String email,
  });

  /// `POST /me/email-change/verify`: the code received at the new address;
  /// it becomes the account's verified e-mail.
  Future<void> verifyEmail({required String challengeId, required String code});

  /// `POST /me/deletion-request/otp`: a code by SMS for the deletion.
  Future<OtpChallenge> requestDeletionCode();

  /// `POST /me/deletion-request`: deletes the account; the server
  /// deactivates it at once (every token is refused from then on).
  Future<void> confirmDeletion({
    required String challengeId,
    required String code,
  });
}
