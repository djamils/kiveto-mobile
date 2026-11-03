import 'package:kiveto_mobile/features/identity_access/domain/auth_repository.dart';
import 'package:kiveto_mobile/features/identity_access/domain/registration_request.dart';
import 'package:kiveto_mobile/features/identity_access/domain/session_store.dart';

/// Creates the account of a verified number without invitation, then opens
/// its session.
final class RegisterAccount {
  const new(this._auth, this._session);

  final AuthRepository _auth;
  final SessionStore _session;

  /// Throws the `ApiFailure` of a refused registration; no session then.
  Future<void> call(RegistrationRequest request) async {
    final tokens = await _auth.register(request);
    await _session.open(tokens);
  }
}
