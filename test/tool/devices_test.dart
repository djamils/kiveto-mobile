// The device picker of `make start` (tool/lib/devices.dart), fed with
// `flutter devices --machine` fixtures (test/tool/fixtures/).

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_tool/devices.dart';

typedef _Result = ({int code, String out, String err});

Future<_Result> _pick(
  List<String> args, {
  String? fixture,
  String? text,
}) async {
  final out = StringBuffer();
  final err = StringBuffer();
  final input = text ?? File('test/tool/fixtures/$fixture').readAsStringSync();
  final code = await pickDevice(
    args,
    input: Stream.value(utf8.encode(input)),
    out: out,
    err: err,
  );
  return (code: code, out: out.toString(), err: err.toString());
}

void main() {
  group('pickDevice for a platform', () {
    test('prints the only Android device and exits 0', () async {
      final result = await _pick([
        '--platform',
        'android',
      ], fixture: 'devices_one_android.json');
      expect(result, (code: 0, out: 'emulator-5554\n', err: ''));
    });

    test('exits 2 without output when no Android device runs', () async {
      final result = await _pick([
        '--platform',
        'android',
      ], fixture: 'devices_no_android.json');
      expect(result, (code: 2, out: '', err: ''));
    });

    test(r'lists every Android device as "<id>\t<name>" and exits 3 when '
        'several run', () async {
      final result = await _pick([
        '--platform',
        'android',
      ], fixture: 'devices_several_android.json');
      expect(result, (
        code: 3,
        out:
            'emulator-5554\tsdk gphone64 x86 64\n'
            '48151FDJH00123\tPixel 9\n',
        err: '',
      ));
    });

    test('picks the iOS simulator for --platform ios', () async {
      final result = await _pick([
        '--platform',
        'ios',
      ], fixture: 'devices_several_android.json');
      expect(result, (
        code: 0,
        out: '8A1F2C3D-0000-4000-8000-000000000001\n',
        err: '',
      ));
    });

    test('skips a banner printed before the JSON', () async {
      final result = await _pick([
        '--platform',
        'android',
      ], fixture: 'devices_banner.txt');
      expect(result, (code: 0, out: 'emulator-5554\n', err: ''));
    });
  });

  group('pickDevice with --device', () {
    test('finds a device by id, whatever its platform', () async {
      final result = await _pick([
        '--platform',
        'android',
        '--device',
        'chrome',
      ], fixture: 'devices_one_android.json');
      expect(result, (code: 0, out: 'chrome\n', err: ''));
    });

    test('finds a device by name and prints its id', () async {
      final result = await _pick([
        '--device',
        'sdk gphone64 x86 64',
        '--platform',
        'android',
      ], fixture: 'devices_one_android.json');
      expect(result, (code: 0, out: 'emulator-5554\n', err: ''));
    });

    test('lists every device and exits 2 for an unknown device', () async {
      final result = await _pick([
        '--platform',
        'android',
        '--device',
        'pixel',
      ], fixture: 'devices_one_android.json');
      expect(result, (
        code: 2,
        out:
            'emulator-5554\tsdk gphone64 x86 64\n'
            'windows\tWindows\n'
            'chrome\tChrome\n'
            'edge\tEdge\n',
        err: '',
      ));
    });
  });

  group('pickDevice refuses with exit 1 and a message on stderr', () {
    Future<void> refuses(
      List<String> args,
      String message, {
      String fixture = 'devices_one_android.json',
      String? text,
    }) async {
      final result = await _pick(args, fixture: fixture, text: text);
      expect(result, (code: 1, out: '', err: 'tool/devices.dart: $message\n'));
    }

    test('an entry lacking a field', () async {
      await refuses(
        ['--platform', 'android'],
        'cannot read `flutter devices --machine`: '
        'a device lacks id, name or platform',
        fixture: 'devices_missing_field.json',
      );
    });

    test('an output without JSON array', () async {
      await refuses(
        ['--platform', 'android'],
        'cannot read `flutter devices --machine`: no JSON array found',
        fixture: 'devices_no_array.txt',
      );
    });

    test('an array that never closes', () async {
      await refuses(
        ['--platform', 'android'],
        'cannot read `flutter devices --machine`: no JSON array found',
        text: '[\n  {"id": "x"',
      );
    });

    test('an array that is not JSON', () async {
      final result = await _pick(['--platform', 'android'], text: '[not json]');
      expect(result.code, 1);
      expect(
        result.err,
        startsWith('tool/devices.dart: cannot read `flutter devices'),
      );
    });

    test('an unknown argument', () async {
      await refuses([
        '--platform',
        'android',
        '--verbose',
      ], 'unknown or incomplete argument "--verbose"');
    });

    test('an argument without its value', () async {
      await refuses([
        '--platform',
      ], 'unknown or incomplete argument "--platform"');
    });

    test('a missing platform', () async {
      await refuses([], '--platform must be android or ios');
    });

    test('an unsupported platform', () async {
      await refuses(['--platform', 'web'], '--platform must be android or ios');
    });
  });
}
