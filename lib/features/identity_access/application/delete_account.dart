import 'package:kiveto_mobile/features/identity_access/domain/account_security_repository.dart';
import 'package:kiveto_mobile/features/identity_access/domain/session_store.dart';

/// Deletes the account: the server checks the SMS code and deactivates the
/// account, then the session closes on the device (its tokens are refused
/// from then on; no logout is sent). A refusal (a wrong code, a network
/// failure) throws its `ApiFailure` and leaves the session open.
final class DeleteAccount {
  const new(this._security, this._session);

  final AccountSecurityRepository _security;
  final SessionStore _session;

  Future<void> call({required String challengeId, required String code}) async {
    await _security.confirmDeletion(challengeId: challengeId, code: code);
    await _session.close();
  }
}
