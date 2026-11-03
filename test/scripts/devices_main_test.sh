#!/usr/bin/env bash
# tool/devices.dart, the thin entry point scripts/start.sh runs: wired to
# pickDevice on stdin, stdout and the exit code (the picker itself is tested
# by test/tool/devices_test.dart). stderr is kept apart: fvm and dart may
# print notices there (a first-run banner) that are not the answer.

. "$(dirname "$0")/support.sh"

cd "$KV_REPO" || exit 1

fixture=test/tool/fixtures/devices_one_android.json

RC=0
OUT=$(with_real_fvm fvm dart tool/devices.dart --platform android <"$fixture" 2>"$KV_T/err") || RC=$?
expect_status 0 "$RC" 'one Android device: exit 0' "$OUT$NL$(cat "$KV_T/err")"
expect_eq emulator-5554 "$(printf '%s' "$OUT" | tr -d '\r')" 'one Android device: prints its id only'

RC=0
OUT=$(with_real_fvm fvm dart tool/devices.dart --platform web <"$fixture" 2>"$KV_T/err") || RC=$?
expect_status 1 "$RC" 'bad arguments: exit 1' "$OUT$NL$(cat "$KV_T/err")"
expect_contains "$(cat "$KV_T/err")" '--platform must be android or ios' 'bad arguments: explained on stderr'

finish
