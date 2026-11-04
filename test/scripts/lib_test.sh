#!/usr/bin/env bash
# scripts/lib.sh: version_ge, env_file_for, and pub_get_needed and
# create_env_files in a temporary project holding a copy of lib.sh and its
# inputs (mtimes set with touch -t, which BSD and GNU touch both read as
# [[CC]YY]MMDDhhmm).

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
  mkdir -p "$P/scripts" "$P/tool" "$P/packages/kiveto_portal_api" "$P/.dart_tool" "$P/.make"
  cp "$KV_REPO/scripts/lib.sh" "$P/scripts/"
  printf '{\n  "flutter": "3.47.9"\n}\n' >"$P/.fvmrc"
  printf 'name: app\n' >"$P/pubspec.yaml"
  printf 'packages: {}\n' >"$P/pubspec.lock"
  printf 'name: kiveto_tool\n' >"$P/tool/pubspec.yaml"
  printf 'name: kiveto_portal_api\n' >"$P/packages/kiveto_portal_api/pubspec.yaml"
  printf '{}\n' >"$P/.dart_tool/package_config.json"
  printf '3.47.9\n' >"$P/.make/pub-get.stamp"
  touch -t "$OLD" "$P/pubspec.yaml" "$P/pubspec.lock" "$P/tool/pubspec.yaml" \
    "$P/packages/kiveto_portal_api/pubspec.yaml"
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

for input in pubspec.yaml pubspec.lock tool/pubspec.yaml packages/kiveto_portal_api/pubspec.yaml; do
  reset
  touch -t "$NEW" "$P/$input"
  expect_eq needed "$(needed)" "pub_get_needed: newer $input -> needed"
done

reset
printf '3.44.0\n' >"$P/.make/pub-get.stamp"
touch -t "$STAMPED" "$P/.make/pub-get.stamp"
expect_eq needed "$(needed)" 'pub_get_needed: other Flutter pin -> needed'

# --- env_file_for -------------------------------------------------------------

env_file() {
  (. "$KV_REPO/scripts/lib.sh" && env_file_for "$1" "$2")
}

expect_eq config/env/dev.json "$(env_file android dev)" 'env_file_for: android dev -> config/env/dev.json'
expect_eq config/env/dev.ios.json "$(env_file ios dev)" 'env_file_for: ios dev -> config/env/dev.ios.json'
expect_eq config/env/staging.json "$(env_file android staging)" 'env_file_for: android staging -> config/env/staging.json'
expect_eq config/env/staging.ios.json "$(env_file ios staging)" 'env_file_for: ios staging -> config/env/staging.ios.json'

# --- create_env_files ---------------------------------------------------------
# In the temporary project, with copies of the committed .dist files.

reset
mkdir -p "$P/config/env"
cp "$KV_REPO/config/env/dev.json.dist" "$KV_REPO/config/env/dev.ios.json.dist" "$P/config/env/"

create() {
  (cd "$P" && bash -c '. scripts/lib.sh && create_env_files' 2>&1)
}

out=$(create)
expect_eq "$(cat "$KV_REPO/config/env/dev.json.dist")" "$(cat "$P/config/env/dev.json" 2>/dev/null)" 'create_env_files: fresh clone -> dev.json from its .dist'
expect_eq "$(cat "$KV_REPO/config/env/dev.ios.json.dist")" "$(cat "$P/config/env/dev.ios.json" 2>/dev/null)" 'create_env_files: fresh clone -> dev.ios.json from its .dist'
expect_contains "$out" 'config/env/dev.json created from config/env/dev.json.dist' 'create_env_files: says dev.json was created'
expect_contains "$out" 'config/env/dev.ios.json created from config/env/dev.ios.json.dist' 'create_env_files: says dev.ios.json was created'
expect_contains "$(cat "$P/config/env/dev.ios.json" 2>/dev/null)" '"http://127.0.0.1:81"' 'create_env_files: the iOS file targets 127.0.0.1:81'

# The Mac of phase 2: its dev.json (10.0.2.2, maybe edited) and no dev.ios.json.
rm "$P/config/env/dev.ios.json"
printf '{"API_BASE_URL": "http://10.0.2.2:81", "EDITED": "yes"}\n' >"$P/config/env/dev.json"
out=$(create)
expect_eq '{"API_BASE_URL": "http://10.0.2.2:81", "EDITED": "yes"}' "$(cat "$P/config/env/dev.json")" 'create_env_files: an existing dev.json is kept as it is'
expect_contains "$out" 'config/env/dev.json kept' 'create_env_files: says dev.json was kept'
expect_eq "$(cat "$KV_REPO/config/env/dev.ios.json.dist")" "$(cat "$P/config/env/dev.ios.json" 2>/dev/null)" 'create_env_files: only the missing dev.ios.json is created'
expect_contains "$out" 'config/env/dev.ios.json created' 'create_env_files: says dev.ios.json was created'

out=$(create)
expect_contains "$out" 'config/env/dev.ios.json kept' 'create_env_files: a second run keeps both'
expect_not_contains "$out" 'created' 'create_env_files: a second run creates nothing'

# make install's success path cannot run on a fake machine (doctor stops it,
# see doctor_test.sh): check statically that it creates the env files.
calls=$(grep -cE '^[[:space:]]*create_env_files[[:space:]]*$' "$KV_REPO/scripts/install.sh") || calls=0
expect_eq 1 "$calls" 'scripts/install.sh calls create_env_files'

finish
