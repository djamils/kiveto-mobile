#!/usr/bin/env bash
# scripts/api.sh check (make api-check, the last step of make ci) with the
# real fvm dart, in a temporary project holding copies of scripts/, the
# contract commands (tool/portal_api.dart, tool/lib/) and the package
# config: it passes on an agreeing tree and fails, saying why, once the
# contract copy is edited (an exit 0 there would turn make ci green on a
# drift).

. "$(dirname "$0")/support.sh"

P=$KV_T/project
mkdir -p "$P/tool" "$P/.dart_tool" "$P/.make" "$P/contracts" "$P/tool/api_generator" \
  "$P/packages/kiveto_portal_api/lib"
cp -R "$KV_REPO/scripts" "$P/"
cp -R "$KV_REPO/tool/lib" "$P/tool/"
cp "$KV_REPO/tool/portal_api.dart" "$P/tool/"
cp "$KV_REPO/.fvmrc" "$P/"
cp "$KV_REPO/.dart_tool/package_config.json" "$P/.dart_tool/"
FLUTTER=$(sed -n 's/.*"flutter"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$P/.fvmrc")
printf '%s\n' "$FLUTTER" >"$P/.make/pub-get.stamp"

# A synced contract, the generator inputs and a one-file client.
printf 'openapi: 3.2.0\n' >"$P/contracts/portal.v1.yaml"
if command -v sha256sum >/dev/null 2>&1; then
  digest=$(sha256sum "$P/contracts/portal.v1.yaml" | cut -c1-64)
else
  digest=$(shasum -a 256 "$P/contracts/portal.v1.yaml" | cut -c1-64)
fi
printf 'commit: 840dbead0202f55a4e8aacf2858a579d2b828f45\nsha256: %s\n' "$digest" >"$P/contracts/SOURCE"
printf 'spec: x\n' >"$P/tool/api_generator/tonik.yaml"
printf 'packages:\n  tonik:\n    source: hosted\n    version: "0.11.1"\n' >"$P/tool/api_generator/pubspec.lock"
printf 'class Me {}\n' >"$P/packages/kiveto_portal_api/lib/me.dart"

RC=0
OUT=$(cd "$P" && with_real_fvm fvm dart tool/portal_api.dart stamp 2>&1) || RC=$?
expect_status 0 "$RC" 'the client stamped (tool/portal_api.dart stamp)' "$OUT"

check() {
  RC=0
  OUT=$(cd "$P" && with_real_fvm bash scripts/api.sh check 2>&1) || RC=$?
}

check
expect_status 0 "$RC" 'make api-check on an agreeing tree: exit 0' "$OUT"
expect_contains "$OUT" "api-check: contract $digest" 'make api-check on an agreeing tree: the success line'

printf 'x: 1\n' >>"$P/contracts/portal.v1.yaml"
check
expect_status 1 "$RC" 'make api-check after a line appended to the copy: exit 1' "$OUT"
expect_contains "$OUT" 'contracts/portal.v1.yaml was edited by hand' \
  'make api-check after a line appended to the copy: edited by hand'
expect_contains "$OUT" 'make api-check failed' 'make api-check after a line appended to the copy: says it failed'

finish
