// PortalDataExportRepository on the real chain and the captures: none,
// pending, ready, Marchand's ready and expired; the statuses and instants
// read from plain strings (unknown kept, a malformed instant refused); the
// request (202, 429 export_rate_limited with its Retry-After); the ZIP
// through its 302 and the signed URL.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/core/network/portal_file_downloader.dart';
import 'package:kiveto_mobile/features/client/domain/data_export.dart';
import 'package:kiveto_mobile/features/client/infrastructure/portal_data_export_repository.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';

import '../../../../support/fakes.dart';
import '../../../../support/portal_api/fake_portal_backend.dart';
import '../../../../support/portal_api/portal_http_harness.dart';

const _exports = '$api/me/data-exports';
const _export = '$api/me/data-export';
const _readyId = '01a1a364-b18e-709a-9274-f2b8099873ef';

void main() {
  late PortalHarness harness;
  late PortalDataExportRepository repository;

  setUp(() async {
    harness = await PortalHarness.create(tokens: pair('A'));
    repository = PortalDataExportRepository(
      harness.http.server,
      PortalFileDownloader(harness.http.dio, devConfig, harness.failures),
      harness.failures,
    );
  });

  group('exports', () {
    test('none (capture)', () async {
      harness.backend.on(
        'GET',
        _exports,
        PortalReply.fixture('me.data-exports.get.200.json'),
      );

      expect(await repository.exports(), isEmpty);
    });

    test('pending (capture): no ready or expiry instant', () async {
      harness.backend.on(
        'GET',
        _exports,
        PortalReply.fixture('me.data-exports.pending.get.200.json'),
      );

      final export = (await repository.exports()).single;

      expect(export.id, _readyId);
      expect(export.status, DataExportStatus.pending);
      expect(export.requestedAt, DateTime.utc(2026, 11, 3, 21, 50, 47));
      expect(export.requestedAt.isUtc, isTrue);
      expect(export.readyAt, isNull);
      expect(export.expiresAt, isNull);
    });

    test('ready (capture): its instants in UTC', () async {
      harness.backend.on(
        'GET',
        _exports,
        PortalReply.fixture('me.data-exports.ready.get.200.json'),
      );

      final export = (await repository.exports()).single;

      expect(export.status, DataExportStatus.ready);
      expect(export.readyAt, DateTime.utc(2026, 11, 3, 21, 50, 49));
      expect(export.expiresAt, DateTime.utc(2026, 11, 5, 21, 50, 49));
      expect(export.expiresAt!.isUtc, isTrue);
    });

    test('Marchand (capture): ready then expired, newest first', () async {
      harness.backend.on(
        'GET',
        _exports,
        PortalReply.fixture('me.data-exports.marchand.get.200.json'),
      );

      final exports = await repository.exports();

      expect(exports.map((export) => export.status), [
        DataExportStatus.ready,
        DataExportStatus.expired,
      ]);
      expect(exports.last.expiresAt, DateTime.utc(2026, 10, 29, 2, 28, 26));
    });

    test('failed and a status this app does not know', () async {
      harness.backend.on(
        'GET',
        _exports,
        PortalReply.json(
          jsonEncode([
            for (final status in ['failed', 'archived'])
              {
                'id': status,
                'status': status,
                'requestedAt': '2026-11-03T12:00:00+01:00',
                'readyAt': null,
                'expiresAt': null,
              },
          ]),
        ),
      );

      final exports = await repository.exports();

      expect(exports.map((export) => export.status), [
        DataExportStatus.failed,
        DataExportStatus.unknown,
      ]);
      // An offset other than UTC is kept as the same instant.
      expect(exports.first.requestedAt, DateTime.utc(2026, 11, 3, 11));
    });

    test('a malformed instant: an answer the app cannot use', () async {
      harness.backend.on(
        'GET',
        _exports,
        PortalReply.json(
          jsonEncode([
            {
              'id': 'x',
              'status': 'ready',
              'requestedAt': '2026-11-03T12:00:00+00:00',
              'readyAt': 'yesterday',
              'expiresAt': null,
            },
          ]),
        ),
      );

      await expectLater(repository.exports(), throwsA(isA<ServerFailure>()));
    });

    test('401 after a refused refresh: an UnauthorizedFailure', () async {
      harness.backend
        ..on('GET', _exports, problem('token_expired', 401))
        ..on('POST', '$api/auth/refresh', problem('refresh_revoked', 401));

      await expectLater(
        repository.exports(),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });
  });

  group('request', () {
    test('202 (capture): the id of the new export', () async {
      harness.backend.on(
        'POST',
        _export,
        PortalReply.fixture('me.data-export.post.202.json', status: 202),
      );

      expect(await repository.request(), _readyId);
      expect(harness.backend.requests.single.method, 'POST');
    });

    test('429 export_rate_limited (capture): its Retry-After', () async {
      harness.backend.on(
        'POST',
        _export,
        PortalReply.fixture(
          'me.data-export.post.429.json',
          status: 429,
          headers: {
            'retry-after': ['86400'],
          },
        ),
      );

      await expectLater(
        repository.request(),
        throwsA(
          isA<RateLimitedFailure>()
              .having((failure) => failure.code, 'code', 'export_rate_limited')
              .having(
                (failure) => failure.retryAfter,
                'retryAfter',
                const Duration(hours: 24),
              ),
        ),
      );
    });
  });

  group('download', () {
    const file = '$_exports/$_readyId/file';
    const signed =
        '$api/files/exports/$_readyId'
        '?_expiration=1793710624&_hash=RXhwb3J0LWhhc2g';

    test('the 302 to the signed URL, then the ZIP bytes', () async {
      final zip = utf8.encode('PK\u0003\u0004 kiveto');
      harness.backend
        ..on(
          'GET',
          file,
          PortalReply.empty(
            302,
            headers: {
              'location': ['http://portal.kiveto.local:81$signed'],
            },
          ),
        )
        ..on(
          'GET',
          signed,
          PortalReply.bytes(
            zip,
            contentType: 'application/zip',
            headers: {
              'content-disposition': [
                'attachment; filename="kiveto-export.zip"',
              ],
            },
          ),
        );

      final download = await repository.download(_readyId);

      expect(download.bytes, zip);
      expect(download.contentType, 'application/zip');
      expect(download.fileName, 'kiveto-export.zip');
      final [first, second] = harness.backend.requests;
      expect(first.pathWithQuery, file);
      expect(bearerOf(first), 'Bearer A');
      expect(second.uri.toString(), 'http://10.0.2.2:81$signed');
      expect(second.headers, isNot(contains('Authorization')));
    });

    test('the id is one encoded path segment; a gone export is a '
        'NotFoundFailure', () async {
      harness.backend.on(
        'GET',
        '$_exports/a%2Fb/file',
        problem('not_found', 404),
      );

      await expectLater(
        repository.download('a/b'),
        throwsA(isA<NotFoundFailure>()),
      );
    });
  });
}
