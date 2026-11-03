#!/usr/bin/env bash
# scripts/api.sh (make api-sync, api-generate, api-check) in a temporary
# project holding a copy of scripts/: make api-sync refuses a missing or
# unsafe REF and a missing backend checkout before any fvm call (a stub logs
# every call). The Dart side is tested by test/tool/portal_api_test.dart and
# test/scripts/portal_api_main_test.sh.

. "$(dirname "$0")/support.sh"

P=$KV_T/project
mkdir -p "$P"
cp -R "$KV_REPO/scripts" "$P/"
cp "$KV_REPO/.fvmrc" "$P/"

stub fvm "printf '%s\n' \"\$*\" >>'$KV_T/fvm.log'
exit 1"
: >"$KV_T/fvm.log"

# api <command> [VAR=value...]: bash scripts/api.sh <command> with only the
# given REF and KIVETO_BACKEND_DIR.
api() {
  local command=$1
  shift
  RC=0
  OUT=$(cd "$P" && env REF= KIVETO_BACKEND_DIR= "$@" bash scripts/api.sh "$command" 2>&1) || RC=$?
}

api sync
expect_status 1 "$RC" 'api-sync without REF: exit 1' "$OUT"
expect_contains "$OUT" 'REF is required: make api-sync REF=<backend commit>' 'api-sync without REF: says how'

api sync 'REF=a^b'
expect_status 1 "$RC" 'api-sync with REF=a^b: exit 1' "$OUT"
expect_contains "$OUT" "REF 'a^b' may only hold letters, digits and . _ / -" 'api-sync with REF=a^b: refused'

api sync 'REF=-x'
expect_status 1 "$RC" 'api-sync with REF=-x: exit 1' "$OUT"
expect_contains "$OUT" "REF '-x' may only hold" 'api-sync with REF=-x: refused'

api sync REF=840dbead "KIVETO_BACKEND_DIR=$KV_T/nope"
expect_status 1 "$RC" 'api-sync with a missing KIVETO_BACKEND_DIR: exit 1' "$OUT"
expect_contains "$OUT" "$KV_T/nope is not a git checkout of djamils/kiveto - set KIVETO_BACKEND_DIR" \
  'api-sync with a missing KIVETO_BACKEND_DIR: names it'

api sync REF=840dbead
expect_status 1 "$RC" 'api-sync without KIVETO_BACKEND_DIR: exit 1' "$OUT"
expect_contains "$OUT" '../kiveto is not a git checkout of djamils/kiveto' \
  'api-sync without KIVETO_BACKEND_DIR: the default ../kiveto, named'

api sync REF=840dbead 'KIVETO_BACKEND_DIR=a&b'
expect_status 1 "$RC" 'api-sync with KIVETO_BACKEND_DIR=a&b: exit 1' "$OUT"
expect_contains "$OUT" "KIVETO_BACKEND_DIR 'a&b' may not hold | ^ & < > % or" \
  'api-sync with KIVETO_BACKEND_DIR=a&b: refused (cmd.exe)'

api publish
expect_status 1 "$RC" 'an unknown command: exit 1' "$OUT"
expect_contains "$OUT" "Unknown command 'publish'" 'an unknown command: says so'

expect_eq '' "$(cat "$KV_T/fvm.log")" 'fvm never called'

finish
