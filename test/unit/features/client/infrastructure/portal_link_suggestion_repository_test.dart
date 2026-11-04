// PortalLinkSuggestionRepository on the real chain and the live captures of
// 2026-11-04: Julien's record at Paris, none, a reason this app does not
// know; the acceptance (202 pending, an unknown status, 404).

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/client/domain/link_suggestion.dart';
import 'package:kiveto_mobile/features/client/domain/me.dart';
import 'package:kiveto_mobile/features/client/infrastructure/portal_link_suggestion_repository.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';

import '../../../../support/fakes.dart';
import '../../../../support/portal_api/fake_portal_backend.dart';
import '../../../../support/portal_api/portal_http_harness.dart';

const _suggestions = '$api/me/link-suggestions';
const _id = '6594e0c558ef0df770974b30a390e79f2ce8e3d5152ca9b22310d9d651f92ee4';

void main() {
  late PortalHarness harness;
  late PortalLinkSuggestionRepository repository;

  setUp(() async {
    harness = await PortalHarness.create(tokens: pair('A'));
    repository = PortalLinkSuggestionRepository(
      harness.http.server,
      harness.failures,
    );
  });

  test("Julien's record at Paris (capture), matched on the phone", () async {
    harness.backend.on(
      'GET',
      _suggestions,
      PortalReply.fixture('me.link-suggestions.get.200.json'),
    );

    final suggestion = (await repository.suggestions()).single;

    expect(suggestion.id, _id);
    expect(suggestion.clinicName, 'Clinique Vétérinaire de Paris');
    expect(suggestion.clinicCity, 'Paris');
    expect(suggestion.matchedOn, LinkMatch.phone);
    expect(
      '$suggestion',
      'LinkSuggestion($_id, Clinique Vétérinaire de Paris)',
    );
  });

  test('none (capture); a reason this app does not know', () async {
    harness.backend.on(
      'GET',
      _suggestions,
      PortalReply.fixture('me.link-suggestions.empty.get.200.json'),
    );
    expect(await repository.suggestions(), isEmpty);

    harness.backend.on(
      'GET',
      _suggestions,
      PortalReply.json(
        '[{"id":"s","clinic":{"name":"C","city":null},"matchedOn":"email"}]',
      ),
    );
    final suggestion = (await repository.suggestions()).single;
    expect(suggestion.matchedOn, LinkMatch.unknown);
    expect(suggestion.clinicCity, isNull);
  });

  test('signed out: an UnauthorizedFailure', () async {
    harness.backend.on('GET', _suggestions, problem('unauthorized', 401));
    await harness.session.signOut();

    await expectLater(
      repository.suggestions(),
      throwsA(isA<UnauthorizedFailure>()),
    );
  });

  test('accepted (capture): the link is pending; a status this app does '
      'not know', () async {
    harness.backend.on(
      'POST',
      '$_suggestions/$_id/accept',
      PortalReply.fixture(
        'me.link-suggestions.accept.post.202.json',
        status: 202,
      ),
    );
    expect(await repository.accept(_id), LinkStatus.pending);
    expect(
      harness.backend.requestsTo('$_suggestions/$_id/accept').single.method,
      'POST',
    );

    harness.backend.on(
      'POST',
      '$_suggestions/$_id/accept',
      PortalReply.json('{"linkStatus":"confirmed"}', status: 202),
    );
    expect(await repository.accept(_id), LinkStatus.unknown);
  });

  test('no longer offered (capture): a NotFoundFailure', () async {
    harness.backend.on(
      'POST',
      '$_suggestions/gone/accept',
      PortalReply.fixture(
        'me.link-suggestions.accept.unknown.post.404.json',
        status: 404,
      ),
    );

    await expectLater(
      repository.accept('gone'),
      throwsA(isA<NotFoundFailure>()),
    );
  });
}
