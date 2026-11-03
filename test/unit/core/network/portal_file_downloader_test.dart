// PortalFileDownloader on the real chain: the 302 to a signed /files/ URL,
// rewritten for the dev host, fetched without the Bearer token.

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/core/network/portal_file_downloader.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';

import '../../../support/fakes.dart';
import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';

const _file = '$api/clinics/c/documents/d/file';
const _signed = '/files/documents/c/d/1?_hash=x&_expiration=9';
const _pdf = [0x25, 0x50, 0x44, 0x46];

void main() {
  late PortalHarness harness;
  late PortalFileDownloader downloader;

  setUp(() async {
    harness = await PortalHarness.create(tokens: pair('A'));
    downloader = PortalFileDownloader(
      harness.http.dio,
      devConfig,
      harness.failures,
    );
  });

  PortalReply redirect(String location) => PortalReply.empty(
    302,
    headers: {
      'location': [location],
    },
  );

  test('302 to the dev host: rewritten, fetched without Bearer', () async {
    harness.backend
      ..on('GET', _file, redirect('http://portal.kiveto.local$_signed'))
      ..on(
        'GET',
        _signed,
        PortalReply.bytes(
          _pdf,
          contentType: 'application/pdf',
          headers: {
            'content-disposition': ['inline; filename="facture-0412.pdf"'],
          },
        ),
      );

    final file = await downloader.download(_file);

    expect(file.bytes, _pdf);
    expect(file.contentType, 'application/pdf');
    expect(file.fileName, 'facture-0412.pdf');
    final [first, second] = harness.backend.requests;
    expect(bearerOf(first), 'Bearer A');
    expect(second.uri.toString(), 'http://10.0.2.2:81$_signed');
    expect(second.headers, isNot(contains('Authorization')));
    expect(second.headers['Host'], 'portal.kiveto.local');
  });

  test('a Location on another host is fetched as is', () async {
    harness.backend
      ..on('GET', _file, redirect('https://cdn.example.com/files/x'))
      ..on('GET', '/files/x', PortalReply.bytes(_pdf));

    final file = await downloader.download(_file);

    expect(
      harness.backend.requests.last.uri.toString(),
      'https://cdn.example.com/files/x',
    );
    expect(file.contentType, isNull);
    expect(file.fileName, isNull);
    final other = harness.backend.requests.last.headers;
    expect(other, isNot(contains('Authorization')));
    expect(other, isNot(contains('X-Device-Id')));
    expect(other, isNot(contains('Host')));
  });

  test('a relative Location resolves against the API path', () async {
    harness.backend
      ..on('GET', _file, redirect('/files/rel'))
      ..on(
        'GET',
        '/files/rel',
        PortalReply.bytes(
          _pdf,
          headers: {
            'content-disposition': ['attachment; filename=export.zip'],
          },
        ),
      );

    final file = await downloader.download(_file);

    expect(
      harness.backend.requests.last.uri.toString(),
      'http://10.0.2.2:81/files/rel',
    );
    expect(file.fileName, 'export.zip');
  });

  test('a 2xx answer is the file itself', () async {
    harness.backend.on(
      'GET',
      _file,
      PortalReply.bytes(_pdf, contentType: 'application/pdf'),
    );

    final file = await downloader.download(_file);

    expect(file.bytes, _pdf);
    expect(harness.backend.requests, hasLength(1));
  });

  test('302 without Location is a ServerFailure', () async {
    harness.backend.on('GET', _file, PortalReply.empty(302));

    await expectLater(
      downloader.download(_file),
      throwsA(isA<ServerFailure>().having((f) => f.statusCode, 'status', 302)),
    );
  });

  test('404 is a NotFoundFailure, on either request', () async {
    harness.backend.on('GET', _file, problem('not_found', 404));
    await expectLater(
      downloader.download(_file),
      throwsA(isA<NotFoundFailure>()),
    );

    harness.backend
      ..on('GET', _file, redirect('http://portal.kiveto.local$_signed'))
      ..on('GET', _signed, problem('not_found', 404));
    await expectLater(
      downloader.download(_file),
      throwsA(isA<NotFoundFailure>()),
    );
  });

  test('an empty body is an empty file', () async {
    harness.backend.on('GET', _file, PortalReply.empty(204));

    expect((await downloader.download(_file)).bytes, isEmpty);
  });
}
