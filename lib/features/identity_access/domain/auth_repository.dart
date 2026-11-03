import 'package:kiveto_mobile/features/identity_access/domain/otp_challenge.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_channel.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_verification.dart';
import 'package:kiveto_mobile/features/identity_access/domain/phone_number.dart';
import 'package:kiveto_mobile/features/identity_access/domain/registration_request.dart';
import 'package:kiveto_mobile/features/identity_access/domain/session_tokens.dart';

/// The sign-in by code, the registration and the logout of the Portal API.
/// Every method throws an `ApiFailure` (shared/domain) when the server
/// refuses or cannot be reached.
abstract interface class AuthRepository {
  /// `POST /auth/otp/request`: sends a code by SMS to [phone].
  Future<OtpChallenge> requestCode(PhoneNumber phone);

  /// `POST /auth/otp/verify`: the branch of a right [code].
  Future<OtpVerification> verifyCode({
    required String challengeId,
    required String code,
  });

  /// `POST /auth/otp/{challengeId}/resend`: a new code on [channel].
  Future<OtpChallenge> resendCode({
    required String challengeId,
    required OtpChannel channel,
  });

  /// `POST /auth/register`: creates the account, signed in.
  Future<SessionTokens> register(RegistrationRequest request);

  /// `POST /auth/logout`: revokes the family of [refreshToken].
  Future<void> logout(String refreshToken);
}
