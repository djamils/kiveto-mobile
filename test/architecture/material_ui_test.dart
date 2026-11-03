// Material comes from package:material_ui (go_router 18 is built on it):
// no Dart file of lib/, test/ or integration_test/ imports the SDK's
// Material library, or the app would get a second MaterialApp, Theme and
// MaterialLocalizations that go_router does not see (spec-app-shell,
// CONTRIBUTING.md §6 "App foundation"). Not a numbered D15 rule.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Split so that this file does not hold the searched URI itself.
const _sdkMaterial =
    'package:flutter/'
    'material.dart';

final _directive = RegExp(
  '^\\s*(import|export)\\s+[\'"]${RegExp.escape(_sdkMaterial)}[\'"]',
  multiLine: true,
);

void main() {
  test('no file imports the SDK Material library (use material_ui)', () {
    final offenders = <String>[
      for (final root in ['lib', 'test', 'integration_test'])
        if (Directory(root).existsSync())
          for (final entity in Directory(root).listSync(recursive: true))
            if (entity is File &&
                entity.path.endsWith('.dart') &&
                _directive.hasMatch(entity.readAsStringSync()))
              entity.path.replaceAll(r'\', '/'),
    ]..sort();

    expect(
      offenders,
      isEmpty,
      reason:
          'import package:material_ui/material_ui.dart instead of '
          '$_sdkMaterial in: ${offenders.join(', ')}',
    );
  });

  test('the scan finds an offending import', () {
    expect(_directive.hasMatch("import '$_sdkMaterial';"), isTrue);
    expect(
      _directive.hasMatch("import 'package:material_ui/material_ui.dart';"),
      isFalse,
    );
  });
}
