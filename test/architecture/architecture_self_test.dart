// Proves that each D15 rule of architecture_rules.dart catches what it
// should: offending files injected into temporary lib/ trees, one tree per
// rule, then a compliant layout using every allowed edge.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'architecture_rules.dart';

/// Split so that no file of the repository holds the marker itself.
const _ignoreMarker =
    'coverage'
    ':ignore';

/// Writes [files] (path under lib/ → content) into a temporary project and
/// returns the offences found there.
List<Offence> _check(Map<String, String> files) {
  final root = Directory.systemTemp.createTempSync('kiveto_architecture_');
  addTearDown(() => root.deleteSync(recursive: true));
  for (final MapEntry(key: path, value: content) in files.entries) {
    File('${root.path}/lib/$path')
      ..createSync(recursive: true)
      ..writeAsStringSync(content);
  }
  return checkArchitecture(root.path);
}

/// Expects the offences of [rule] to be exactly [expected]: for each one,
/// its head (`[rule N] lib/<path>:<line> imports <uri>`) and a fragment of
/// what the rule allows.
void _expectRule(
  List<Offence> offences,
  int rule,
  List<(String, String)> expected,
) {
  final messages = [
    for (final offence in offences)
      if (offence.rule == rule) offence.message,
  ];
  expect(messages.map((message) => message.split(' — ').first).toList(), [
    for (final (head, _) in expected) head,
  ], reason: messages.join('\n'));
  for (var i = 0; i < expected.length; i++) {
    expect(messages[i], contains(' — ${expected[i].$2}'));
    expect(messages[i], endsWith(' (architecture §3, D15)'));
  }
}

/// The rules broken by [offences].
Set<int> _rules(List<Offence> offences) => {
  for (final offence in offences) offence.rule,
};

void main() {
  group('a violation of', () {
    test('rule 1: a domain importing a package, a platform library or '
        'another domain', () {
      final offences = _check({
        'features/patient/domain/pet.dart': '''
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:collection';
import 'pet_id.dart';
import 'package:kiveto_mobile/shared/domain/clock.dart';
import '../../client/domain/client.dart';
''',
        'shared/domain/clock.dart': "import 'dart:ui';\n",
      });

      const featureDomain =
          'features/patient/domain/ may import only dart:core, dart:async, '
          'dart:collection, dart:math, its own domain and shared/domain/';
      const sharedDomain =
          'shared/domain/ may import only dart:core, dart:async, '
          'dart:collection, dart:math and itself';
      _expectRule(offences, 1, [
        (
          '[rule 1] lib/features/patient/domain/pet.dart:1 imports '
              'package:flutter/foundation.dart',
          featureDomain,
        ),
        (
          '[rule 1] lib/features/patient/domain/pet.dart:2 imports dart:io',
          featureDomain,
        ),
        (
          '[rule 1] lib/features/patient/domain/pet.dart:6 imports '
              '../../client/domain/client.dart',
          featureDomain,
        ),
        (
          '[rule 1] lib/shared/domain/clock.dart:1 imports dart:ui',
          sharedDomain,
        ),
      ]);
      expect(_rules(offences), {1, 5});
    });

    test('rule 2: an application importing Flutter, Riverpod, Dio, the '
        'client, its runtime, core/ or presentation', () {
      final offences = _check({
        'features/patient/application/book_pet.dart': '''
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart';
import 'package:kiveto_mobile/core/errors/api_failure.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import '../domain/pet.dart';
import 'confirm_booking.dart';
import '../../../shared/domain/clock.dart';
import 'dart:async';
import '../presentation/pet_page.dart';
import 'package:tonik_util/tonik_util.dart';
''',
      });

      const allowed =
          'features/patient/application/ may import only dart:core, '
          'dart:async, dart:collection, dart:math, its own domain and '
          'application, and shared/domain/: no Flutter, Riverpod, Dio, '
          'kiveto_portal_api, tonik_util or core/';
      const file = '[rule 2] lib/features/patient/application/book_pet.dart';
      _expectRule(offences, 2, [
        ('$file:1 imports package:flutter/widgets.dart (Flutter)', allowed),
        (
          '$file:2 imports package:flutter_riverpod/flutter_riverpod.dart '
              '(Riverpod)',
          allowed,
        ),
        ('$file:3 imports package:dio/dio.dart (Dio)', allowed),
        (
          '$file:4 imports package:kiveto_portal_api/kiveto_portal_api.dart '
              '(kiveto_portal_api)',
          allowed,
        ),
        (
          '$file:5 imports package:kiveto_mobile/core/errors/api_failure.dart '
              '(core/)',
          allowed,
        ),
        ('$file:6 imports dart:ui (Flutter)', allowed),
        ('$file:7 imports package:go_router/go_router.dart', allowed),
        ('$file:12 imports ../presentation/pet_page.dart', allowed),
        (
          '$file:13 imports package:tonik_util/tonik_util.dart (tonik_util)',
          allowed,
        ),
      ]);
      expect(_rules(offences), {2, 7});
    });

    test('rule 3: presentation importing infrastructure, Dio, the client, '
        'core/network/ or core/security/', () {
      final offences = _check({
        'features/patient/presentation/pet_page.dart': '''
import '../infrastructure/pet_api.dart';
import 'package:dio/dio.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart';
import 'package:kiveto_mobile/core/network/http.dart';
import 'package:kiveto_mobile/core/errors/api_failure.dart';
import '../application/book_pet.dart';
''',
        'shared/presentation/kit.dart':
            "import '../../core/security/session.dart';\n",
      });

      const allowed =
          'presentation reaches data through application/, domain/ and the '
          "providers of di.dart, never a feature's infrastructure/, Dio, "
          'kiveto_portal_api, core/network/ or core/security/';
      const page = '[rule 3] lib/features/patient/presentation/pet_page.dart';
      _expectRule(offences, 3, [
        ('$page:1 imports ../infrastructure/pet_api.dart', allowed),
        ('$page:2 imports package:dio/dio.dart', allowed),
        (
          '$page:3 imports package:kiveto_portal_api/kiveto_portal_api.dart',
          allowed,
        ),
        (
          '$page:4 imports package:kiveto_mobile/core/network/http.dart',
          allowed,
        ),
        (
          '[rule 3] lib/shared/presentation/kit.dart:1 imports '
              '../../core/security/session.dart',
          allowed,
        ),
      ]);
      expect(_rules(offences), {3, 4, 6, 7});
    });

    test("rule 4: a feature's infrastructure imported outside the "
        'composition files', () {
      final offences = _check({
        'app/routing/router.dart': '''
import 'package:kiveto_mobile/features/patient/infrastructure/pet_api.dart';
''',
        'features/patient/application/book_pet.dart':
            "import '../infrastructure/pet_api.dart';\n",
        'features/client/infrastructure/client_api.dart':
            "import '../../patient/infrastructure/pet_api.dart';\n",
        // Allowed by rule 4 (rules 5 and 6 catch the last two).
        'features/patient/infrastructure/pet_api.dart':
            "import 'pet_mapper.dart';\n",
        'features/patient/di.dart': "import 'infrastructure/pet_api.dart';\n",
        'app/bootstrap/bootstrap.dart':
            "import '../../features/patient/infrastructure/pet_api.dart';\n",
        'features/home/di.dart':
            "import '../patient/infrastructure/pet_api.dart';\n",
        'core/di/providers.dart':
            "import '../../features/patient/infrastructure/pet_api.dart';\n",
      });

      const allowed =
          "a feature's infrastructure/ is imported only by its own "
          'infrastructure/, features/*/di.dart, core/di/, app/bootstrap/ and '
          'tests';
      _expectRule(offences, 4, [
        (
          '[rule 4] lib/app/routing/router.dart:1 imports '
              'package:kiveto_mobile/features/patient/infrastructure/'
              'pet_api.dart',
          allowed,
        ),
        (
          '[rule 4] lib/features/client/infrastructure/client_api.dart:1 '
              'imports ../../patient/infrastructure/pet_api.dart',
          allowed,
        ),
        (
          '[rule 4] lib/features/patient/application/book_pet.dart:1 imports '
              '../infrastructure/pet_api.dart',
          allowed,
        ),
      ]);
      expect(_rules(offences), {2, 4, 5, 6});
    });

    test("rule 5: a feature reaching another one's internals", () {
      final offences = _check({
        'features/home/presentation/home_page.dart': '''
import 'package:kiveto_mobile/features/patient/domain/pet.dart';
import '../../patient/patient.dart';
''',
        'features/home/di.dart':
            "import '../client/infrastructure/api.dart';\n",
        // app/ and main.dart may reach feature internals (rule 4 permitting).
        'app/routing/router.dart':
            "import '../../features/patient/presentation/pet_page.dart';\n",
        'main.dart': "import 'features/patient/domain/pet.dart';\n",
      });

      _expectRule(offences, 5, [
        (
          '[rule 5] lib/features/home/di.dart:1 imports '
              '../client/infrastructure/api.dart',
          'features/home/ reaches another feature only through its public '
              'API, features/client/client.dart',
        ),
        (
          '[rule 5] lib/features/home/presentation/home_page.dart:1 imports '
              'package:kiveto_mobile/features/patient/domain/pet.dart',
          'features/home/ reaches another feature only through its public '
              'API, features/patient/patient.dart',
        ),
      ]);
      expect(_rules(offences), {5});
    });

    test('rule 5: a cycle between features, reported once with every '
        'edge', () {
      final offences = _check({
        'features/alpha/alpha.dart': "import '../beta/beta.dart';\n",
        'features/alpha/presentation/page.dart':
            "import '../../beta/beta.dart';\n",
        'features/beta/beta.dart': '''
import '../alpha/alpha.dart';
import 'package:kiveto_mobile/features/gamma/gamma.dart';
''',
        'features/gamma/gamma.dart': "import '../alpha/alpha.dart';\n",
      });

      const allowed =
          'the feature graph stays acyclic: move what both need to '
          'shared/domain/ or invert the dependency';
      _expectRule(offences, 5, [
        (
          '[rule 5] feature cycle alpha → beta → alpha: '
              'lib/features/alpha/alpha.dart:1 imports ../beta/beta.dart; '
              'lib/features/beta/beta.dart:1 imports ../alpha/alpha.dart',
          allowed,
        ),
        (
          '[rule 5] feature cycle alpha → beta → gamma → alpha: '
              'lib/features/alpha/alpha.dart:1 imports ../beta/beta.dart; '
              'lib/features/beta/beta.dart:2 imports '
              'package:kiveto_mobile/features/gamma/gamma.dart; '
              'lib/features/gamma/gamma.dart:1 imports ../alpha/alpha.dart',
          allowed,
        ),
      ]);
    });

    test('rule 6: core/ or shared/ importing a feature, shared/ importing '
        'core/ or app/', () {
      final offences = _check({
        'core/di/providers.dart':
            "import 'package:kiveto_mobile/features/patient/di.dart';\n",
        'core/network/http.dart':
            "import '../../features/patient/patient.dart';\n",
        'shared/domain/money.dart':
            "import '../../core/errors/api_failure.dart';\n",
        'shared/presentation/kit.dart': '''
import 'package:kiveto_mobile/app/theme/theme.dart';
import '../../features/home/home.dart';
import '../domain/money.dart';
''',
      });

      const noFeature = 'core/ and shared/ import no feature';
      const noCore = 'shared/ imports nothing from core/ or app/';
      _expectRule(offences, 6, [
        (
          '[rule 6] lib/core/di/providers.dart:1 imports '
              'package:kiveto_mobile/features/patient/di.dart',
          noFeature,
        ),
        (
          '[rule 6] lib/core/network/http.dart:1 imports '
              '../../features/patient/patient.dart',
          noFeature,
        ),
        (
          '[rule 6] lib/shared/domain/money.dart:1 imports '
              '../../core/errors/api_failure.dart',
          noCore,
        ),
        (
          '[rule 6] lib/shared/presentation/kit.dart:1 imports '
              'package:kiveto_mobile/app/theme/theme.dart',
          noCore,
        ),
        (
          '[rule 6] lib/shared/presentation/kit.dart:2 imports '
              '../../features/home/home.dart',
          noFeature,
        ),
      ]);
      expect(_rules(offences), {1, 6});
    });

    test('rule 7: kiveto_portal_api imported outside the data side', () {
      const api =
          "import 'package:kiveto_portal_api/kiveto_portal_api.dart';\n";
      final offences = _check({
        'app/bootstrap/bootstrap.dart': api,
        'core/security/session.dart': api,
        'features/patient/di.dart': api,
        // Allowed.
        'features/patient/infrastructure/pet_api.dart': api,
        'core/network/http.dart': api,
        'core/di/providers.dart': api,
      });

      const allowed =
          'kiveto_portal_api is imported only under '
          'features/*/infrastructure/, core/network/ and core/di/';
      const uri = 'package:kiveto_portal_api/kiveto_portal_api.dart';
      _expectRule(offences, 7, [
        ('[rule 7] lib/app/bootstrap/bootstrap.dart:1 imports $uri', allowed),
        ('[rule 7] lib/core/security/session.dart:1 imports $uri', allowed),
        ('[rule 7] lib/features/patient/di.dart:1 imports $uri', allowed),
      ]);
      expect(_rules(offences), {7});
    });

    test('rule 7: tonik_util, the runtime of the client, imported outside '
        'the data side', () {
      const runtime = "import 'package:tonik_util/tonik_util.dart';\n";
      final offences = _check({
        'app/bootstrap/bootstrap.dart': runtime,
        'features/patient/presentation/pet_page.dart': runtime,
        'features/patient/di.dart': runtime,
        // Allowed.
        'features/patient/infrastructure/pet_api.dart': runtime,
        'core/network/http.dart': runtime,
        'core/di/providers.dart': runtime,
      });

      const allowed =
          'tonik_util is imported only under '
          'features/*/infrastructure/, core/network/ and core/di/';
      const uri = 'package:tonik_util/tonik_util.dart';
      _expectRule(offences, 7, [
        ('[rule 7] lib/app/bootstrap/bootstrap.dart:1 imports $uri', allowed),
        ('[rule 7] lib/features/patient/di.dart:1 imports $uri', allowed),
        (
          '[rule 7] lib/features/patient/presentation/pet_page.dart:1 '
              'imports $uri',
          allowed,
        ),
      ]);
      expect(_rules(offences), {7});
    });

    test('rule 8: DateTime.now, DateTime.timestamp, print( and coverage '
        'ignore comments in domain and application', () {
      final offences = _check({
        'features/patient/domain/age.dart':
            '''
// DateTime.now() and print('x') in comments are fine.
/* print(1); DateTime.now() */
int age(DateTime birth) => DateTime.now().year - birth.year;
final DateTime Function() clock = DateTime
    .now;
void log() => print('age');
void fine(Logger logger) => logger.print('fine');
void debug() => debugPrint('fine');
const x = 1; // $_ignoreMarker-line
''',
        'features/patient/application/book_pet.dart':
            'void f() => print (1);\n',
        'shared/domain/clock.dart': '''
DateTime now() => DateTime.now();
DateTime utc() => DateTime.timestamp();
''',
        // Not restricted by rule 8.
        'features/patient/presentation/pet_page.dart':
            "final now = DateTime.now();\nvoid f() => print('x');\n",
        'core/network/http.dart': 'final now = DateTime.now();\n',
      });

      const clock =
          'domain and application read the time from the injected Clock of '
          'shared/domain/';
      const print =
          'domain and application do not print: they return values or '
          'failures';
      const ignore =
          'domain and application stay at 100% line coverage without ignore '
          'comments (CLAUDE.md §4)';
      _expectRule(offences, 8, [
        (
          '[rule 8] lib/features/patient/application/book_pet.dart:1 uses '
              'print(',
          print,
        ),
        (
          '[rule 8] lib/features/patient/domain/age.dart:3 uses DateTime.now',
          clock,
        ),
        (
          '[rule 8] lib/features/patient/domain/age.dart:4 uses DateTime.now',
          clock,
        ),
        ('[rule 8] lib/features/patient/domain/age.dart:6 uses print(', print),
        (
          '[rule 8] lib/features/patient/domain/age.dart:9 uses '
              '$_ignoreMarker',
          ignore,
        ),
        ('[rule 8] lib/shared/domain/clock.dart:1 uses DateTime.now', clock),
        (
          '[rule 8] lib/shared/domain/clock.dart:2 uses DateTime.timestamp',
          clock,
        ),
      ]);
      expect(_rules(offences), {8});
    });

    test('rules 2 and 3: export and part directives, checked like imports', () {
      final offences = _check({
        'features/patient/presentation/pet_view.dart':
            "export '../infrastructure/pet_dto.dart';\n",
        'features/patient/application/book_pet.dart':
            "part '../presentation/booking_form.dart';\n",
      });

      _expectRule(offences, 2, [
        (
          '[rule 2] lib/features/patient/application/book_pet.dart:1 imports '
              '../presentation/booking_form.dart',
          'features/patient/application/ may import only',
        ),
      ]);
      _expectRule(offences, 3, [
        (
          '[rule 3] lib/features/patient/presentation/pet_view.dart:1 imports '
              '../infrastructure/pet_dto.dart',
          'presentation reaches data through application/',
        ),
      ]);
      expect(_rules(offences), {2, 3, 4});
    });

    test('rules 1 and 2: a domain or an application importing another '
        'feature, even through its public API', () {
      final offences = _check({
        'features/scheduling/application/book.dart':
            "import 'package:kiveto_mobile/features/client/client.dart';\n",
        'features/scheduling/domain/slot.dart':
            "import '../../client/client.dart';\n",
      });

      _expectRule(offences, 1, [
        (
          '[rule 1] lib/features/scheduling/domain/slot.dart:1 imports '
              '../../client/client.dart',
          'features/scheduling/domain/ may import only',
        ),
      ]);
      _expectRule(offences, 2, [
        (
          '[rule 2] lib/features/scheduling/application/book.dart:1 imports '
              'package:kiveto_mobile/features/client/client.dart',
          'features/scheduling/application/ may import only',
        ),
      ]);
      expect(_rules(offences), {1, 2});
    });
  });

  test('a compliant layout with every D15 folder and every allowed edge '
      'breaks no rule', () {
    final offences = _check({
      'main.dart': '''
import 'package:flutter/widgets.dart';

import 'app/bootstrap/bootstrap.dart';
import 'features/patient/presentation/pet_page.dart';
''',
      'app/bootstrap/bootstrap.dart': '''
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/features/patient/di.dart';
import 'package:kiveto_mobile/features/patient/infrastructure/pet_api.dart';

import '../../core/di/providers.dart';
import '../routing/router.dart';
''',
      'app/routing/router.dart': '''
import 'package:go_router/go_router.dart';

import '../../features/home/home.dart';
import '../../features/patient/patient.dart';
import '../../features/patient/presentation/pet_page.dart';
''',
      'app/theme/theme.dart': '''
import 'package:material_ui/material_ui.dart';

import '../../shared/presentation/kit.dart';
''',
      'core/network/http.dart': '''
import 'package:dio/dio.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart';
import 'package:tonik_util/tonik_util.dart';

import '../errors/api_failure.dart';
import '../security/token_store.dart';
import 'adapter_stub.dart' if (dart.library.io) 'adapter_io.dart';
''',
      'core/network/adapter_stub.dart': '',
      'core/network/adapter_io.dart': "import 'dart:io';\n",
      'core/security/token_store.dart': '''
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../shared/domain/clock.dart';
''',
      'core/errors/api_failure.dart':
          "import '../../shared/domain/failure.dart';\n",
      'core/di/providers.dart': '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart';
import 'package:tonik_util/tonik_util.dart';

import '../network/http.dart';
''',
      'shared/domain/clock.dart': '''
import 'dart:async';
import 'dart:collection';
import 'dart:core';
import 'dart:math';

import 'failure.dart';

/// Reads the time; tests inject a fixed one instead of DateTime.now().
abstract interface class Clock {
  DateTime now();
}
''',
      'shared/domain/failure.dart': 'sealed class Failure {}\n',
      'shared/presentation/kit.dart': '''
import 'package:material_ui/material_ui.dart';

import '../domain/clock.dart';
''',
      'features/patient/domain/pet.dart': '''
import 'dart:collection';

import 'package:kiveto_mobile/shared/domain/clock.dart';

import 'pet_id.dart';

part 'pet_kind.dart';
''',
      'features/patient/domain/pet_kind.dart': "part of 'pet.dart';\n",
      'features/patient/domain/pet_id.dart': 'extension type PetId(int v) {}\n',
      'features/patient/application/book_pet.dart': '''
import 'dart:async';

import 'package:kiveto_mobile/shared/domain/failure.dart';

import '../domain/pet.dart';
import 'booking_state.dart';

void log(Logger logger) => logger.print('booked');
''',
      'features/patient/application/booking_state.dart': '',
      'features/patient/infrastructure/pet_api.dart': '''
import 'package:dio/dio.dart';
import 'package:kiveto_mobile/core/network/http.dart';
import 'package:kiveto_mobile/shared/domain/failure.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart';
import 'package:tonik_util/tonik_util.dart';

import '../domain/pet.dart';
import 'pet_mapper.dart';
''',
      'features/patient/infrastructure/pet_mapper.dart':
          "import '../domain/pet_id.dart';\n",
      'features/patient/presentation/pet_page.dart': '''
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/providers.dart';
import 'package:kiveto_mobile/core/errors/api_failure.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/shared/domain/clock.dart';
import 'package:kiveto_mobile/shared/presentation/kit.dart';

import '../application/book_pet.dart';
import '../di.dart';
import '../domain/pet.dart';

final now = DateTime.now();
''',
      'features/patient/di.dart': '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/providers.dart';

import 'domain/pet.dart';
import 'infrastructure/pet_api.dart';
''',
      'features/patient/patient.dart': '''
export 'domain/pet.dart';
export 'presentation/pet_page.dart' show PetPage;
''',
      'features/client/client.dart': "export 'domain/client.dart';\n",
      'features/client/domain/client.dart': 'final class Client {}\n',
      'features/home/home.dart': "export 'presentation/home_page.dart';\n",
      'features/home/presentation/home_page.dart': '''
import '../../client/client.dart';
import '../../patient/patient.dart';
''',
      'l10n/app_localizations.dart': '''
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
''',
    });

    expect(offences, isEmpty, reason: offences.join('\n'));
  });
}
