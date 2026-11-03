// The Portal API contract commands of `make api-sync`, `make api-generate`
// and `make api-check` (architecture §4, D4, D5), behind
// tool/portal_api.dart. Paths are relative to the repository root.
//
//   sync <backend-dir> <ref>
//       copies openapi/portal.v1.yaml of a local backend checkout, at the
//       commit <ref> names, into contracts/portal.v1.yaml (raw bytes) and
//       writes contracts/SOURCE (repository, path, commit, sha256).
//   stamp
//       writes packages/kiveto_portal_api/CONTRACT after the generator: the
//       contract's sha256 and commit, the tonik version of
//       tool/api_generator/pubspec.lock, a sha256 over the generator inputs
//       and one over the generated files.
//   check
//       recomputes all of it and reports every mismatch, each with the
//       command that fixes it.
//
// SDK libraries only: the SHA-256 is implemented here (FIPS 180-4).

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

const _done = 0;
const _failed = 1;
const _usageError = 64;

const _usage =
    'usage: dart tool/portal_api.dart <command>\n'
    '  sync <backend-dir> <ref>  copy openapi/portal.v1.yaml of the backend '
    'checkout at <ref>\n'
    '                            into contracts/ (make api-sync)\n'
    '  stamp                     write packages/kiveto_portal_api/CONTRACT '
    '(make api-generate)\n'
    '  check                     check the copy, contracts/SOURCE and the '
    'generated client (make api-check)';

const _repository = 'https://github.com/djamils/kiveto';
const _backendContract = 'openapi/portal.v1.yaml';
const _contract = 'contracts/portal.v1.yaml';
const _source = 'contracts/SOURCE';
const _package = 'packages/kiveto_portal_api';
const _stamp = '$_package/CONTRACT';
const _generatorLock = 'tool/api_generator/pubspec.lock';

/// The files whose change calls for a new generation: they decide what the
/// generator writes.
const _generatorInputs = <String>[
  'tool/api_generator/tonik.yaml',
  _generatorLock,
  'tool/lib/contract_normalizer.dart',
];

/// The characters a backend ref may hold (it reaches git, and the make
/// target passes it through cmd.exe on Windows).
final _refPattern = RegExp(r'^[0-9A-Za-z._/][0-9A-Za-z._/-]*$');

const _syncFix = 'make api-sync REF=<sha>';
const _generateFix = 'make api-generate';

/// What a git command printed and returned.
final class GitResult {
  const new(this.exitCode, this.stdout, this.stderr);

  final int exitCode;

  /// The raw bytes of its standard output.
  final List<int> stdout;
  final String stderr;
}

/// Runs `git <args>` in the checkout [dir].
typedef GitRunner = Future<GitResult> Function(String dir, List<String> args);

/// The real git, trusting [dir] for these read-only commands: a WSL
/// checkout seen from Windows belongs to another user (`safe.directory`).
Future<GitResult> processGit(String dir, List<String> args) async {
  final result = await Process.run('git', [
    '-c',
    'safe.directory=*',
    '-C',
    dir,
    ...args,
  ], stdoutEncoding: null);
  return GitResult(
    result.exitCode,
    result.stdout as List<int>,
    '${result.stderr}',
  );
}

/// Runs a command on the repository at [root]; writes its report to [out]
/// and its failures to [err]. Returns 0 on success, 1 on failure, 64 on a
/// usage error.
Future<int> runPortalApi(
  List<String> args, {
  required String root,
  required StringSink out,
  required StringSink err,
  GitRunner git = processGit,
}) async {
  switch (args) {
    case ['sync', final backend, final ref]:
      return await _sync(root, backend, ref, git, out, err);
    case ['stamp']:
      return _writeStamp(root, out, err);
    case ['check']:
      return _check(root, out, err);
    default:
      err.writeln(_usage);
      return _usageError;
  }
}

Future<int> _sync(
  String root,
  String backend,
  String ref,
  GitRunner git,
  StringSink out,
  StringSink err,
) async {
  if (!_refPattern.hasMatch(ref)) {
    err.writeln(
      'REF "$ref" may only hold letters, digits and . _ / - (not first): '
      'a commit SHA, a branch or a tag of the backend',
    );
    return _failed;
  }
  final notCheckout =
      '$backend is not a git checkout of djamils/kiveto - set '
      'KIVETO_BACKEND_DIR to the backend checkout';
  if (!Directory(backend).existsSync() ||
      (await git(backend, ['rev-parse', '--git-dir'])).exitCode != 0) {
    err.writeln(notCheckout);
    return _failed;
  }
  final resolved = await git(backend, [
    'rev-parse',
    '--verify',
    '--quiet',
    '$ref^{commit}',
  ]);
  if (resolved.exitCode != 0) {
    err.writeln(
      'ref $ref not found in $backend - fetch it there first '
      '(git fetch), then make api-sync REF=$ref again',
    );
    return _failed;
  }
  final commit = utf8.decode(resolved.stdout).trim();
  final shown = await git(backend, ['show', '$commit:$_backendContract']);
  if (shown.exitCode != 0) {
    err.writeln(
      '$_backendContract not found at $commit in $backend - $notCheckout',
    );
    return _failed;
  }

  final digest = sha256Hex(shown.stdout);
  File('$root/$_contract')
    ..createSync(recursive: true)
    ..writeAsBytesSync(shown.stdout);
  File('$root/$_source').writeAsStringSync(
    '# Written by `make api-sync`; checked by `make api-check`. Never edit.\n'
    'repository: $_repository\n'
    'path: $_backendContract\n'
    'commit: $commit\n'
    'sha256: $digest\n',
  );
  out.writeln('synced $_contract from $backend at $commit (sha256 $digest)');
  return _done;
}

/// The contract, its SOURCE, the generator and the generated package as
/// they are now: what stamp writes and check compares. A missing piece is
/// null (its problem is reported by [_current]).
typedef _State = ({
  String? contract,
  Map<String, String>? source,
  String? commit,
  String? generator,
  String? inputs,
  String? files,
});

int _writeStamp(String root, StringSink out, StringSink err) {
  final problems = <String>[];
  final state = _current(root, problems);
  if (problems.isNotEmpty) {
    problems.forEach(err.writeln);
    return _failed;
  }
  File('$root/$_stamp').writeAsStringSync(
    '# Written by `make api-generate`; checked by `make api-check`. '
    'Never edit.\n'
    'contract: $_contract\n'
    'sha256: ${state.contract}\n'
    'commit: ${state.commit}\n'
    'generator: tonik ${state.generator}\n'
    'inputs: ${state.inputs}\n'
    'files: ${state.files}\n',
  );
  out.writeln(
    'stamped $_stamp: contract ${state.contract} (backend ${state.commit}), '
    'tonik ${state.generator}',
  );
  return _done;
}

int _check(String root, StringSink out, StringSink err) {
  final problems = <String>[];
  final state = _current(root, problems);

  final digest = state.contract;
  final recorded = state.source?['sha256'];
  if (digest != null && state.source != null && recorded != digest) {
    problems.add(
      '$_contract was edited by hand: its sha256 is $digest, $_source says '
      '$recorded - restore it (git checkout -- $_contract) or $_syncFix',
    );
  }

  // Without the package, its missing CONTRACT is no news.
  final stamp = state.files == null ? null : _fields(root, _stamp);
  if (state.files != null && stamp == null) {
    problems.add('$_stamp is missing - fix: $_generateFix');
  }
  if (stamp != null) {
    final generator = state.generator == null
        ? null
        : 'tonik ${state.generator}';
    final expected = <String, (String?, String)>{
      'sha256': (
        digest,
        '$_package was generated from another contract: $_stamp says '
            'sha256 ${stamp['sha256']}, $_contract is $digest',
      ),
      'commit': (
        state.commit,
        '$_package was generated from backend commit ${stamp['commit']}, '
            '$_source says ${state.commit}',
      ),
      'files': (
        state.files,
        '$_package is not what the generator wrote: a file was changed, '
            'added or removed (git status $_package shows which)',
      ),
      'inputs': (
        state.inputs,
        'the generator inputs (${_generatorInputs.join(', ')}) changed since '
            '$_package was generated',
      ),
      'generator': (
        generator,
        '$_package was generated by ${stamp['generator']}, $_generatorLock '
            'pins $generator',
      ),
    };
    for (final MapEntry(key: field, value: (actual, message))
        in expected.entries) {
      if (actual != null && stamp[field] != actual) {
        problems.add('$message - fix: $_generateFix');
      }
    }
  }

  if (problems.isNotEmpty) {
    problems.forEach(err.writeln);
    return _failed;
  }
  out.writeln(
    'api-check: contract $digest (backend ${state.commit}) matches $_source '
    'and $_package (tonik ${state.generator})',
  );
  return _done;
}

/// Reads the current [_State]; adds a problem to [problems] for each
/// missing piece.
_State _current(String root, List<String> problems) {
  final contract = File('$root/$_contract');
  final digest = contract.existsSync()
      ? sha256Hex(contract.readAsBytesSync())
      : null;
  if (digest == null) problems.add('$_contract is missing - fix: $_syncFix');

  final source = _fields(root, _source);
  final commit = source?['commit'];
  if (commit == null) {
    problems.add(
      source == null
          ? '$_source is missing - fix: $_syncFix'
          : '$_source names no commit - fix: $_syncFix',
    );
  }

  final lock = File('$root/$_generatorLock');
  final generator = lock.existsSync()
      ? _lockedVersion(lock.readAsStringSync(), 'tonik')
      : null;
  if (generator == null) {
    problems.add(
      '$_generatorLock does not pin tonik - fix: run `fvm dart pub get` in '
      'tool/api_generator',
    );
  }

  final missingInputs = [
    for (final path in _generatorInputs)
      if (!File('$root/$path').existsSync()) path,
  ];
  if (missingInputs.isNotEmpty) {
    problems.add(
      'generator inputs missing: ${missingInputs.join(', ')} - restore them '
      '(git checkout -- ${missingInputs.join(' ')})',
    );
  }

  final package = Directory('$root/$_package');
  final files = package.existsSync() ? _packageDigest(package) : null;
  if (files == null) problems.add('$_package is missing - fix: $_generateFix');

  return (
    contract: digest,
    source: source,
    commit: commit,
    generator: generator,
    inputs: missingInputs.isEmpty
        ? _treeDigest({
            for (final path in _generatorInputs) path: File('$root/$path'),
          })
        : null,
    files: files,
  );
}

/// The digest of the generator's output in [package]: every file but the
/// stamp itself and the git-ignored files other tools drop there, which
/// tonik never writes: what a `pub get` inside the package writes
/// (`pubspec.lock`, `.dart_tool/`), any path with a segment starting with
/// `.` (`.DS_Store` of the macOS Finder, `.idea/`), `*.iml` files and a
/// top-level `build/` folder.
String _packageDigest(Directory package) => _treeDigest(
  {
    for (final entity in package.listSync(recursive: true))
      if (entity is File)
        entity.path.substring(package.path.length + 1).replaceAll(r'\', '/'):
            entity,
  }..removeWhere(
    (path, _) =>
        path == 'CONTRACT' ||
        path == 'pubspec.lock' ||
        path.startsWith('build/') ||
        path.endsWith('.iml') ||
        path.split('/').any((segment) => segment.startsWith('.')),
  ),
);

/// The SHA-256 of `<path>\n<sha256 of the file>\n` for every file of
/// [files] (path → file), in sorted path order.
String _treeDigest(Map<String, File> files) {
  final paths = files.keys.toList()..sort();
  final buffer = StringBuffer();
  for (final path in paths) {
    buffer
      ..write(path)
      ..write('\n')
      ..write(sha256Hex(files[path]!.readAsBytesSync()))
      ..write('\n');
  }
  return sha256Hex(utf8.encode(buffer.toString()));
}

/// The `key: value` lines of a SOURCE or CONTRACT file (`#` lines are
/// comments); null when it is missing.
Map<String, String>? _fields(String root, String path) {
  final file = File('$root/$path');
  if (!file.existsSync()) return null;
  return {
    for (final line in const LineSplitter().convert(file.readAsStringSync()))
      if (!line.startsWith('#') && line.contains(': '))
        line.substring(0, line.indexOf(': ')): line
            .substring(line.indexOf(': ') + 2)
            .trim(),
  };
}

/// The version of [package] in a pubspec.lock, if it is there.
String? _lockedVersion(String lock, String package) {
  var inPackage = false;
  for (final line in const LineSplitter().convert(lock)) {
    if (line.startsWith('  ') && !line.startsWith('   ')) {
      inPackage = line.trim() == '$package:';
    } else if (inPackage && line.trim().startsWith('version: ')) {
      return line.trim().substring('version: '.length).replaceAll('"', '');
    }
  }
  return null;
}

// --- SHA-256 (FIPS 180-4) ----------------------------------------------------

const _roundConstants = <int>[
  0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, //
  0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
  0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786,
  0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
  0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147,
  0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
  0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
  0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
  0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a,
  0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
  0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
];

const _mask = 0xffffffff;

int _rotateRight(int x, int n) => ((x >> n) | (x << (32 - n))) & _mask;

/// The SHA-256 digest of [message], as 64 lowercase hexadecimal digits.
String sha256Hex(List<int> message) {
  final hash = <int>[
    0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, //
    0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
  ];
  // Padding: 0x80, zeros up to 56 mod 64, the length in bits (64-bit BE).
  final padded = BytesBuilder(copy: false)
    ..add(message)
    ..addByte(0x80);
  while ((padded.length + 8) % 64 != 0) {
    padded.addByte(0);
  }
  padded.add(
    (ByteData(8)..setUint64(0, message.length * 8)).buffer.asUint8List(),
  );
  final data = ByteData.sublistView(padded.takeBytes());

  final w = List<int>.filled(64, 0);
  for (var chunk = 0; chunk < data.lengthInBytes; chunk += 64) {
    for (var i = 0; i < 16; i++) {
      w[i] = data.getUint32(chunk + i * 4);
    }
    for (var i = 16; i < 64; i++) {
      final s0 =
          _rotateRight(w[i - 15], 7) ^
          _rotateRight(w[i - 15], 18) ^
          (w[i - 15] >> 3);
      final s1 =
          _rotateRight(w[i - 2], 17) ^
          _rotateRight(w[i - 2], 19) ^
          (w[i - 2] >> 10);
      w[i] = (w[i - 16] + s0 + w[i - 7] + s1) & _mask;
    }
    var [a, b, c, d, e, f, g, h] = hash;
    for (var i = 0; i < 64; i++) {
      final s1 = _rotateRight(e, 6) ^ _rotateRight(e, 11) ^ _rotateRight(e, 25);
      final choice = (e & f) ^ (~e & _mask & g);
      final t1 = (h + s1 + choice + _roundConstants[i] + w[i]) & _mask;
      final s0 = _rotateRight(a, 2) ^ _rotateRight(a, 13) ^ _rotateRight(a, 22);
      final majority = (a & b) ^ (a & c) ^ (b & c);
      final t2 = (s0 + majority) & _mask;
      h = g;
      g = f;
      f = e;
      e = (d + t1) & _mask;
      d = c;
      c = b;
      b = a;
      a = (t1 + t2) & _mask;
    }
    final round = [a, b, c, d, e, f, g, h];
    for (var i = 0; i < 8; i++) {
      hash[i] = (hash[i] + round[i]) & _mask;
    }
  }
  return hash.map((word) => word.toRadixString(16).padLeft(8, '0')).join();
}
