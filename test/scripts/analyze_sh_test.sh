#!/usr/bin/env bash
# scripts/analyze.sh fails on an info-level lint (--fatal-infos: without it
# every very_good_analysis rule would be advisory). One real analyzer run,
# in a temporary project holding a copy of scripts/, .fvmrc,
# analysis_options.yaml and the package config, with a fresh pub-get stamp.

. "$(dirname "$0")/support.sh"

P=$KV_T/project
mkdir -p "$P/.dart_tool" "$P/.make" "$P/lib"
cp -R "$KV_REPO/scripts" "$P/"
cp "$KV_REPO/.fvmrc" "$KV_REPO/analysis_options.yaml" "$P/"
cp "$KV_REPO/.dart_tool/package_config.json" "$P/.dart_tool/"
sed -n 's/.*"flutter"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$P/.fvmrc" >"$P/.make/pub-get.stamp"
# Its only problem: double quotes, an info of prefer_single_quotes.
printf 'const greeting = "hello";\n' >"$P/lib/a.dart"

RC=0
OUT=$(cd "$P" && with_real_fvm bash scripts/analyze.sh 2>&1) || RC=$?
expect_eq yes "$([ "$RC" -ne 0 ] && echo yes || echo no)" 'analyze: an info-level lint fails it'
expect_contains "$OUT" 'prefer_single_quotes' 'analyze: names the lint (log tail)'

finish
