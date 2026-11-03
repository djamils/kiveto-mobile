// The contract normaliser of `make api-generate`, behind
// tool/normalize_contract.dart (architecture §4).
//
// The backend's OpenAPI document declares no `required` on the schemas it
// answers with, although its success bodies carry every key (`null`
// included): a generator would type every response field as optional. Its
// problem+json bodies omit some nullable keys (`detail`, `instance`), which
// still decode: the client reads a missing nullable key as null. This writes a
// build copy of the contract where every response-only schema lists all its
// properties in `required`. Nullability (`type: [T, 'null']`, `anyOf` with
// `type: 'null'`) is kept: a nullable field stays nullable, it is only
// always present.
//
// Response-only schemas are the schemas reachable (through `$ref`,
// transitively) from the `responses` of an operation and from no
// `requestBody` or `parameters`: request schemas are never touched (a
// merge-patch body must stay all-optional). The `required:` list is
// inserted as text right after the schema's `type: object` line, so that
// nothing else of the document changes; running it again changes nothing.
//
// Before rewriting, it checks that tool/api_generator/tonik.yaml gives a
// readable name to every operationId, tag and dotted schema of the
// contract (tonik would otherwise derive one from the route or concatenate
// the parts).
//
// The only file of package:kiveto_tool using package:yaml (tool/pubspec.yaml).

import 'dart:io';

import 'package:yaml/yaml.dart';

const _done = 0;
const _failed = 1;
const _usageError = 64;

const _usage =
    'usage: dart tool/normalize_contract.dart <contract> <tonik.yaml> <out>\n'
    '  <contract>    the OpenAPI document (contracts/portal.v1.yaml)\n'
    '  <tonik.yaml>  the generator configuration and its nameOverrides\n'
    '  <out>         the normalised copy to write (its folders are created)';

/// The operation keys of an OpenAPI 3.2 path item.
const _methods = {
  'get',
  'put',
  'post',
  'delete',
  'options',
  'head',
  'patch',
  'trace',
  'query',
};

const _schemaRef = '#/components/schemas/';

/// A property name written as a plain YAML scalar in the `required:` list;
/// any other one is single-quoted.
final _plainName = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');

/// Plain scalars YAML reads as something else than a string.
const _reservedWords = {'true', 'false', 'null', 'yes', 'no', 'on', 'off'};

/// A schema key line of `components.schemas` (4 spaces, a key, a colon).
final _schemaKey = RegExp(r'^    (\S.*?):\s*$');

/// A contract the normaliser refuses, with the reason and the fix.
final class NormalizationException implements Exception {
  const new(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The normalised contract and what changed.
final class NormalizedContract {
  const new({
    required this.text,
    required this.rewritten,
    required this.declared,
    required this.requestSchemas,
  });

  /// The normalised document.
  final String text;

  /// The response-only schemas that got a `required:` list.
  final Set<String> rewritten;

  /// The response-only schemas that already declared `required`.
  final Set<String> declared;

  /// The schemas reachable from a request body or a parameter, left alone.
  final Set<String> requestSchemas;
}

/// Runs the normaliser: `<contract> <tonik.yaml> <out>` (paths as given,
/// relative to the current directory). Writes its summary to [out] and its
/// errors to [err]; returns 0 when the copy is written, 1 when the contract
/// is refused, 64 on a usage error.
int runNormalizeContract(
  List<String> args, {
  required StringSink out,
  required StringSink err,
}) {
  if (args.length != 3) {
    err.writeln(_usage);
    return _usageError;
  }
  final [contractPath, configPath, outPath] = args;
  for (final path in [contractPath, configPath]) {
    if (!File(path).existsSync()) {
      err.writeln('$path not found');
      return _failed;
    }
  }

  final NormalizedContract result;
  try {
    result = normalizeContract(
      File(contractPath).readAsStringSync(),
      File(configPath).readAsStringSync(),
      configName: configPath,
    );
  } on NormalizationException catch (error) {
    err.writeln(error.message);
    return _failed;
  }
  File(outPath)
    ..createSync(recursive: true)
    ..writeAsStringSync(result.text);
  out.writeln(
    'required added to ${result.rewritten.length} response-only schemas '
    '(${result.declared.length} already declared it; request schemas '
    'untouched: ${result.requestSchemas.length})',
  );
  return _done;
}

/// Normalises [contract] (see the top of this file) after checking the
/// names of [tonikConfig], whose path [configName] the messages show.
///
/// Throws a [NormalizationException] when a document is not valid YAML,
/// when a contract item has no readable name, or when a selected schema
/// cannot be rewritten.
NormalizedContract normalizeContract(
  String contract,
  String tonikConfig, {
  String configName = 'tonik.yaml',
}) {
  final document = _map(_load(contract, 'the contract'));
  final config = _map(_load(tonikConfig, configName));
  _checkNames(document, _map(config['nameOverrides']), configName);

  final components = _map(document['components']);
  final schemas = _map(components['schemas']);
  final requestRoots = <String>{};
  final responseRoots = <String>{};
  for (final operation in _operations(document)) {
    requestRoots
      ..addAll(_refs(operation['requestBody']))
      ..addAll(_refs(operation['parameters']));
    responseRoots.addAll(_refs(operation['responses']));
  }
  for (final item in _map(document['paths']).values) {
    requestRoots.addAll(_refs(_map(item)['parameters']));
  }

  final requests = _schemaNames(_closure(requestRoots, components));
  final responseOnly = _schemaNames(_closure(responseRoots, components))
      .difference(requests);

  final targets = <String, List<String>>{};
  final declared = <String>{};
  for (final name in responseOnly) {
    final schema = _map(schemas[name]);
    final properties = _map(schema['properties']);
    if (schema.containsKey('required')) {
      declared.add(name);
    } else if (properties.isNotEmpty) {
      targets[name] = [for (final key in properties.keys) '$key'];
    }
  }

  return NormalizedContract(
    text: _insertRequired(contract, targets),
    rewritten: targets.keys.toSet(),
    declared: declared,
    requestSchemas: requests,
  );
}

Object? _load(String text, String name) {
  try {
    return loadYaml(text);
  } on YamlException catch (error) {
    throw NormalizationException('$name is not valid YAML: $error');
  }
}

Map<Object?, Object?> _map(Object? node) =>
    node is Map<Object?, Object?> ? node : const {};

/// Every operation of the document's `paths`.
Iterable<Map<Object?, Object?>> _operations(Map<Object?, Object?> document) => [
  for (final item in _map(document['paths']).values)
    for (final MapEntry(:key, :value) in _map(item).entries)
      if (_methods.contains(key)) _map(value),
];

/// The names guard: every operationId, tag and dotted schema of the
/// contract must have an entry in [overrides].
void _checkNames(
  Map<Object?, Object?> document,
  Map<Object?, Object?> overrides,
  String configName,
) {
  final operations = _operations(document);
  final items = <String, Set<String>>{
    'operations': {
      for (final operation in operations)
        if (operation['operationId'] case final String id) id,
    },
    'tags': {
      for (final operation in operations)
        if (operation['tags'] case final List<Object?> tags)
          for (final tag in tags) '$tag',
      if (document['tags'] case final List<Object?> tags)
        for (final tag in tags)
          if (_map(tag)['name'] case final String name) name,
    },
    'schemas': {
      for (final name in _map(_map(document['components'])['schemas']).keys)
        if ('$name'.contains('.')) '$name',
    },
  };

  final lines = <String>[];
  for (final MapEntry(key: section, value: names) in items.entries) {
    final named = _map(overrides[section]);
    final missing = names.where((name) => !named.containsKey(name)).toList();
    if (missing.isNotEmpty) {
      lines.add(
        '  nameOverrides.$section: ${missing.join(', ')} - add a readable '
        'name to nameOverrides.$section of $configName',
      );
    }
  }
  if (lines.isNotEmpty) {
    throw NormalizationException(
      'contract items without a readable name (tonik would derive one from '
      'the route or the schema key):\n${lines.join('\n')}',
    );
  }
}

/// The `$ref` values found under [node].
Set<String> _refs(Object? node) {
  final refs = <String>{};
  void walk(Object? value) {
    if (value is Map<Object?, Object?>) {
      if (value[r'$ref'] case final String ref) refs.add(ref);
      value.values.forEach(walk);
    } else if (value is List<Object?>) {
      value.forEach(walk);
    }
  }

  walk(node);
  return refs;
}

/// Every `#/components/...` reference reached from [roots], transitively.
Set<String> _closure(Set<String> roots, Map<Object?, Object?> components) {
  final seen = <String>{};
  final pending = [...roots];
  while (pending.isNotEmpty) {
    final ref = pending.removeLast();
    if (seen.add(ref)) pending.addAll(_refs(_component(ref, components)));
  }
  return seen;
}

/// The component a `#/components/<section>/<name>` reference points to.
Object? _component(String ref, Map<Object?, Object?> components) {
  const prefix = '#/components/';
  if (!ref.startsWith(prefix)) return null;
  final [section, ...name] = ref.substring(prefix.length).split('/');
  return _map(components[section])[_unescape(name.join('/'))];
}

/// The schema names among [refs].
Set<String> _schemaNames(Set<String> refs) => {
  for (final ref in refs)
    if (ref.startsWith(_schemaRef)) _unescape(ref.substring(_schemaRef.length)),
};

/// A JSON pointer segment, unescaped.
String _unescape(String segment) =>
    segment.replaceAll('~1', '/').replaceAll('~0', '~');

/// Inserts a `required:` list right after the `type: object` line of each
/// schema of [targets], inside `components.schemas` only.
String _insertRequired(String contract, Map<String, List<String>> targets) {
  final pending = {...targets};
  final result = <String>[];
  var inComponents = false;
  var inSchemas = false;
  String? schema;
  for (final line in contract.split('\n')) {
    result.add(line);
    // A CRLF document keeps its line endings, inserted lines included.
    final end = line.endsWith('\r') ? '\r' : '';
    final content = line.trimLeft();
    if (content.isEmpty || content.startsWith('#')) continue;
    switch (line.length - content.length) {
      case 0:
        inComponents = line.trimRight() == 'components:';
        inSchemas = false;
        schema = null;
      case 2 when inComponents:
        inSchemas = line.trimRight() == '  schemas:';
        schema = null;
      case 4 when inSchemas:
        schema = _key(line);
      case 6 when line == '      type: object$end':
        if (pending.remove(schema) case final List<String> properties) {
          result
            ..add('      required:$end')
            ..addAll([
              for (final name in properties) '        - ${_scalar(name)}$end',
            ]);
        }
    }
  }
  if (pending.isNotEmpty) {
    final names = pending.keys.toList()..sort();
    throw NormalizationException(
      'cannot add `required` to the response-only schemas '
      '${names.join(', ')}: no "      type: object" line right under their '
      'key in components.schemas',
    );
  }
  return result.join('\n');
}

/// The schema name of a `components.schemas` key line, unquoted; null when
/// the line holds more than a key.
String? _key(String line) {
  final key = _schemaKey.firstMatch(line)?[1];
  if (key == null || key.length < 2) return key;
  if (key.startsWith("'") && key.endsWith("'")) {
    return key.substring(1, key.length - 1).replaceAll("''", "'");
  }
  if (key.startsWith('"') && key.endsWith('"')) {
    return key
        .substring(1, key.length - 1)
        .replaceAll(r'\"', '"')
        .replaceAll(r'\\', r'\');
  }
  return key;
}

/// [name] as a YAML scalar that reads back as that string.
String _scalar(String name) =>
    _plainName.hasMatch(name) && !_reservedWords.contains(name.toLowerCase())
    ? name
    : "'${name.replaceAll("'", "''")}'";
