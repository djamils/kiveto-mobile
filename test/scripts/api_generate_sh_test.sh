#!/usr/bin/env bash
# scripts/api.sh generate and sync past their argument checks, in a
# temporary project holding a copy of scripts/, with a stub fvm (the pinned
# Flutter set up; any call naming the text of KV_T/fail-at fails): the
# committed client stays in place when the normaliser refuses the contract
# or the generator cannot be resolved, the failure says what to restore
# (contracts/ too after a sync), and a relative LOG_FILE still lands in the
# project once the script has moved to tool/api_generator. The real
# generation (tonik) is checked by hand: the spec's implementation notes.

. "$(dirname "$0")/support.sh"

P=$KV_T/project
mkdir -p "$P/.dart_tool" "$P/.make" "$P/contracts" "$P/tool/api_generator" \
  "$P/packages/kiveto_portal_api/lib" "$KV_T/backend"
cp -R "$KV_REPO/scripts" "$P/"
cp "$KV_REPO/.fvmrc" "$P/"
FLUTTER=$(sed -n 's/.*"flutter"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$P/.fvmrc")
printf '{}\n' >"$P/.dart_tool/package_config.json"
printf 'name: kiveto_portal_api\n' >"$P/packages/kiveto_portal_api/pubspec.yaml"
printf 'class Me {}\n' >"$P/packages/kiveto_portal_api/lib/me.dart"
# Written last: no input is newer, so no pub get is due.
printf '%s\n' "$FLUTTER" >"$P/.make/pub-get.stamp"

cat >"$KV_T/bin/fvm" <<EOF
#!/usr/bin/env bash
printf '%s\n' "\$*" >>"$KV_T/fvm.log"
case "\${1:-}" in
  --version) echo 4.3.2; exit 0 ;;
  api) printf '{"versions":[{"name":"%s","isSetup":true}]}\n' "$FLUTTER"; exit 0 ;;
esac
fail=\$(cat "$KV_T/fail-at" 2>/dev/null)
if [ -n "\$fail" ]; then
  case "\$*" in *"\$fail"*) echo "stub: \$* failed"; exit 1 ;; esac
fi
exit 0
EOF
chmod +x "$KV_T/bin/fvm"

# api <command> <fail-at> [VAR=value...]: bash scripts/api.sh <command>, the
# stub failing on the call that names <fail-at>.
api() {
  local command=$1
  printf '%s' "$2" >"$KV_T/fail-at"
  shift 2
  : >"$KV_T/fvm.log"
  RC=0
  OUT=$(cd "$P" && env REF= KIVETO_BACKEND_DIR= "$@" bash scripts/api.sh "$command" 2>&1) || RC=$?
}

client_kept() {
  if [ -f "$P/packages/kiveto_portal_api/lib/me.dart" ]; then echo kept; else echo removed; fi
}

api generate normalize_contract
expect_status 1 "$RC" 'api-generate, contract refused by the normaliser: exit 1' "$OUT"
expect_eq kept "$(client_kept)" 'api-generate, contract refused: the committed client stays'
expect_contains "$OUT" 'then make api-generate; or go back with git checkout -- packages/kiveto_portal_api && git clean -fdq -- packages/kiveto_portal_api' \
  'api-generate, contract refused: says how to go back'
expect_not_contains "$OUT" 'checkout -- contracts' 'api-generate, contract refused: contracts/ untouched, not restored'

api generate 'pub get --enforce-lockfile'
expect_status 1 "$RC" 'api-generate, generator not resolved: exit 1' "$OUT"
expect_eq kept "$(client_kept)" 'api-generate, generator not resolved: the committed client stays'
expect_not_contains "$(cat "$KV_T/fvm.log")" 'run tonik' 'api-generate, generator not resolved: tonik never run'

api sync normalize_contract REF=840dbead "KIVETO_BACKEND_DIR=$KV_T/backend"
expect_status 1 "$RC" 'api-sync, contract refused by the normaliser: exit 1' "$OUT"
expect_contains "$(cat "$KV_T/fvm.log")" "dart tool/portal_api.dart sync $KV_T/backend 840dbead" \
  'api-sync: copies the contract at REF from KIVETO_BACKEND_DIR first'
expect_contains "$OUT" 'go back with git checkout -- contracts packages/kiveto_portal_api' \
  'api-sync, contract refused: says to restore contracts/ too'
expect_eq kept "$(client_kept)" 'api-sync, contract refused: the committed client stays'

rm -f "$P/.make/make.log"
api generate 'run tonik' LOG_FILE=.make/make.log
expect_status 1 "$RC" 'api-generate, tonik failing, relative LOG_FILE: exit 1' "$OUT"
expect_contains "$(cat "$P/.make/make.log" 2>/dev/null)" 'fvm dart run tonik --config tonik.yaml' \
  'a relative LOG_FILE is the project'"'"'s, also once in tool/api_generator'

finish
