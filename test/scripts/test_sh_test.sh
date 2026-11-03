#!/usr/bin/env bash
# scripts/test.sh on a suite without test, in a temporary project holding a
# copy of scripts/: it says there is nothing to run and succeeds without
# calling fvm (a stub logs every call).

. "$(dirname "$0")/support.sh"

P=$KV_T/project
mkdir -p "$P"
cp -R "$KV_REPO/scripts" "$P/"
cp "$KV_REPO/.fvmrc" "$P/"

stub fvm "printf '%s\n' \"\$*\" >>'$KV_T/fvm.log'
exit 1"
: >"$KV_T/fvm.log"

run_suite() {
  RC=0
  OUT=$(cd "$P" && bash scripts/test.sh "$@" 2>&1) || RC=$?
}

run_suite integration
expect_status 0 "$RC" 'no test/integration/: exit 0' "$OUT"
expect_contains "$OUT" 'test/integration: nothing to run' 'no test/integration/: says there is nothing to run'

mkdir -p "$P/test/integration/support"
printf 'void helper() {}\n' >"$P/test/integration/support/fake_adapter.dart"
run_suite integration
expect_status 0 "$RC" 'test/integration/ without *_test.dart: exit 0' "$OUT"
expect_contains "$OUT" 'nothing to run' 'test/integration/ without *_test.dart: says there is nothing to run'

run_suite
expect_status 0 "$RC" 'make test with no suite holding a test: exit 0' "$OUT"
expect_contains "$OUT" 'nothing to run' 'make test with no suite holding a test: nothing to run'

run_suite --coverage
expect_status 0 "$RC" 'make test-coverage with no test: exit 0' "$OUT"
expect_eq '' "$(cat "$P/coverage/lcov.info")" 'make test-coverage with no test: empty coverage/lcov.info'

expect_eq '' "$(cat "$KV_T/fvm.log")" 'fvm never called'

run_suite e2e
expect_status 1 "$RC" 'an unknown suite: exit 1' "$OUT"
expect_contains "$OUT" "Unknown test suite 'e2e'" 'an unknown suite: says so'

finish
