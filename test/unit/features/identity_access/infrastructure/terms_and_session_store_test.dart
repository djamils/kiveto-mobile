// PortalTermsRepository on the captured terms; SessionManagerStore over the
// app's SessionManager.

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/core/security/session_manager.dart';
import 'package:kiveto_mobile/core/security/token_pair.dart';
import 'package:kiveto_mobile/features/identity_access/domain/session_tokens.dart';
import 'package:kiveto_mobile/features/identity_access/domain/terms.dart';
import 'package:kiveto_mobile/features/identity_access/infrastructure/portal_terms_repository.dart';
import 'package:kiveto_mobile/features/identity_access/infrastructure/session_manager_store.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';

import '../../../../support/fakes.dart';
import '../../../../support/portal_api/fake_portal_backend.dart';
import '../../../../support/portal_api/portal_http_harness.dart';

const _terms = '$api/legal/terms/current';

void main() {
  group('PortalTermsRepository', () {
    test('the current version and its page (capture)', () async {
      final harness = await PortalHarness.create();
      harness.backend.on(
        'GET',
        _terms,
        PortalReply.fixture('legal.terms.current.get.200.json'),
      );

      final terms = await PortalTermsRepository(
        harness.http.server,
        harness.failures,
      ).current();

      expect(
        terms,
        const Terms(
          version: '2026-10-29',
          url: 'http://portal.kiveto.local/cgu',
        ),
      );
    });

    test('a failure is thrown', () async {
      final harness = await PortalHarness.create();
      harness.backend.on('GET', _terms, problem('not_found', 404));

      await expectLater(
        PortalTermsRepository(harness.http.server, harness.failures).current(),
        throwsA(isA<NotFoundFailure>()),
      );
    });
  });

  group('SessionManagerStore', () {
    test('opens the session with the pair in UTC, closes it, reads the '
        'refresh token', () async {
      final session = await memorySession();
      final store = SessionManagerStore(session);
      expect(store.refreshToken, isNull);

      await store.open(
        SessionTokens(
          accessToken: 'A',
          refreshToken: 'refresh-A',
          accessTokenExpiresAt: DateTime.parse('2026-11-03T11:37:51+01:00'),
          refreshTokenExpiresAt: DateTime.utc(2027, 2),
        ),
      );

      expect(session.status, SessionStatus.signedIn);
      expect(
        session.tokens,
        TokenPair(
          accessToken: 'A',
          refreshToken: 'refresh-A',
          accessTokenExpiresAt: DateTime.utc(2026, 11, 3, 10, 37, 51),
          refreshTokenExpiresAt: DateTime.utc(2027, 2),
        ),
      );
      expect(session.tokens!.accessTokenExpiresAt!.isUtc, isTrue);
      expect(store.refreshToken, 'refresh-A');
      expect(session.generation, 1);

      await store.close();

      expect(session.status, SessionStatus.signedOut);
      expect(store.refreshToken, isNull);
    });

    test('no expiry: none stored', () async {
      final session = await memorySession();

      await SessionManagerStore(
        session,
      ).open(const SessionTokens(accessToken: 'A', refreshToken: 'refresh-A'));

      expect(session.tokens, pair('A'));
    });
  });
}
