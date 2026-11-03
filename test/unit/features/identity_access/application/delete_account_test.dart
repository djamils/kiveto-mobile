// DeleteAccount: the server confirms, then the session closes on the
// device; a refusal leaves it open.

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/identity_access/application/delete_account.dart';
import 'package:kiveto_mobile/features/identity_access/domain/account_security_repository.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_challenge.dart';
import 'package:kiveto_mobile/features/identity_access/domain/session_store.dart';
import 'package:kiveto_mobile/features/identity_access/domain/session_tokens.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';

final class _Session implements SessionStore {
  final calls = <String>[];

  @override
  String? get refreshToken => 'refresh-A';

  @override
  Future<void> open(SessionTokens tokens) async => calls.add('open');

  @override
  Future<void> close() async => calls.add('close');
}

final class _Security implements AccountSecurityRepository {
  new(this._session, {this.failure});

  final _Session _session;
  final ApiFailure? failure;

  @override
  Future<void> confirmDeletion({
    required String challengeId,
    required String code,
  }) async {
    _session.calls.add('confirm $challengeId $code');
    if (failure case final failure?) throw failure;
  }

  @override
  Future<OtpChallenge> requestDeletionCode() => throw UnimplementedError();

  @override
  Future<OtpChallenge> requestEmailChangeCode() => throw UnimplementedError();

  @override
  Future<String> startEmailChange({
    required String challengeId,
    required String code,
    required String email,
  }) => throw UnimplementedError();

  @override
  Future<void> verifyEmail({
    required String challengeId,
    required String code,
  }) => throw UnimplementedError();
}

void main() {
  test('confirmed by the server, then the session closes', () async {
    final session = _Session();

    await DeleteAccount(_Security(session), session)(
      challengeId: 'c1',
      code: '123456',
    );

    expect(session.calls, ['confirm c1 123456', 'close']);
  });

  test('a refused code: the failure, the session left open', () async {
    final session = _Session();
    const failure = BusinessFailure(code: 'otp_invalid', statusCode: 422);

    await expectLater(
      DeleteAccount(_Security(session, failure: failure), session)(
        challengeId: 'c1',
        code: '000000',
      ),
      throwsA(same(failure)),
    );
    expect(session.calls, ['confirm c1 000000']);
  });
}
