#!/usr/bin/env bash
# scripts/format.sh in a temporary project (a copy of scripts/, .fvmrc,
# analysis_options.yaml and the package config, a fresh pub-get stamp) with
# the real fvm: --check fails on an unformatted file and says make format;
# once formatted, it passes.

. "$(dirname "$0")/support.sh"

P=$KV_T/project
mkdir -p "$P/.dart_tool" "$P/.make" "$P/lib" "$P/test" "$P/tool"
cp -R "$KV_REPO/scripts" "$P/"
cp "$KV_REPO/.fvmrc" "$KV_REPO/analysis_options.yaml" "$P/"
cp "$KV_REPO/.dart_tool/package_config.json" "$P/.dart_tool/"
sed -n 's/.*"flutter"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$P/.fvmrc" >"$P/.make/pub-get.stamp"
printf 'void main( ) {print(1);}\n' >"$P/lib/a.dart"

format() {
  RC=0
  OUT=$(cd "$P" && with_real_fvm bash scripts/format.sh "$@" 2>&1) || RC=$?
}

format --check
expect_status 1 "$RC" 'format-check: an unformatted file -> exit 1' "$OUT"
expect_contains "$OUT" 'a.dart' 'format-check: names the unformatted file'
expect_contains "$OUT" 'fix: make format' 'format-check: says make format'

format
expect_status 0 "$RC" 'format: rewrites the file' "$OUT"

format --check
expect_status 0 "$RC" 'format-check: once formatted -> exit 0' "$OUT"
expect_contains "$OUT" 'Dart files formatted' 'format-check: says so'

finish
