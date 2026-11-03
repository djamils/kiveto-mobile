#!/usr/bin/env bash
# make test, test-<suite>, test-coverage: fvm flutter test on the folders of
# test/ that hold a *_test.dart file.
#
#   bash scripts/test.sh              every suite of KV_TEST_SUITES (make test)
#   bash scripts/test.sh <suite>      test/<suite> only (make test-<suite>)
#   bash scripts/test.sh --coverage   the suites of KV_COVERAGE_SUITES with
#                                     coverage of lib/ and tool/lib/ into
#                                     coverage/lcov.info (make test-coverage)
#
# A suite without test is reported as having nothing to run; when no suite
# has a test, this says so and succeeds before any fvm call. Quiet runs use
# --reporter failures-only so that the failure ends up in the 30 lines shown.

. "$(dirname "$0")/lib.sh"

COVERAGE=0
case ${1:-} in
  '') suites=$KV_TEST_SUITES ;;
  --coverage)
    COVERAGE=1
    suites=$KV_COVERAGE_SUITES
    ;;
  *)
    case " $KV_TEST_SUITES " in
      *" $1 "*) suites=$1 ;;
      *) die "Unknown test suite '$1': use one of $KV_TEST_SUITES." ;;
    esac
    ;;
esac

dirs=()
for suite in $suites; do
  if suite_has_tests "$suite"; then
    dirs+=("test/$suite")
  else
    info "test/$suite: nothing to run (no *_test.dart)"
  fi
done

if [ "$COVERAGE" = 1 ]; then
  rm -f coverage/lcov.info
fi

if [ "${#dirs[@]}" -eq 0 ]; then
  if [ "$COVERAGE" = 1 ]; then
    mkdir -p coverage
    : >coverage/lcov.info
    ok "No test to run: empty coverage/lcov.info written"
  else
    ok "No test to run in ${suites// /, }: nothing to run"
  fi
  exit 0
fi

require_flutter
pub_get_if_needed

args=(test)
if [ "$V" != 1 ]; then args+=(--reporter failures-only); fi
if [ "$COVERAGE" = 1 ]; then
  # One --coverage-package per package: a regex would hold characters that
  # cmd.exe (behind fvm on Windows) mangles.
  args+=(--coverage --coverage-package=kiveto_mobile --coverage-package=kiveto_tool)
fi
args+=("${dirs[@]}")

step "Running fvm flutter ${args[*]}..."
run fvm flutter "${args[@]}"
if [ "$COVERAGE" = 1 ]; then
  ok "Tests passed, coverage in coverage/lcov.info (${dirs[*]})"
else
  ok "Tests passed (${dirs[*]})"
fi
