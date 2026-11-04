import 'package:kiveto_mobile/core/errors/api_failure_mapper.dart';
import 'package:kiveto_mobile/core/network/portal_results.dart';
import 'package:kiveto_mobile/features/identity_access/domain/account_security_repository.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_challenge.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart' as api;
import 'package:tonik_util/tonik_util.dart';

/// [AccountSecurityRepository] on the generated `AccountApi`, through the
/// app's authenticated chain (`portalServerProvider`). The challenges'
/// instants are kept in UTC; the verified account of
/// `POST /me/email-change/verify` is not read (the account page reloads
/// `GET /me`).
final class PortalAccountSecurityRepository
    implements AccountSecurityRepository {
  new(api.Server server, this._failures) : _api = api.AccountApi(server);

  final api.AccountApi _api;
  final ApiFailureMapper _failures;

  @override
  Future<OtpChallenge> requestEmailChangeCode() async => switch (await _api
      .requestEmailChangeOtp()) {
    TonikSuccess(value: api.RequestEmailChangeOtpResponse202(:final body)) =>
      OtpChallenge(
        id: body.challengeId,
        expiresAt: body.expiresAt.toUtc(),
        resendAvailableAt: body.resendAvailableAt.toUtc(),
      ),
    final other => throw apiFailureOf(other, _failures),
  };

  @override
  Future<String> startEmailChange({
    required String challengeId,
    required String code,
    required String email,
  }) async => switch (await _api.requestEmailChange(
    body: api.EmailChange(challengeId: challengeId, code: code, email: email),
  )) {
    TonikSuccess(value: api.RequestEmailChangeResponse202(:final body)) =>
      body.challengeId,
    final other => throw apiFailureOf(other, _failures),
  };

  @override
  Future<void> verifyEmail({
    required String challengeId,
    required String code,
  }) async {
    switch (await _api.verifyEmailChange(
      body: api.EmailChangeVerification(challengeId: challengeId, code: code),
    )) {
      case TonikSuccess(value: api.VerifyEmailChangeResponse200()):
        return;
      case final other:
        throw apiFailureOf(other, _failures);
    }
  }

  @override
  Future<OtpChallenge> requestDeletionCode() async =>
      switch (await _api.requestDeletionOtp()) {
        TonikSuccess(value: api.RequestDeletionOtpResponse202(:final body)) =>
          OtpChallenge(
            id: body.challengeId,
            expiresAt: body.expiresAt.toUtc(),
            resendAvailableAt: body.resendAvailableAt.toUtc(),
          ),
        final other => throw apiFailureOf(other, _failures),
      };

  @override
  Future<void> confirmDeletion({
    required String challengeId,
    required String code,
  }) async {
    switch (await _api.requestDeletion(
      body: api.DeletionRequest(challengeId: challengeId, code: code),
    )) {
      case TonikSuccess(value: api.RequestDeletionResponse202()):
        return;
      case final other:
        throw apiFailureOf(other, _failures);
    }
  }
}
