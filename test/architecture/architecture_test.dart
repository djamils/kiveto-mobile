// The D15 rules (architecture §3) on the real lib/: one test per rule,
// failing with every offence of that rule. The rules themselves are in
// architecture_rules.dart; architecture_self_test.dart proves that each one
// catches what it should.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'architecture_rules.dart';

void main() {
  late final List<Offence> offences;

  setUpAll(() => offences = checkArchitecture(Directory.current.path));

  for (final MapEntry(key: rule, value: title) in ruleTitles.entries) {
    test('rule $rule: $title', () {
      final broken = [
        for (final offence in offences)
          if (offence.rule == rule) offence.message,
      ];
      if (broken.isNotEmpty) {
        fail(
          '${broken.length} offence(s) of rule $rule ($title):\n'
          '${broken.join('\n')}',
        );
      }
    });
  }
}
