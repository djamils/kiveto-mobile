import 'package:kiveto_mobile/features/identity_access/domain/invitation_repository.dart';
import 'package:kiveto_mobile/features/identity_access/domain/session_store.dart';

/// Accepts an invitation from its link with the code sent to the invited
/// mobile and the version of the terms accepted, then opens the session it
/// gives (the newest session wins, also over a signed-in one).
final class AcceptInvitationByLink {
  const new(this._invitations, this._session);

  final InvitationRepository _invitations;
  final SessionStore _session;

  /// Throws the `ApiFailure` of a refused acceptance; the session is then
  /// unchanged.
  Future<void> call({
    required String token,
    required String challengeId,
    required String code,
    required String termsVersion,
  }) async {
    final tokens = await _invitations.acceptByLink(
      token: token,
      challengeId: challengeId,
      code: code,
      termsVersion: termsVersion,
    );
    await _session.open(tokens);
  }
}
