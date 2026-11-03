#!/usr/bin/env bash
# scripts/lib.sh: version_ge, and pub_get_needed in a temporary project
# holding a copy of lib.sh and its inputs (mtimes set with touch -t, which
# BSD and GNU touch both read as [[CC]YY]MMDDhhmm).

. "$(dirname "$0")/support.sh"

# --- version_ge ---------------------------------------------------------------

ge() {
  (. "$KV_REPO/scripts/lib.sh" && version_ge "$1" "$2") && echo yes || echo no
}

expect_eq yes "$(ge 1.10 1.9)" 'version_ge: 1.10 >= 1.9'
expect_eq yes "$(ge 3.81 3.81)" 'version_ge: 3.81 >= 3.81'
expect_eq yes "$(ge 4 4.0.0)" 'version_ge: 4 >= 4.0.0'
expect_eq no "$(ge 3.80 3.81)" 'version_ge: 3.80 < 3.81'
expect_eq yes "$(ge 20.12.1 20.12)" 'version_ge: 20.12.1 >= 20.12'
expect_eq yes "$(ge 08 7)" 'version_ge: 08 >= 7 (base 10)'
expect_eq no "$(ge 2.9 2.10)" 'version_ge: 2.9 < 2.10'

# --- pub_get_needed -----------------------------------------------------------

P=$KV_T/project
OLD=202601010000
STAMPED=202601020000
NEW=202601030000

# reset: a project whose last pub get is newer than every input.
reset() {
  rm -rf "$P"
  mkdir -p "$P/scripts" "$P/tool" "$P/.dart_tool" "$P/.make"
  cp "$KV_REPO/scripts/lib.sh" "$P/scripts/"
  printf '{\n  "flutter": "3.47.9"\n}\n' >"$P/.fvmrc"
  printf 'name: app\n' >"$P/pubspec.yaml"
  printf 'packages: {}\n' >"$P/pubspec.lock"
  printf 'name: kiveto_tool\n' >"$P/tool/pubspec.yaml"
  printf '{}\n' >"$P/.dart_tool/package_config.json"
  printf '3.47.9\n' >"$P/.make/pub-get.stamp"
  touch -t "$OLD" "$P/pubspec.yaml" "$P/pubspec.lock" "$P/tool/pubspec.yaml"
  touch -t "$STAMPED" "$P/.make/pub-get.stamp"
}

needed() {
  (cd "$P" && bash -c '. scripts/lib.sh && if pub_get_needed; then echo needed; else echo skipped; fi')
}

reset
expect_eq skipped "$(needed)" 'pub_get_needed: unchanged inputs -> skipped'

reset
rm "$P/pubspec.lock"
expect_eq skipped "$(needed)" 'pub_get_needed: a missing input is skipped'

reset
rm "$P/.make/pub-get.stamp"
expect_eq needed "$(needed)" 'pub_get_needed: no stamp -> needed'

reset
rm "$P/.dart_tool/package_config.json"
expect_eq needed "$(needed)" 'pub_get_needed: no package config (flutter clean) -> needed'

for input in pubspec.yaml pubspec.lock tool/pubspec.yaml; do
  reset
  touch -t "$NEW" "$P/$input"
  expect_eq needed "$(needed)" "pub_get_needed: newer $input -> needed"
done

reset
printf '3.44.0\n' >"$P/.make/pub-get.stamp"
touch -t "$STAMPED" "$P/.make/pub-get.stamp"
expect_eq needed "$(needed)" 'pub_get_needed: other Flutter pin -> needed'

finish
