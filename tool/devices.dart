// Picks the device `make start` runs the app on.
//
// Reads the JSON that `flutter devices --machine` prints, on stdin (Git Bash
// has no JSON tool, so scripts/start.sh keeps the control flow and asks this
// script for the answer).
//
//   dart tool/devices.dart --platform <android|ios>
//     exit 0: the only connected device of the platform; prints its id
//     exit 2: no device of the platform; prints nothing
//     exit 3: several devices of the platform; prints "<id>\t<name>" each
//
//   dart tool/devices.dart --platform <android|ios> --device <id or name>
//     exit 0: flutter lists that device (any platform); prints its id
//     exit 2: it does not; prints "<id>\t<name>" for every listed device
//
//   exit 1: invalid arguments or input, explained on stderr.
//
// SDK libraries only: it runs before `pub get` and must not need a package.

import 'dart:convert';
import 'dart:io';

const _found = 0;
const _invalid = 1;
const _none = 2;
const _several = 3;

class _Device {
  const _Device(this.id, this.name, this.targetPlatform);

  final String id;
  final String name;
  final String targetPlatform;

  bool runs(String platform) => platform == 'ios'
      ? targetPlatform == 'ios'
      : targetPlatform.startsWith('android');

  String get line => '$id\t$name';
}

Future<void> main(List<String> args) async {
  exitCode = await _run(args);
}

Future<int> _run(List<String> args) async {
  String? platform;
  String? device;
  for (var i = 0; i < args.length; i++) {
    final value = i + 1 < args.length ? args[i + 1] : null;
    switch (args[i]) {
      case '--platform' when value != null:
        platform = value;
        i++;
      case '--device' when value != null:
        device = value;
        i++;
      default:
        return _fail('unknown or incomplete argument "${args[i]}"');
    }
  }
  if (platform != 'android' && platform != 'ios') {
    return _fail('--platform must be android or ios');
  }

  final List<_Device> devices;
  try {
    devices = _parse(await stdin.transform(utf8.decoder).join());
  } on FormatException catch (error) {
    return _fail('cannot read `flutter devices --machine`: ${error.message}');
  }

  if (device != null) {
    for (final candidate in devices) {
      if (candidate.id == device || candidate.name == device) {
        stdout.writeln(candidate.id);
        return _found;
      }
    }
    devices.map((d) => d.line).forEach(stdout.writeln);
    return _none;
  }

  final candidates = devices.where((d) => d.runs(platform!)).toList();
  if (candidates.isEmpty) return _none;
  if (candidates.length == 1) {
    stdout.writeln(candidates.single.id);
    return _found;
  }
  candidates.map((d) => d.line).forEach(stdout.writeln);
  return _several;
}

/// Decodes the device list, skipping anything Flutter prints before it
/// (a first-run banner, for instance).
List<_Device> _parse(String output) {
  final start = RegExp(r'^\[', multiLine: true).firstMatch(output)?.start;
  final end = output.lastIndexOf(']');
  if (start == null || end < start) {
    throw const FormatException('no JSON array found');
  }
  final decoded = jsonDecode(output.substring(start, end + 1));
  if (decoded is! List<Object?>) {
    throw const FormatException('the JSON is not an array');
  }
  return [
    for (final entry in decoded)
      if (entry case {
        'id': final String id,
        'name': final String name,
        'targetPlatform': final String targetPlatform,
      })
        _Device(id, name, targetPlatform)
      else
        throw const FormatException('a device lacks id, name or platform'),
  ];
}

int _fail(String message) {
  stderr.writeln('tool/devices.dart: $message');
  return _invalid;
}
