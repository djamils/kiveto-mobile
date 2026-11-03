// The coverage gate of `make ci`: `make coverage-gate` runs
//
//   dart tool/coverage_gate.dart --lcov coverage/lcov.info \
//     --test-dir test/unit --test-dir test/widget ...
//
// after `make test-coverage`. Exit 0 passed, 1 failed, 2 usage error or
// missing input (no lcov report, no package config, no --test-dir).
//
// A thin entry point over package:kiveto_tool/coverage_gate.dart (tool/lib/,
// SDK libraries only, tested by test/tool/), which documents the rules.

import 'dart:convert';
import 'dart:io';

import 'package:kiveto_tool/coverage_gate.dart';

void main(List<String> args) {
  // The report uses non-ASCII signs (✓, ✗, –): UTF-8 whatever the console
  // code page says.
  stdout.encoding = utf8;
  stderr.encoding = utf8;
  exitCode = runCoverageGate(
    args,
    root: Directory.current.path,
    out: stdout,
    err: stderr,
  );
}
