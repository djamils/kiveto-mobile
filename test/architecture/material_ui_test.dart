// Material comes from package:material_ui and Cupertino from cupertino_ui
// (go_router 18 is built on them): no Dart file of lib/, test/ or
// integration_test/ imports the SDK's Material or Cupertino library, or the
// app would get a second MaterialApp, Theme and localisations that
// go_router does not see (spec-app-shell, CONTRIBUTING.md §6 "App
// foundation"). Not a numbered D15 rule.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Split so that this file does not hold the searched URIs itself.
const _sdkPrefix = 'package:flutter/';
const _sdkLibraries = [
  '${_sdkPrefix}material.dart',
  '${_sdkPrefix}cupertino.dart',
];

final _directive = RegExp(
  '^\\s*(import|export)\\s+[\'"]'
  '(${_sdkLibraries.map(RegExp.escape).join('|')})[\'"]',
  multiLine: true,
);

void main() {
  test('no file imports the SDK Material or Cupertino library', () {
    var scannedInLib = 0;
    final offenders = <String>[];
    for (final root in ['lib', 'test', 'integration_test']) {
      if (!Directory(root).existsSync()) continue;
      for (final entity in Directory(root).listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        if (root == 'lib') scannedInLib++;
        if (_directive.hasMatch(entity.readAsStringSync())) {
          offenders.add(entity.path.replaceAll(r'\', '/'));
        }
      }
    }

    // Run from another directory, the scan would find nothing and pass.
    expect(
      scannedInLib,
      greaterThan(0),
      reason: 'no Dart file found under lib/: run from the project root',
    );
    expect(
      offenders..sort(),
      isEmpty,
      reason:
          'import package:material_ui/material_ui.dart (or cupertino_ui) '
          'instead of ${_sdkLibraries.join(' / ')} in: '
          '${offenders.join(', ')}',
    );
  });

  test('the scan finds an offending import', () {
    for (final library in _sdkLibraries) {
      expect(_directive.hasMatch("import '$library';"), isTrue);
      expect(_directive.hasMatch('export "$library";'), isTrue);
    }
    expect(
      _directive.hasMatch("import 'package:material_ui/material_ui.dart';"),
      isFalse,
    );
    expect(
      _directive.hasMatch("import 'package:cupertino_ui/cupertino_ui.dart';"),
      isFalse,
    );
  });
}
