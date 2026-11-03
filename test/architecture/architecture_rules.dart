// The D15 dependency rules of lib/ (architecture §3 and §10, CLAUDE.md §3),
// checked on the import, export and part directives of every Dart file, in
// the style of the backend's tests/Unit/Architecture/: collect the
// offences, then assert there is none.
//
// Paths are relative to lib/. A directive's targets inside lib/ come from
// relative URIs and `package:kiveto_mobile/` ones; `dart:` libraries and
// other packages keep their name. Every rule is checked on its own: one
// import may break several.

import 'dart:io';

import 'package:kiveto_tool/dart_source.dart';

/// What each rule protects, by number (the test names).
const ruleTitles = <int, String>{
  1: 'features/*/domain/ and shared/domain/ are pure Dart',
  2: 'features/*/application/ reaches only its domain and shared/domain/',
  3: 'presentation never reaches infrastructure, Dio or the API client',
  4: "only the composition files import a feature's infrastructure/",
  5: 'features meet through their public API, without cycle',
  6: 'core/ and shared/ import no feature; shared/ no core/ or app/',
  7:
      'kiveto_portal_api and tonik_util only in infrastructure, core/network/, '
      'core/di/',
  8: 'no DateTime.now/timestamp, print, coverage ignore in domain, application',
};

/// A broken rule, with its message:
/// `[rule N] lib/<path>:<line> imports <uri> — <what is allowed> (…)`.
final class Offence {
  const new(this.rule, this.message);

  final int rule;
  final String message;

  @override
  String toString() => message;
}

const _source = '(architecture §3, D15)';
const _pureDart = 'dart:core, dart:async, dart:collection, dart:math';
const _packages = {'kiveto_mobile': 'lib'};

/// Split so that this file does not hold the marker itself.
const _ignoreMarker =
    'coverage'
    ':ignore';

/// Both read the wall clock (tear-offs included).
final _dateTimeNow = RegExp(r'\bDateTime\s*\.\s*(now|timestamp)\b');
final _print = RegExp(r'(?<![\w$.])print\s*\(');

/// Checks every rule on `<root>/lib/**/*.dart`.
List<Offence> checkArchitecture(String root) {
  final offences = <Offence>[];
  final edges = <(String, String), _Import>{};
  for (final file in listDartFiles(root, 'lib')) {
    final from = _LibPath(file.substring(4));
    final source = DartSource(File('$root/$file').readAsStringSync());
    for (final directive in source.directives) {
      for (final uri in directive.uris) {
        final import = _Import(from, directive.line, uri);
        final target = _Target(
          resolveUri(uri, from: file, packages: _packages),
        );
        _checkImport(import, target, offences);
        final (fromFeature, toFeature) = (from.feature, target.path?.feature);
        if (fromFeature != null &&
            toFeature != null &&
            fromFeature != toFeature) {
          edges.putIfAbsent((fromFeature, toFeature), () => import);
        }
      }
    }
    _checkTokens(from, source, offences);
  }
  offences.addAll(_cycles(edges));
  return offences;
}

/// A `/`-separated path relative to lib/.
final class _LibPath {
  new(this.path) : _segments = path.split('/');

  final String path;
  final List<String> _segments;

  bool under(String directory) => path.startsWith('$directory/');

  /// `<f>` for `features/<f>/…` (a file or a folder of the feature).
  String? get feature =>
      _segments.length > 2 && _segments[0] == 'features' ? _segments[1] : null;

  /// `domain` for `features/<f>/domain/…`, null elsewhere.
  String? get layer =>
      feature != null && _segments.length > 3 ? _segments[2] : null;

  bool inLayer(String layer) => this.layer == layer;

  /// `features/<f>/<f>.dart`.
  bool get isPublicApi =>
      feature != null &&
      _segments.length == 3 &&
      _segments[2] == '${_segments[1]}.dart';

  /// `features/<f>/di.dart`.
  bool get isFeatureDi =>
      feature != null && _segments.length == 3 && _segments[2] == 'di.dart';
}

/// What a URI points to, seen from lib/.
final class _Target {
  new(UriTarget target)
    : path = switch (target) {
        ProjectFile(:final path) when path.startsWith('lib/') => _LibPath(
          path.substring(4),
        ),
        _ => null,
      },
      dartLibrary = switch (target) {
        DartLibrary(:final name) => name,
        _ => null,
      },
      package = switch (target) {
        ExternalPackage(:final name) => name,
        _ => null,
      };

  /// The file under lib/, if any.
  final _LibPath? path;
  final String? dartLibrary;
  final String? package;

  bool get isPureDart =>
      const {'core', 'async', 'collection', 'math'}.contains(dartLibrary);

  bool under(String directory) => path?.under(directory) ?? false;

  /// The forbidden family of an application/ import, if it is one.
  String? get family => switch ((package, dartLibrary)) {
    (final String name, _) when name.contains('riverpod') => 'Riverpod',
    ('flutter' || 'flutter_test' || 'flutter_localizations', _) => 'Flutter',
    (_, 'ui') => 'Flutter',
    ('dio', _) => 'Dio',
    ('kiveto_portal_api', _) => 'kiveto_portal_api',
    ('tonik_util', _) => 'tonik_util',
    _ when under('core') => 'core/',
    _ => null,
  };
}

/// One URI of a directive.
final class _Import {
  const new(this.from, this.line, this.uri);

  final _LibPath from;
  final int line;
  final String uri;

  String get site => 'lib/${from.path}:$line';

  Offence offence(int rule, String allowed, {String? family}) => Offence(
    rule,
    '[rule $rule] $site imports $uri${family == null ? '' : ' ($family)'} '
    '— $allowed $_source',
  );
}

void _checkImport(_Import import, _Target target, List<Offence> offences) {
  final from = import.from;
  final feature = from.feature;

  // Rule 1: the domains are pure Dart.
  final featureDomain = from.inLayer('domain');
  if (featureDomain || from.under('shared/domain')) {
    final own = featureDomain ? 'features/$feature/domain' : 'shared/domain';
    if (!target.isPureDart &&
        !target.under(own) &&
        !target.under('shared/domain')) {
      offences.add(
        import.offence(
          1,
          featureDomain
              ? '$own/ may import only $_pureDart, its own domain and '
                    'shared/domain/'
              : 'shared/domain/ may import only $_pureDart and itself',
        ),
      );
    }
  }

  // Rule 2: application/ adds its own domain and application.
  if (from.inLayer('application') &&
      !target.isPureDart &&
      !target.under('features/$feature/domain') &&
      !target.under('features/$feature/application') &&
      !target.under('shared/domain')) {
    offences.add(
      import.offence(
        2,
        'features/$feature/application/ may import only $_pureDart, its '
        'own domain and application, and shared/domain/: no Flutter, '
        'Riverpod, Dio, kiveto_portal_api, tonik_util or core/',
        family: target.family,
      ),
    );
  }

  // Rule 3: presentation stays away from the data side.
  if ((from.inLayer('presentation') || from.under('shared/presentation')) &&
      (target.path?.path.split('/').contains('infrastructure') == true ||
          target.package == 'dio' ||
          target.package == 'kiveto_portal_api' ||
          target.under('core/network') ||
          target.under('core/security'))) {
    offences.add(
      import.offence(
        3,
        'presentation reaches data through application/, domain/ and the '
        "providers of di.dart, never a feature's infrastructure/, Dio, "
        'kiveto_portal_api, core/network/ or core/security/',
      ),
    );
  }

  // Rule 4: a feature's infrastructure/ is wired by the composition files.
  final targetPath = target.path;
  if (targetPath != null &&
      targetPath.inLayer('infrastructure') &&
      !from.isFeatureDi &&
      !from.under('core/di') &&
      !from.under('app/bootstrap') &&
      !(from.inLayer('infrastructure') && feature == targetPath.feature)) {
    offences.add(
      import.offence(
        4,
        "a feature's infrastructure/ is imported only by its own "
        'infrastructure/, features/*/di.dart, core/di/, app/bootstrap/ and '
        'tests',
      ),
    );
  }

  // Rule 5: another feature only through its public API.
  final other = targetPath?.feature;
  if (feature != null &&
      other != null &&
      other != feature &&
      !targetPath!.isPublicApi) {
    offences.add(
      import.offence(
        5,
        'features/$feature/ reaches another feature only through its public '
        'API, features/$other/$other.dart',
      ),
    );
  }

  // Rule 6: the kernels depend on no feature, shared/ on nothing technical.
  if ((from.under('core') || from.under('shared')) &&
      target.under('features')) {
    offences.add(import.offence(6, 'core/ and shared/ import no feature'));
  }
  if (from.under('shared') && (target.under('core') || target.under('app'))) {
    offences.add(
      import.offence(6, 'shared/ imports nothing from core/ or app/'),
    );
  }

  // Rule 7: the generated client and its runtime stay in the data side.
  final client = target.package;
  if ((client == 'kiveto_portal_api' || client == 'tonik_util') &&
      !from.inLayer('infrastructure') &&
      !from.under('core/network') &&
      !from.under('core/di')) {
    offences.add(
      import.offence(
        7,
        '$client is imported only under '
        'features/*/infrastructure/, core/network/ and core/di/',
      ),
    );
  }
}

/// Rule 8, on the text of the domains and applications.
void _checkTokens(_LibPath from, DartSource source, List<Offence> offences) {
  if (!from.inLayer('domain') &&
      !from.inLayer('application') &&
      !from.under('shared/domain')) {
    return;
  }
  void add(int offset, String token, String allowed) => offences.add(
    Offence(
      8,
      '[rule 8] lib/${from.path}:${source.lineAt(offset)} uses $token '
      '— $allowed $_source',
    ),
  );
  for (final match in _dateTimeNow.allMatches(source.code)) {
    add(
      match.start,
      'DateTime.${match[1]}',
      'domain and application read the time from the injected Clock of '
          'shared/domain/',
    );
  }
  for (final match in _print.allMatches(source.code)) {
    add(
      match.start,
      'print(',
      'domain and application do not print: they return values or '
          'failures',
    );
  }
  for (final match in _ignoreMarker.allMatches(source.text)) {
    add(
      match.start,
      _ignoreMarker,
      'domain and application stay at 100% line coverage without ignore '
      'comments (CLAUDE.md §4)',
    );
  }
}

/// Rule 5's cycles: each elementary cycle of the feature graph once,
/// starting from its smallest feature, with the first import of each edge.
List<Offence> _cycles(Map<(String, String), _Import> edges) {
  final graph = <String, List<String>>{};
  for (final (from, to) in edges.keys) {
    (graph[from] ??= []).add(to);
  }
  final offences = <Offence>[];
  final starts = graph.keys.toList()..sort();
  for (final start in starts) {
    void visit(List<String> path) {
      for (final next in [...?graph[path.last]]..sort()) {
        if (next == start) {
          final cycle = [...path, start];
          final sites = [
            for (var i = 0; i < path.length; i++)
              edges[(cycle[i], cycle[i + 1])]!,
          ];
          offences.add(
            Offence(
              5,
              '[rule 5] feature cycle ${cycle.join(' → ')}: '
              '${sites.map((s) => '${s.site} imports ${s.uri}').join('; ')} '
              '— the feature graph stays acyclic: move what both need to '
              'shared/domain/ or invert the dependency $_source',
            ),
          );
        } else if (next.compareTo(start) > 0 && !path.contains(next)) {
          visit([...path, next]);
        }
      }
    }

    visit([start]);
  }
  return offences;
}
