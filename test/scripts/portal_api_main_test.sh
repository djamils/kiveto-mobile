#!/usr/bin/env bash
# tool/portal_api.dart and tool/normalize_contract.dart, the thin entry
# points of make api-generate and make api-check, with the real fvm dart:
# their exit codes must reach the process (a bare call would turn
# make api-check into a report while make ci stays green). The libraries
# are tested by test/tool/portal_api_test.dart and
# test/tool/contract_normalizer_test.dart.

. "$(dirname "$0")/support.sh"

# --- tool/portal_api.dart, in a temporary repository ------------------------------

P=$KV_T/project
mkdir -p "$P/contracts" "$P/tool/api_generator" "$P/tool/lib" "$P/packages/kiveto_portal_api/lib"
cp "$KV_REPO/.fvmrc" "$P/"
printf 'openapi: 3.2.0\n' >"$P/contracts/portal.v1.yaml"
printf 'spec: x\n' >"$P/tool/api_generator/tonik.yaml"
printf 'packages:\n  tonik:\n    source: hosted\n    version: "0.11.1"\n' >"$P/tool/api_generator/pubspec.lock"
printf '// normaliser\n' >"$P/tool/lib/contract_normalizer.dart"
printf 'class Me {}\n' >"$P/packages/kiveto_portal_api/lib/me.dart"

# portal_api <command>: tool/portal_api.dart run from the temporary
# repository (its root is the current directory), with the packages of
# this one.
portal_api() {
  RC=0
  OUT=$(cd "$P" && with_real_fvm fvm dart --packages="$KV_REPO/.dart_tool/package_config.json" \
    "$KV_REPO/tool/portal_api.dart" "$@" 2>"$KV_T/err") || RC=$?
  ERR=$(cat "$KV_T/err")
}

portal_api check
expect_status 1 "$RC" 'check without contracts/SOURCE: exit 1' "$OUT$NL$ERR"
expect_contains "$ERR" 'contracts/SOURCE is missing - fix: make api-sync REF=<sha>' 'check without contracts/SOURCE: names it'

# SOURCE with the copy's sha256, as make api-sync writes it.
if command -v sha256sum >/dev/null 2>&1; then
  digest=$(sha256sum "$P/contracts/portal.v1.yaml" | cut -c1-64)
else
  digest=$(shasum -a 256 "$P/contracts/portal.v1.yaml" | cut -c1-64)
fi
printf 'commit: 840dbead0202f55a4e8aacf2858a579d2b828f45\nsha256: %s\n' "$digest" >"$P/contracts/SOURCE"

portal_api stamp
expect_status 0 "$RC" 'stamp: exit 0' "$OUT$NL$ERR"
expect_contains "$(cat "$P/packages/kiveto_portal_api/CONTRACT" 2>/dev/null)" "sha256: $digest" 'stamp: CONTRACT written'

portal_api check
expect_status 0 "$RC" 'check on an agreeing tree: exit 0' "$OUT$NL$ERR"
expect_contains "$OUT" "api-check: contract $digest" 'check on an agreeing tree: the success line'

printf 'x: 1\n' >>"$P/contracts/portal.v1.yaml"
portal_api check
expect_status 1 "$RC" 'check after a line appended to the copy: exit 1' "$OUT$NL$ERR"
expect_contains "$ERR" 'contracts/portal.v1.yaml was edited by hand' 'check after a line appended: edited by hand'
expect_contains "$ERR" 'was generated from another contract' 'check after a line appended: client from another contract'

portal_api bogus
expect_status 64 "$RC" 'an unknown command: exit 64' "$OUT$NL$ERR"

# --- tool/normalize_contract.dart, from the repository ----------------------------

cd "$KV_REPO" || exit 1

cat >"$KV_T/contract.yaml" <<'EOF'
openapi: 3.2.0
paths:
  /x:
    get:
      operationId: api_x_get
      responses:
        '200':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/X'
components:
  schemas:
    X:
      type: object
      properties:
        id:
          type: string
EOF

normalize() {
  RC=0
  OUT=$(with_real_fvm fvm dart tool/normalize_contract.dart "$KV_T/contract.yaml" "$KV_T/tonik.yaml" \
    "$KV_T/build/portal.v1.yaml" 2>"$KV_T/err") || RC=$?
  ERR=$(cat "$KV_T/err")
}

printf 'nameOverrides:\n  operations: {}\n' >"$KV_T/tonik.yaml"
normalize
expect_status 1 "$RC" 'normalize an unnamed operation: exit 1' "$OUT$NL$ERR"
expect_contains "$ERR" 'nameOverrides.operations: api_x_get - add a readable name' 'normalize an unnamed operation: names it'

printf 'nameOverrides:\n  operations:\n    api_x_get: getX\n' >"$KV_T/tonik.yaml"
normalize
expect_status 0 "$RC" 'normalize a named contract: exit 0' "$OUT$NL$ERR"
expect_contains "$OUT" 'required added to 1 response-only schemas' 'normalize a named contract: says what it did'
expect_contains "$(cat "$KV_T/build/portal.v1.yaml" 2>/dev/null)" "      required:$NL        - id" \
  'normalize a named contract: copy written'

finish
