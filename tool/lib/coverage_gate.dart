// The coverage gate of `make ci` (architecture §8, D15), behind
// tool/coverage_gate.dart.
//
// `flutter test --coverage` leaves out of lcov.info every library no test
// loads, and the libraries without executable line (abstract interfaces,
// enums, typedefs, constants, exports). So the gate lists every Dart file of
// lib/ and tool/ itself and decides per file:
//
//   in lcov.info                          its lines hit / found;
//   absent, reachable from a test         "no executable lines" (passes);
//   absent, reachable from no test        "not loaded by any test", 0%.
//
// A test reaches a file through import / export / part directives (relative
// or `package:` URIs of the project's own packages), starting from the
// `*_test.dart` files of the --test-dir folders.
//
// It fails on a gated file below 100% (its uncovered lines are listed), a
// gated file no test loads, a coverage ignore comment in a gated file
// (CLAUDE.md §4) and a file outside the D15 layout. SDK libraries only.

import 'dart:io';

import 'package:kiveto_tool/dart_source.dart';

const _passed = 0;
const _failed = 1;
const _usageError = 2;

/// The prefix of package:coverage's ignore comments (`-line`, `-start`,
/// `-end`, `-file`), split so that this gated file does not contain it.
const _ignoreMarker =
    'coverage'
    ':ignore';

const _usage =
    'usage: dart tool/coverage_gate.dart --test-dir <dir> [--test-dir <dir>]'
    ' [--lcov <file>] [--root <dir>]\n'
    '  --test-dir  a folder of *_test.dart files run by the coverage run'
    ' (repeatable, at least one)\n'
    '  --lcov      the lcov report (default: coverage/lcov.info)\n'
    '  --root      the project root (default: the current directory)\n'
    'Relative paths are relative to the project root.';

/// The declared exclusions: pattern, reason, test.
final List<(String, String, bool Function(String path))> _exclusions = [
  ('lib/main.dart', 'entry point', (path) => path == 'lib/main.dart'),
  (
    'lib/l10n/app_localizations*.dart',
    'gen-l10n output',
    (path) =>
        path.startsWith('lib/l10n/app_localizations') &&
        path.split('/').length == 3,
  ),
  (
    'tool/*.dart',
    'thin entry points over tool/lib/, run by the make targets and '
        'test/scripts/',
    (path) => path.startsWith('tool/') && path.split('/').length == 2,
  ),
];

/// Where a file sits in the D15 layout.
typedef _Place = ({String area, String layer, bool gated});

/// Runs the gate on the project at [root] (or `--root`), writes its report
/// to [out] and its usage errors to [err], and returns the exit code: 0
/// passed, 1 failed, 2 usage error or missing input.
int runCoverageGate(
  List<String> args, {
  required String root,
  required StringSink out,
  required StringSink err,
}) {
  var base = root;
  var lcov = 'coverage/lcov.info';
  final testDirectories = <String>[];
  for (var i = 0; i < args.length; i++) {
    final value = i + 1 < args.length ? args[i + 1] : null;
    switch (args[i]) {
      case '--lcov' when value != null:
        lcov = value;
        i++;
      case '--test-dir' when value != null:
        testDirectories.add(value);
        i++;
      case '--root' when value != null:
        base = value;
        i++;
      default:
        return _usageFailure(
          err,
          'unknown or incomplete argument "${args[i]}"\n$_usage',
        );
    }
  }
  if (testDirectories.isEmpty) {
    return _usageFailure(err, 'at least one --test-dir is needed\n$_usage');
  }

  final lcovFile = File(_inside(base, lcov));
  if (!lcovFile.existsSync()) {
    return _usageFailure(
      err,
      '$lcov not found - fix: make test-coverage first',
    );
  }
  if (!File('$base/.dart_tool/package_config.json').existsSync()) {
    return _usageFailure(
      err,
      '.dart_tool/package_config.json not found - fix: make install first',
    );
  }
  for (final directory in testDirectories) {
    if (File(directory).isAbsolute) {
      return _usageFailure(
        err,
        '--test-dir $directory must be relative to the project root',
      );
    }
    if (!Directory('$base/$directory').existsSync()) {
      return _usageFailure(err, '--test-dir $directory is not a directory');
    }
  }
  final Map<String, String> packages;
  try {
    packages = readPackageConfig(base);
  } on FormatException catch (error) {
    return _usageFailure(
      err,
      'cannot read .dart_tool/package_config.json (${error.message}) - '
      'fix: make install',
    );
  }

  return _Gate(
    root: base,
    packages: packages,
    coverage: _parseLcov(lcovFile.readAsLinesSync(), _rootPrefix(base)),
    out: out,
  ).run(testDirectories);
}

int _usageFailure(StringSink err, String message) {
  err.writeln('coverage gate: $message');
  return _usageError;
}

/// [path] when it is absolute, else [path] under [root].
String _inside(String root, String path) =>
    File(path).isAbsolute ? path : '$root/$path';

/// The absolute path of [root], `/`-separated, with a trailing `/`.
String _rootPrefix(String root) =>
    Directory(root).absolute.uri
        .normalizePath()
        .toFilePath()
        .replaceAll(r'\', '/');

/// The hits per line of each file of an lcov report, by project-relative
/// path (`\` becomes `/`; absolute paths under [rootPrefix] are made
/// relative).
Map<String, Map<int, int>> _parseLcov(List<String> lines, String rootPrefix) {
  final files = <String, Map<int, int>>{};
  var current = <int, int>{};
  for (final line in lines) {
    if (line.startsWith('SF:')) {
      var path = line.substring(3).trim().replaceAll(r'\', '/');
      if (path.startsWith(rootPrefix)) {
        path = path.substring(rootPrefix.length);
      }
      current = files.putIfAbsent(path, () => {});
    } else if (line.startsWith('DA:')) {
      final fields = line.substring(3).split(',');
      final number = int.parse(fields[0]);
      current[number] = (current[number] ?? 0) + int.parse(fields[1].trim());
    }
  }
  return files;
}

/// The area, layer and threshold of a project-relative path, or null when
/// it is outside the D15 layout.
_Place? _placeOf(String path) {
  final s = path.split('/');
  final file = s.length;
  if (s[0] == 'tool') {
    return file > 2 && s[1] == 'lib'
        ? (area: 'tool', layer: 'lib', gated: true)
        : null;
  }
  if (file < 3) return null;
  switch (s[1]) {
    case 'features' when file > 3:
      final feature = s[2];
      if (file == 4 && (s[3] == 'di.dart' || s[3] == '$feature.dart')) {
        return (area: 'features/$feature', layer: s[3], gated: false);
      }
      if (file == 4) return null;
      return switch (s[3]) {
        'domain' || 'application' || 'infrastructure' => (
          area: 'features/$feature',
          layer: s[3],
          gated: true,
        ),
        'presentation' => (
          area: 'features/$feature',
          layer: s[3],
          gated: false,
        ),
        _ => null,
      };
    case 'shared' when file > 3:
      return switch (s[2]) {
        'domain' => (area: 'shared', layer: 'domain', gated: true),
        'presentation' => (area: 'shared', layer: 'presentation', gated: false),
        _ => null,
      };
    case 'core' when file > 3:
      return switch (s[2]) {
        'network' ||
        'security' ||
        'errors' => (area: 'core', layer: s[2], gated: true),
        'di' => (area: 'core', layer: 'di', gated: false),
        _ => null,
      };
    case 'app' when file == 3:
      return (area: 'app', layer: '(files)', gated: false);
    case 'app':
      return switch (s[2]) {
        'bootstrap' ||
        'routing' ||
        'theme' => (area: 'app', layer: s[2], gated: false),
        _ => null,
      };
  }
  return null;
}

/// One file's result.
final class _FileResult {
  new(this.path, this.place, {required this.hit, required this.found});

  final String path;
  final _Place place;
  final int hit;
  final int found;
}

/// One row of the table.
final class _Row {
  new(this.area, this.layer, {required this.gated});

  final String area;
  final String layer;
  final bool gated;
  int files = 0;
  int hit = 0;
  int found = 0;
}

final class _Gate {
  new({
    required this.root,
    required this.packages,
    required this.coverage,
    required this.out,
  });

  final String root;
  final Map<String, String> packages;
  final Map<String, Map<int, int>> coverage;
  final StringSink out;

  final Map<String, DartSource> _sources = {};
  final List<String> _failures = [];
  final List<String> _notes = [];

  DartSource _source(String path) => _sources.putIfAbsent(
    path,
    () => DartSource(File('$root/$path').readAsStringSync()),
  );

  int run(List<String> testDirectories) {
    final files = [
      ...listDartFiles(root, 'lib'),
      ...listDartFiles(root, 'tool'),
    ];
    final reachable = _reachable([
      for (final directory in testDirectories)
        for (final file in listDartFiles(root, directory))
          if (file.endsWith('_test.dart')) file,
    ]);

    out
      ..writeln('Coverage gate: every Dart file of lib/ and tool/')
      ..writeln()
      ..writeln('Declared exclusions:');
    final counted = <String>[];
    final width = _exclusions
        .map((exclusion) => exclusion.$1.length)
        .reduce(_max);
    for (final (pattern, reason, test) in _exclusions) {
      final matched = files.where(test).toList();
      counted.addAll(matched);
      out.writeln('  ${pattern.padRight(width)} $reason (${matched.length})');
    }

    final results = [
      for (final path in files)
        if (!counted.contains(path)) ?_check(path, reachable),
    ];
    _checkPackagesMeasured(results, reachable);
    _table(results);

    if (_notes.isNotEmpty) {
      out
        ..writeln()
        ..writeln('Notes:');
      _notes.forEach(_line);
    }
    out.writeln();
    if (_failures.isEmpty) {
      final gated = results.where((r) => r.place.gated).length;
      out.writeln('✓ Coverage gate passed: $gated gated file(s) at 100%');
      return _passed;
    }
    out.writeln('Failures:');
    _failures.forEach(_line);
    out
      ..writeln()
      ..writeln('✗ Coverage gate failed: ${_failures.length} problem(s)');
    return _failed;
  }

  void _line(String text) => out.writeln('  $text');

  /// A project package whose gated files tests load must have records in
  /// lcov.info: without its --coverage-package, flutter test records none
  /// of its files and every one of them would pass as "no executable
  /// lines".
  void _checkPackagesMeasured(
    List<_FileResult> results,
    Set<String> reachable,
  ) {
    for (final MapEntry(key: name, value: directory) in packages.entries) {
      final prefix = '$directory/';
      final loaded = results.any(
        (result) =>
            result.place.gated &&
            result.path.startsWith(prefix) &&
            reachable.contains(result.path),
      );
      if (loaded && !coverage.keys.any((path) => path.startsWith(prefix))) {
        _failures.add(
          '$prefix: no record in lcov.info for package:$name, although '
          'tests load its gated files - fix: keep '
          '--coverage-package=$name in the flutter test command of '
          'scripts/test.sh',
        );
      }
    }
  }

  /// The project files reached from [roots] through their directives.
  Set<String> _reachable(List<String> roots) {
    final seen = <String>{};
    final pending = [...roots];
    while (pending.isNotEmpty) {
      final path = pending.removeLast();
      if (!seen.add(path)) continue;
      for (final directive in _source(path).directives) {
        for (final uri in directive.uris) {
          if (resolveUri(uri, from: path, packages: packages)
              case ProjectFile(path: final target)
              when File('$root/$target').existsSync()) {
            pending.add(target);
          }
        }
      }
    }
    return seen;
  }

  _FileResult? _check(String path, Set<String> reachable) {
    final place = _placeOf(path);
    if (place == null) {
      _failures.add(
        '$path: outside the D15 layout (architecture §6): move it under '
        'lib/features/<feature>/<layer>/ (domain, application, '
        'infrastructure, presentation), lib/features/<feature>/di.dart or '
        '<feature>.dart, lib/shared/{domain,presentation}/, '
        'lib/core/{network,security,errors,di}/, '
        'lib/app/{bootstrap,routing,theme}/ (or directly under lib/app/), '
        'or tool/lib/',
      );
      return null;
    }
    if (place.gated) {
      final source = _source(path);
      final ignores = [
        for (final match in _ignoreMarker.allMatches(source.text))
          source.lineAt(match.start),
      ];
      if (ignores.isNotEmpty) {
        _failures.add(
          '$path: $_ignoreMarker on line ${ignores.join(', ')} - forbidden '
          'in a gated layer (CLAUDE.md §4): test the code instead',
        );
      }
    }

    final hits = coverage[path];
    if (hits != null) {
      final uncovered = [
        for (final MapEntry(:key, :value) in hits.entries)
          if (value == 0) key,
      ]..sort();
      final result = _FileResult(
        path,
        place,
        hit: hits.length - uncovered.length,
        found: hits.length,
      );
      if (place.gated && uncovered.isNotEmpty) {
        _failures.add(
          '$path: ${result.hit}/${result.found} lines '
          '(${_percent(result.hit, result.found)}), uncovered lines: '
          '${uncovered.join(', ')}',
        );
      }
      return result;
    }
    if (reachable.contains(path)) {
      _notes.add('$path: no executable lines (loaded by a test)');
      return _FileResult(path, place, hit: 0, found: 0);
    }
    final message = '$path: not loaded by any test (0%)';
    if (place.gated) {
      _failures.add(message);
    } else {
      _notes.add('$message, measured without threshold');
    }
    return _FileResult(path, place, hit: 0, found: _estimate(path));
  }

  /// The lines of a file no test loads, estimated: neither blank, nor
  /// comment, nor directive.
  int _estimate(String path) {
    final source = _source(path);
    final directiveLines = {
      for (final directive in source.directives)
        for (var line = directive.line; line <= directive.endLine; line++) line,
    };
    final lines = source.code.split('\n');
    var count = 0;
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].trim().isNotEmpty && !directiveLines.contains(i + 1)) {
        count++;
      }
    }
    return count;
  }

  void _table(List<_FileResult> results) {
    final rows = <String, _Row>{};
    for (final result in results) {
      final place = result.place;
      rows.putIfAbsent(
          '${place.area} ${place.layer}',
          () => _Row(place.area, place.layer, gated: place.gated),
        )
        ..files += 1
        ..hit += result.hit
        ..found += result.found;
    }
    final sorted = rows.keys.toList()..sort();
    final table = [
      ['area', 'layer', 'files', 'lines hit/found', 'cover', 'threshold'],
      for (final key in sorted)
        [
          rows[key]!.area,
          rows[key]!.layer,
          '${rows[key]!.files}',
          '${rows[key]!.hit}/${rows[key]!.found}',
          _percent(rows[key]!.hit, rows[key]!.found),
          if (rows[key]!.gated) '100%' else '–',
        ],
    ];
    final widths = [
      for (var column = 0; column < table.first.length; column++)
        table.map((row) => row[column].length).reduce(_max),
    ];
    out.writeln();
    for (final row in table) {
      out.writeln(
        [
          for (var column = 0; column < row.length; column++)
            if (column < 2)
              row[column].padRight(widths[column])
            else
              row[column].padLeft(widths[column]),
        ].join('  ').trimRight(),
      );
    }
  }
}

int _max(int a, int b) => a > b ? a : b;

/// [hit] out of [found] as a percentage truncated to one decimal (99.96%
/// shows as 99.9%, never as 100.0%); `–` when there is no line.
String _percent(int hit, int found) =>
    found == 0 ? '–' : '${(hit * 1000 ~/ found) / 10}%';
