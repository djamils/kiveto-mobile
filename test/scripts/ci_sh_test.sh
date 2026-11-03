#!/usr/bin/env bash
# scripts/ci.sh and scripts/test-scripts.sh with a failing step, in a
# temporary project holding a copy of scripts/: make ci stops at the first
# failing target and names it; make test-scripts fails and names the
# failing *_test.sh.

. "$(dirname "$0")/support.sh"

P=$KV_T/project
mkdir -p "$P"
cp -R "$KV_REPO/scripts" "$P/"
cp "$KV_REPO/.fvmrc" "$P/"
FLUTTER=$(sed -n 's/.*"flutter"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$P/.fvmrc")

# --- make ci ----------------------------------------------------------------------

# The make that ci.sh calls: logs its target, fails on the one in fail-at.
stub make-stub "printf '%s\n' \"\$1\" >>'$KV_T/targets'
if [ \"\$1\" = \"\$(cat '$KV_T/fail-at' 2>/dev/null)\" ]; then exit 1; fi
exit 0"

run_ci() {
  : >"$KV_T/targets"
  RC=0
  OUT=$(cd "$P" && MAKE="$KV_T/bin/make-stub" bash scripts/ci.sh 2>&1) || RC=$?
}

printf 'analyze\n' >"$KV_T/fail-at"
run_ci
expect_status 1 "$RC" 'make ci: a failing step -> exit 1' "$OUT"
expect_contains "$OUT" 'make ci failed at analyze' 'make ci: names the failing target'
expect_eq "format-check${NL}analyze" "$(cat "$KV_T/targets")" 'make ci: stops at the failing target'

rm "$KV_T/fail-at"
run_ci
expect_status 0 "$RC" 'make ci: every step passes -> exit 0' "$OUT"
expect_eq "format-check analyze test-architecture test-coverage coverage-gate test-scripts" \
  "$(tr '\n' ' ' <"$KV_T/targets" | sed 's/ $//')" 'make ci: the six targets, in order'
expect_contains "$OUT" 'make ci passed in' 'make ci: prints the total'

# --- make test-scripts ------------------------------------------------------------

# fvm 4.3.2 with the pinned Flutter set up; any other call fails.
stub fvm "case \"\${1:-}\" in
  --version) echo 4.3.2 ;;
  api) printf '{\"versions\":[{\"name\":\"%s\",\"isSetup\":true}]}\n' '$FLUTTER' ;;
  *) exit 1 ;;
esac"
mkdir -p "$P/.dart_tool" "$P/.make" "$P/test/scripts"
printf '{}\n' >"$P/.dart_tool/package_config.json"
printf '%s\n' "$FLUTTER" >"$P/.make/pub-get.stamp"
printf '#!/usr/bin/env bash\necho "  ✓ fine"\n' >"$P/test/scripts/pass_test.sh"
printf '#!/usr/bin/env bash\necho "  ✗ broken"\nexit 1\n' >"$P/test/scripts/fail_test.sh"

RC=0
OUT=$(cd "$P" && bash scripts/test-scripts.sh 2>&1) || RC=$?
expect_status 1 "$RC" 'make test-scripts: a failing *_test.sh -> exit 1' "$OUT"
expect_contains "$OUT" 'Plain-bash checks failed: test/scripts/fail_test.sh' 'make test-scripts: names the failing file'
expect_contains "$OUT" '✓ fine' 'make test-scripts: runs the other files too'

finish
