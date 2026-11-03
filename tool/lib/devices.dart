// The device picker of `make start`, behind tool/devices.dart.
//
// Reads the JSON that `flutter devices --machine` prints and picks a device
// for a platform; tool/devices.dart documents the contract (exit codes 0, 1,
// 2 and 3). SDK libraries only.

import 'dart:convert';

const _found = 0;
const _invalid = 1;
const _none = 2;
const _several = 3;

class _Device {
  const new(this.id, this.name, this.targetPlatform);

  final String id;
  final String name;
  final String targetPlatform;

  bool runs(String platform) => platform == 'ios'
      ? targetPlatform == 'ios'
      : targetPlatform.startsWith('android');

  String get line => '$id\t$name';
}

/// Picks a device from the `flutter devices --machine` JSON read on [input].
///
/// Writes the answer to [out] and errors to [err], and returns the exit code
/// documented in tool/devices.dart.
Future<int> pickDevice(
  List<String> args, {
  required Stream<List<int>> input,
  required StringSink out,
  required StringSink err,
}) async {
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
        return _fail(err, 'unknown or incomplete argument "${args[i]}"');
    }
  }
  if (platform != 'android' && platform != 'ios') {
    return _fail(err, '--platform must be android or ios');
  }

  final List<_Device> devices;
  try {
    devices = _parse(await input.transform(utf8.decoder).join());
  } on FormatException catch (error) {
    return _fail(
      err,
      'cannot read `flutter devices --machine`: ${error.message}',
    );
  }

  if (device != null) {
    for (final candidate in devices) {
      if (candidate.id == device || candidate.name == device) {
        out.writeln(candidate.id);
        return _found;
      }
    }
    devices.map((d) => d.line).forEach(out.writeln);
    return _none;
  }

  final candidates = devices.where((d) => d.runs(platform!)).toList();
  if (candidates.isEmpty) return _none;
  if (candidates.length == 1) {
    out.writeln(candidates.single.id);
    return _found;
  }
  candidates.map((d) => d.line).forEach(out.writeln);
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
  // From a `[` to a `]`: either an array or a FormatException.
  final decoded = jsonDecode(output.substring(start, end + 1)) as List<Object?>;
  final devices = <_Device>[];
  for (final entry in decoded) {
    if (entry case {
      'id': final String id,
      'name': final String name,
      'targetPlatform': final String targetPlatform,
    }) {
      devices.add(_Device(id, name, targetPlatform));
    } else {
      throw const FormatException('a device lacks id, name or platform');
    }
  }
  return devices;
}

int _fail(StringSink err, String message) {
  err.writeln('tool/devices.dart: $message');
  return _invalid;
}
