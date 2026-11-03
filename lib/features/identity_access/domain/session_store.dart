import 'package:kiveto_mobile/features/identity_access/domain/session_tokens.dart';

/// The app's session, as the use cases see it: opened with the tokens of a
/// sign-in, an acceptance or a registration, closed by the logout.
abstract interface class SessionStore {
  /// Signs in with [tokens]; the newest pair wins.
  Future<void> open(SessionTokens tokens);

  /// Signs out locally.
  Future<void> close();

  /// The refresh token of the current session, or null when signed out.
  String? get refreshToken;
}
