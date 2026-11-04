// The iOS project files, read only (no Mac needed): the debug-only dev URL
// scheme (Info.plist registers $(KIVETO_DEV_URL_SCHEME), Debug.xcconfig
// alone sets it, the Runner's Debug configuration alone uses
// Debug.xcconfig), the launch screen's status bar, the purpose of the local
// network prompt, and the location permission kept to « when in use ».

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

/// [plist] without its `<!-- … -->` comments.
String _plistWithoutComments(String plist) =>
    plist.replaceAll(RegExp('<!--.*?-->', dotAll: true), '');

/// The settings of an xcconfig file (`NAME = value` lines, `//` comments
/// and `#include` lines left out).
Map<String, String> _xcconfigSettings(String path) => {
  for (final line in _read(path).split('\n'))
    if (RegExp(r'^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*?)\s*$')
            .firstMatch(line.split('//').first)
        case final match?)
      match.group(1)!: match.group(2)!,
};

/// The configurations of the Runner target in the pbxproj, name →
/// (base xcconfig file name, Info.plist file).
Map<String, (String?, String?)> _runnerConfigurations(String pbxproj) {
  final list = RegExp(
    r'/\* Build configuration list for PBXNativeTarget "Runner" \*/ = \{'
    r'.*?buildConfigurations = \((.*?)\);',
    dotAll: true,
  ).firstMatch(pbxproj);
  expect(list, isNotNull, reason: 'the Runner configuration list');
  final configurations = <String, (String?, String?)>{};
  for (final entry in RegExp(
    r'([0-9A-F]{24}) /\* (\w+) \*/',
  ).allMatches(list!.group(1)!)) {
    final id = entry.group(1)!;
    final block = RegExp(
      '$id /\\* \\w+ \\*/ = \\{\\s*isa = XCBuildConfiguration;(.*?)\\n\\t\\t\\};',
      dotAll: true,
    ).firstMatch(pbxproj);
    expect(block, isNotNull, reason: 'the configuration $id');
    final body = block!.group(1)!;
    configurations[entry.group(2)!] = (
      RegExp(r'baseConfigurationReference = [0-9A-F]{24} /\* ([\w.]+) \*/;')
          .firstMatch(body)
          ?.group(1),
      RegExp(r'INFOPLIST_FILE = ([\w/.]+);').firstMatch(body)?.group(1),
    );
  }
  return configurations;
}

void main() {
  group('ios/Runner/Info.plist', () {
    final plist = _plistWithoutComments(_read('ios/Runner/Info.plist'));

    test(r'one URL type: app.kiveto.portal.dev, $(KIVETO_DEV_URL_SCHEME)', () {
      final types = RegExp(
        r'<key>CFBundleURLTypes</key>\s*<array>(.*?)</array>\s*<key>',
        dotAll: true,
      ).firstMatch(plist);
      expect(types, isNotNull);
      final dicts = RegExp(
        '<dict>(.*?)</dict>',
        dotAll: true,
      ).allMatches(types!.group(1)!).toList();
      expect(dicts, hasLength(1));
      final type = dicts.single.group(1)!;
      expect(
        type,
        matches(
          RegExp(
            r'<key>CFBundleURLName</key>\s*'
            r'<string>app\.kiveto\.portal\.dev</string>',
          ),
        ),
      );
      expect(
        type,
        matches(
          RegExp(
            r'<key>CFBundleURLSchemes</key>\s*<array>\s*'
            r'<string>\$\(KIVETO_DEV_URL_SCHEME\)</string>\s*</array>',
          ),
        ),
      );
    });

    test("the launch screen's status bar: dark content, the view "
        'controllers (Flutter) driving it afterwards', () {
      expect(
        plist,
        matches(
          RegExp(
            r'<key>UIStatusBarStyle</key>\s*'
            '<string>UIStatusBarStyleDarkContent</string>',
          ),
        ),
      );
      expect(
        plist,
        isNot(contains('UIViewControllerBasedStatusBarAppearance')),
      );
    });

    test('the local network prompt has its purpose (a physical iPhone '
        "reaching the Mac's backend), in every configuration", () {
      expect(
        plist,
        matches(
          RegExp(
            r'<key>NSLocalNetworkUsageDescription</key>\s*'
            '<string>Kiveto utilise le réseau local pour joindre le serveur '
            'de développement.</string>',
          ),
        ),
      );
    });

    test('the location stays « when in use »: its description, no always '
        'key', () {
      expect(plist, contains('<key>NSLocationWhenInUseUsageDescription</key>'));
      expect(plist, isNot(contains('NSLocationAlways')));
    });
  });

  group('the xcconfig files', () {
    test('Debug.xcconfig sets KIVETO_DEV_URL_SCHEME = kiveto-dev', () {
      expect(
        _xcconfigSettings('ios/Flutter/Debug.xcconfig'),
        containsPair('KIVETO_DEV_URL_SCHEME', 'kiveto-dev'),
      );
    });

    test('Release.xcconfig (Release and Profile) does not set it', () {
      expect(
        _xcconfigSettings('ios/Flutter/Release.xcconfig'),
        isNot(contains('KIVETO_DEV_URL_SCHEME')),
      );
      expect(
        _read('ios/Flutter/Release.xcconfig'),
        isNot(contains('#include "Debug.xcconfig"')),
      );
    });
  });

  test('the Runner target: Debug on Debug.xcconfig, Release and Profile on '
      'Release.xcconfig, all three on Runner/Info.plist', () {
    expect(
      _runnerConfigurations(_read('ios/Runner.xcodeproj/project.pbxproj')),
      {
        'Debug': ('Debug.xcconfig', 'Runner/Info.plist'),
        'Release': ('Release.xcconfig', 'Runner/Info.plist'),
        'Profile': ('Release.xcconfig', 'Runner/Info.plist'),
      },
    );
  });
}
