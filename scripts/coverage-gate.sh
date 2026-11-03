#!/usr/bin/env bash
# make coverage-gate: tool/coverage_gate.dart on coverage/lcov.info (written
# by make test-coverage), with the suites of KV_COVERAGE_SUITES that hold
# tests as roots. Its output is the report: shown live, not logged.

. "$(dirname "$0")/lib.sh"

require_flutter
pub_get_if_needed

args=(tool/coverage_gate.dart --lcov coverage/lcov.info)
for suite in $KV_COVERAGE_SUITES; do
  if suite_has_tests "$suite"; then args+=(--test-dir "test/$suite"); fi
done

step "Coverage gate (fvm dart tool/coverage_gate.dart)..."
run_live fvm dart "${args[@]}"
