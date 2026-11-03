// The coverage gate (tool/lib/coverage_gate.dart) on temporary projects:
// lib/, tool/lib/, .dart_tool/package_config.json, test roots and lcov.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_tool/coverage_gate.dart';

/// Split so that no file of the repository holds the marker itself.
const _marker =
    'coverage'
    ':ignore';
const _ignoreLine = '// $_marker-line';

const _packageConfig = '''
{
  "configVersion": 2,
  "packages": [
    {
      "name": "dio",
      "rootUri": "file:///C:/pub-cache/hosted/pub.dev/dio-5.11.1",
      "packageUri": "lib/"
    },
    {"name": "kiveto_tool", "rootUri": "../tool", "packageUri": "lib/"},
    {"name": "kiveto_mobile", "rootUri": "../", "packageUri": "lib/"}
  ]
}''';

typedef _Result = ({int code, String out, String err});

final class _Project {
  new() : root = Directory.systemTemp.createTempSync('kiveto_gate_') {
    addTearDown(() => root.deleteSync(recursive: true));
  }

  final Directory root;

  void write(String path, String content) {
    File('${root.path}/$path')
      ..createSync(recursive: true)
      ..writeAsStringSync(content);
  }

  void packageConfig([String content = _packageConfig]) =>
      write('.dart_tool/package_config.json', content);

  /// Writes coverage/lcov.info: one record per path, with its hits per line.
  void lcov(Map<String, Map<int, int>> records) {
    write(
      'coverage/lcov.info',
      [
        for (final MapEntry(key: path, value: hits) in records.entries) ...[
          'SF:$path',
          for (final MapEntry(key: line, value: count) in hits.entries)
            'DA:$line,$count',
          'LF:${hits.length}',
          'LH:${hits.values.where((count) => count > 0).length}',
          'end_of_record',
        ],
      ].join('\n'),
    );
  }

  _Result gate([List<String> args = const ['--test-dir', 'test/unit']]) {
    final out = StringBuffer();
    final err = StringBuffer();
    final code = runCoverageGate(args, root: root.path, out: out, err: err);
    return (code: code, out: out.toString(), err: err.toString());
  }
}

/// A project whose only test covers lib/features/patient/domain/pet.dart.
_Project _covered() {
  return _Project()
    ..packageConfig()
    ..write('lib/main.dart', 'void main() {}\n')
    ..write('lib/features/patient/domain/pet.dart', '''
class Pet {
  const Pet(this.name);

  final String name;
}
''')
    ..write(
      'test/unit/pet_test.dart',
      "import 'package:kiveto_mobile/features/patient/domain/pet.dart';\n",
    )
    ..lcov({
      r'lib\features\patient\domain\pet.dart': {2: 1},
    });
}

void main() {
  test('passes a project where every gated file is covered, and reports '
      'exclusions, rows and notes', () {
    final project = _covered()
      ..write('lib/l10n/app_localizations.dart', 'class L {}\n')
      ..write('lib/l10n/app_localizations_fr.dart', 'class LFr {}\n')
      ..write('tool/coverage_gate.dart', 'void main() {}\n')
      ..write('tool/lib/gate.dart', 'int gate() => 0;\n')
      ..write('tool/.dart_tool/cache.dart', 'int hidden() => 0;\n')
      // Declarations only, reached through the public API's exports.
      ..write(
        'lib/features/patient/patient.dart',
        "export 'domain/pet.dart';\n"
            "export 'domain/pet_repository.dart';\n",
      )
      ..write(
        'lib/features/patient/domain/pet_repository.dart',
        'abstract interface class PetRepository {}\n',
      )
      // Measured layers: uncovered or never loaded, without threshold.
      ..write('lib/features/patient/di.dart', 'int di() => 1;\n')
      ..write('lib/features/patient/presentation/pet_page.dart', '''
// A page.
import 'package:flutter/widgets.dart'
    show Widget;

class PetPage {
  void build() {}
}
''')
      ..write('lib/shared/presentation/kit.dart', 'int kit() => 0;\n')
      ..write('lib/core/di/providers.dart', 'int providers() => 0;\n')
      ..write('lib/app/app.dart', 'int app() => 0;\n')
      ..write('lib/app/bootstrap/bootstrap.dart', 'int bootstrap() => 0;\n')
      ..write('lib/app/routing/router.dart', 'int router() => 0;\n')
      ..write('lib/app/theme/theme.dart', 'int theme() => 0;\n')
      // Gated, reached through relative imports, a part and a helper.
      ..write('lib/shared/domain/clock.dart', 'int now() => 0;\n')
      ..write('lib/core/network/http.dart', 'int http() => 0;\n')
      ..write('lib/core/security/token.dart', 'int token() => 0;\n')
      ..write(
        'lib/core/errors/failure.dart',
        "part 'failure_kind.dart';\n\nint failure() => 0;\n",
      )
      ..write(
        'lib/core/errors/failure_kind.dart',
        "part of 'failure.dart';\n\nenum FailureKind { network }\n",
      )
      ..write('test/unit/patient_test.dart', '''
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:kiveto_mobile/features/patient/patient.dart';
import 'package:kiveto_mobile/missing.dart';

import '../support/helpers.dart';
''')
      ..write('test/support/helpers.dart', '''
import 'package:kiveto_mobile/core/errors/failure.dart';
import 'package:kiveto_tool/gate.dart';
import '../../lib/shared/domain/clock.dart';
''')
      // Not a test root: what it imports is not reached through it.
      ..write(
        'test/unit/fake.dart',
        "import 'package:kiveto_mobile/core/network/http.dart';\n",
      )
      ..write(
        'test/widget/http_test.dart',
        "import 'package:kiveto_mobile/core/network/http.dart';\n"
            "import 'package:kiveto_mobile/core/security/token.dart';\n",
      )
      ..lcov({
        r'lib\features\patient\domain\pet.dart': {2: 1},
        'lib/features/patient/di.dart': {1: 0},
        'lib/shared/domain/clock.dart': {1: 3},
        'lib/core/network/http.dart': {1: 1},
        'lib/core/security/token.dart': {1: 1},
        'lib/core/errors/failure.dart': {3: 1},
        'tool/lib/gate.dart': {1: 1},
        'test/unit/patient_test.dart': {1: 1},
      });

    final result = project.gate([
      '--test-dir',
      'test/unit',
      '--test-dir',
      'test/widget',
    ]);

    expect(result.err, isEmpty);
    expect(result.code, 0, reason: result.out);
    final out = result.out;
    expect(out, contains('Declared exclusions:'));
    for (final exclusion in [
      r'lib/main\.dart +entry point \(1\)',
      r'lib/l10n/app_localizations\*\.dart +gen-l10n output \(2\)',
      r'tool/\*\.dart +thin entry points over tool/lib/.* \(1\)',
    ]) {
      expect(out, matches(RegExp(exclusion)), reason: exclusion);
    }
    expect(
      out,
      matches(RegExp('area +layer +files +lines hit/found +cover +threshold')),
    );
    for (final row in [
      r'features/patient +di\.dart +1 +0/1 +0\.0% +–',
      r'features/patient +domain +2 +1/1 +100\.0% +100%',
      r'features/patient +patient\.dart +1 +0/0 +– +–',
      r'features/patient +presentation +1 +0/3 +0\.0% +–',
      r'shared +domain +1 +1/1 +100\.0% +100%',
      r'shared +presentation +1 +0/1 +0\.0% +–',
      r'core +di +1 +0/1 +0\.0% +–',
      r'core +errors +2 +1/1 +100\.0% +100%',
      r'core +network +1 +1/1 +100\.0% +100%',
      r'core +security +1 +1/1 +100\.0% +100%',
      r'app +\(files\) +1 +0/1 +0\.0% +–',
      r'app +bootstrap +1 +0/1 +0\.0% +–',
      r'app +routing +1 +0/1 +0\.0% +–',
      r'app +theme +1 +0/1 +0\.0% +–',
      r'tool +lib +1 +1/1 +100\.0% +100%',
    ]) {
      expect(out, matches(RegExp(row)), reason: row);
    }
    expect(
      out,
      contains(
        'lib/features/patient/domain/pet_repository.dart: no executable '
        'lines (loaded by a test)',
      ),
    );
    expect(
      out,
      contains('lib/core/errors/failure_kind.dart: no executable lines'),
    );
    expect(
      out,
      contains(
        'lib/features/patient/presentation/pet_page.dart: not loaded by any '
        'test (0%), measured without threshold',
      ),
    );
    expect(out, isNot(contains('hidden')));
    expect(out, isNot(contains('test/unit')));
    expect(out, endsWith('✓ Coverage gate passed: 8 gated file(s) at 100%\n'));
  });

  test('fails on a gated file that no test loads', () {
    final project = _covered()
      ..write(
        'lib/features/patient/application/book.dart',
        '// Books a slot.\n\nint book() {\n  return 1;\n}\n',
      );

    final result = project.gate();

    expect(result.code, 1);
    expect(
      result.out,
      contains(
        '  lib/features/patient/application/book.dart: not loaded by any '
        'test (0%)\n',
      ),
    );
    expect(result.out, matches(RegExp(r'application +1 +0/3 +0\.0% +100%')));
    expect(result.out, endsWith('✗ Coverage gate failed: 1 problem(s)\n'));
  });

  test('passes a declarations-only gated file that a test imports', () {
    final project = _covered()
      ..write(
        'lib/features/patient/domain/species.dart',
        'enum Species { cat, dog }\n\ntypedef Name = String;\n',
      )
      ..write(
        'test/unit/species_test.dart',
        "import 'package:kiveto_mobile/features/patient/domain/species.dart';"
            '\n',
      );

    final result = project.gate();

    expect(result.code, 0, reason: result.out);
    expect(
      result.out,
      contains('lib/features/patient/domain/species.dart: no executable lines'),
    );
  });

  test('fails on a partly covered gated file and lists its uncovered '
      'lines', () {
    final project = _covered()
      ..write(
        'lib/features/patient/infrastructure/pet_api.dart',
        'int a() => 1;\n',
      )
      ..lcov({
        r'lib\features\patient\domain\pet.dart': {2: 1},
        'lib/features/patient/infrastructure/pet_api.dart': {9: 0, 5: 0, 6: 2},
      });

    final result = project.gate();

    expect(result.code, 1);
    expect(
      result.out,
      contains(
        'lib/features/patient/infrastructure/pet_api.dart: 1/3 lines '
        '(33.3%), uncovered lines: 5, 9',
      ),
    );
  });

  test('refuses a coverage ignore comment in a gated file', () {
    final project = _covered()
      ..write(
        'lib/features/patient/domain/pet.dart',
        'class Pet {\n  const Pet(this.name);\n\n'
            '  final String name; $_ignoreLine\n}\n',
      );

    final result = project.gate();

    expect(result.code, 1);
    expect(
      result.out,
      contains(
        'lib/features/patient/domain/pet.dart: $_marker on line 4 - '
        'forbidden in a gated layer (CLAUDE.md §4)',
      ),
    );
  });

  test('lets a measured file hold a coverage ignore comment', () {
    final project = _covered()
      ..write('lib/app/app.dart', 'int app() => 0; $_ignoreLine\n');

    expect(project.gate().code, 0);
  });

  test('fails on every file outside the D15 layout', () {
    const outside = [
      'lib/core/foo.dart',
      'lib/core/storage/box.dart',
      'lib/features/patient/util.dart',
      'lib/features/patient/data/pet_dto.dart',
      'lib/features/patient.dart',
      'lib/shared/format.dart',
      'lib/shared/widgets/button.dart',
      'lib/app/widgets/button.dart',
      'lib/l10n/plurals.dart',
      'lib/helpers.dart',
      'tool/bin/x.dart',
    ];
    final project = _covered();
    for (final path in outside) {
      project.write(path, 'int x() => 0;\n');
    }

    final result = project.gate();

    expect(result.code, 1);
    for (final path in outside) {
      expect(
        result.out,
        contains('  $path: outside the D15 layout (architecture §6): move it'),
        reason: path,
      );
    }
    expect(result.out, endsWith('✗ Coverage gate failed: 11 problem(s)\n'));
  });

  test('fails when lcov.info holds no record of a package whose gated '
      'files tests load', () {
    // As if --coverage-package=kiveto_tool were dropped: the lcov report
    // only holds lib/ records.
    final project = _covered()
      ..write('tool/lib/gate.dart', 'int gate() {\n  return 0;\n}\n')
      ..write(
        'test/unit/gate_test.dart',
        "import 'package:kiveto_tool/gate.dart';\n",
      );

    final result = project.gate();

    expect(result.code, 1);
    expect(
      result.out,
      contains(
        '  tool/lib/: no record in lcov.info for package:kiveto_tool, '
        'although tests load its gated files - fix: keep '
        '--coverage-package=kiveto_tool in the flutter test command of '
        'scripts/test.sh\n',
      ),
    );
    expect(result.out, endsWith('✗ Coverage gate failed: 1 problem(s)\n'));
  });

  group('reads its inputs', () {
    test('from --root, with an absolute --lcov holding absolute and '
        'repeated records', () {
      final project = _covered();
      final lcov = '${project.root.path}/coverage/other.info';
      final absolute =
          '${project.root.path}/lib/features/patient/domain'
          '/pet.dart';
      File(lcov).writeAsStringSync(
        [
          'TN:',
          'SF:$absolute',
          'DA:2,0',
          'DA:3,0,c2f1',
          'end_of_record',
          'SF:${absolute.replaceAll('/', r'\')}',
          'DA:2,1',
          'DA:3,4,c2f1',
          'end_of_record',
        ].join('\n'),
      );

      final out = StringBuffer();
      final code = runCoverageGate(
        ['--root', project.root.path, '--lcov', lcov, '--test-dir', 'test'],
        root: Directory.systemTemp.path,
        out: out,
        err: StringBuffer(),
      );

      expect(code, 0, reason: out.toString());
      expect(out.toString(), matches(RegExp(r'domain +1 +2/2 +100\.0%')));
    });
  });

  group('stops with exit 2', () {
    void refuses(_Project project, List<String> args, String message) {
      final result = project.gate(args);
      expect(result.code, 2, reason: result.out);
      expect(result.out, isEmpty);
      expect(result.err, contains(message));
    }

    test('without lcov report', () {
      final project = _covered();
      File('${project.root.path}/coverage/lcov.info').deleteSync();
      refuses(project, [
        '--test-dir',
        'test/unit',
      ], 'coverage/lcov.info not found - fix: make test-coverage first');
    });

    test('without package config', () {
      final project = _covered();
      File('${project.root.path}/.dart_tool/package_config.json').deleteSync();
      refuses(project, [
        '--test-dir',
        'test/unit',
      ], 'package_config.json not found - fix: make install first');
    });

    test('with a package config that is not one', () {
      refuses(_covered()..packageConfig('[]'), [
        '--test-dir',
        'test/unit',
      ], 'cannot read .dart_tool/package_config.json (no "packages" list)');
    });

    test('without --test-dir', () {
      refuses(_covered(), [], 'at least one --test-dir is needed');
    });

    test('with a --test-dir that does not exist', () {
      refuses(_covered(), [
        '--test-dir',
        'test/nowhere',
      ], '--test-dir test/nowhere is not a directory');
    });

    test('with an absolute --test-dir', () {
      final project = _covered();
      final absolute = '${project.root.path}/test/unit';
      refuses(project, [
        '--test-dir',
        absolute,
      ], '--test-dir $absolute must be relative to the project root');
    });

    test('with an unknown or incomplete argument', () {
      refuses(_covered(), [
        '--test-dir',
        'test/unit',
        '--html',
      ], 'unknown or incomplete argument "--html"\nusage:');
      refuses(_covered(), ['--lcov'], 'unknown or incomplete argument');
    });
  });
}
