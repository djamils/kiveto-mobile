import 'package:flutter/foundation.dart';
import 'package:kiveto_mobile/core/security/token_pair.dart';
import 'package:kiveto_mobile/core/security/token_storage.dart';

enum SessionStatus { signedOut, signedIn }

/// The session the router and the auth interceptor read: signed out, or
/// signed in with a [TokenPair].
///
/// Memory first: every change updates [tokens] and notifies the listeners
/// at once, then persists in the background, in order. A persistence
/// failure is swallowed (the session lives in memory; the next start asks
/// to sign in again), with a log line that names no value.
final class SessionManager with ChangeNotifier {
  new _(this._storage, this._tokens);

  /// The session of the stored pair. Never throws: an unreadable storage
  /// is a signed-out session.
  static Future<SessionManager> restore(TokenStorage storage) async {
    TokenPair? tokens;
    try {
      tokens = await storage.read();
    } on Object catch (error) {
      debugPrint('SessionManager: storage unreadable (${error.runtimeType})');
    }
    return SessionManager._(storage, tokens);
  }

  final TokenStorage _storage;
  TokenPair? _tokens;
  int _generation = 0;
  Future<void> _persisted = Future.value();

  SessionStatus get status =>
      _tokens == null ? SessionStatus.signedOut : SessionStatus.signedIn;

  TokenPair? get tokens => _tokens;

  /// Counts the session changes: [open] (a sign-in, an invitation
  /// acceptance, a registration) and a [signOut] that ends a session
  /// increment it; a refresh ([replaceTokens]) does not. What belongs to
  /// the account rather than to its tokens is rebuilt when it changes,
  /// never on a refresh.
  int get generation => _generation;

  /// Signs in with [tokens], replacing any pair: after a sign-in, an
  /// invitation acceptance or a registration, the newest pair always wins.
  /// Always a new session, also over a signed-in one.
  Future<void> open(TokenPair tokens) {
    _generation++;
    return _install(tokens);
  }

  /// Forgets the session (memory, then storage).
  Future<void> signOut() {
    if (_tokens != null) {
      _tokens = null;
      _generation++;
      notifyListeners();
    }
    return _persist(_storage.clear);
  }

  /// After a refresh: installs [next] only when the session still holds the
  /// refresh token of [expected] (compare-and-set), and says whether it
  /// did. A newer pair opened meanwhile is kept.
  Future<bool> replaceTokens({
    required TokenPair expected,
    required TokenPair next,
  }) async {
    if (_tokens?.refreshToken != expected.refreshToken) return false;
    await _install(next);
    return true;
  }

  /// After a refused refresh: signs out only when the session still holds
  /// the refresh token of [expected].
  Future<void> signOutIfCurrent(TokenPair expected) async {
    if (_tokens?.refreshToken != expected.refreshToken) return;
    await signOut();
  }

  /// Installs [tokens] in memory, notifies, then persists them; [open]
  /// counts a new session, a refresh does not.
  Future<void> _install(TokenPair tokens) {
    _tokens = tokens;
    notifyListeners();
    return _persist(() => _storage.write(tokens));
  }

  Future<void> _persist(Future<void> Function() write) =>
      _persisted = _persisted.then((_) async {
        try {
          await write();
        } on Object catch (error) {
          debugPrint(
            'SessionManager: storage write failed (${error.runtimeType})',
          );
        }
      });
}
