#!/usr/bin/env bash
# tool/coverage_gate.dart, the thin entry point make coverage-gate runs:
# the gate's exit code must reach the process (a bare runCoverageGate call
# would turn the gate into a mere report while make ci stays green). The
# gate itself is tested by test/tool/coverage_gate_test.dart.

. "$(dirname "$0")/support.sh"

cd "$KV_REPO" || exit 1

P=$KV_T/project
mkdir -p "$P/.dart_tool" "$P/lib/features/x/domain" "$P/test/unit" "$P/coverage"
printf '{"configVersion":2,"packages":[{"name":"kiveto_mobile","rootUri":"../","packageUri":"lib/"}]}\n' \
  >"$P/.dart_tool/package_config.json"
printf 'int answer() {\n  return 42;\n}\n' >"$P/lib/features/x/domain/a.dart"
printf 'void main() {}\n' >"$P/test/unit/a_test.dart"
: >"$P/coverage/lcov.info"

gate() {
  RC=0
  OUT=$(with_real_fvm fvm dart tool/coverage_gate.dart --root "$P" "$@" 2>"$KV_T/err") || RC=$?
}

gate --test-dir test/unit
expect_status 1 "$RC" 'a gated file no test loads: exit 1' "$OUT$NL$(cat "$KV_T/err")"
expect_contains "$OUT" 'lib/features/x/domain/a.dart: not loaded by any test (0%)' 'a gated file no test loads: reported'

printf "import 'package:kiveto_mobile/features/x/domain/a.dart';\n\nvoid main() {}\n" >"$P/test/unit/a_test.dart"
printf 'SF:lib/features/x/domain/a.dart\nDA:1,1\nDA:2,1\nLF:2\nLH:2\nend_of_record\n' >"$P/coverage/lcov.info"
gate --test-dir test/unit
expect_status 0 "$RC" 'every gated file covered: exit 0' "$OUT$NL$(cat "$KV_T/err")"
expect_contains "$OUT" 'Coverage gate passed' 'every gated file covered: says so'

gate
expect_status 2 "$RC" 'no --test-dir: exit 2' "$OUT$NL$(cat "$KV_T/err")"
expect_contains "$(cat "$KV_T/err")" 'at least one --test-dir is needed' 'no --test-dir: explained on stderr'

finish
