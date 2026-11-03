#!/usr/bin/env bash
# make api-sync, api-generate, api-check: the Portal API contract copy and
# its generated client (architecture §4, CONTRIBUTING.md §8).
#
#   bash scripts/api.sh sync       copy openapi/portal.v1.yaml of the backend
#                                  checkout KIVETO_BACKEND_DIR (default
#                                  ../kiveto) at REF into contracts/, then
#                                  generate (make api-sync REF=<sha>)
#   bash scripts/api.sh generate   normalise the copy into build/, run tonik
#                                  in tool/api_generator, stamp the client
#                                  (make api-generate)
#   bash scripts/api.sh check      the copy, contracts/SOURCE and the client
#                                  agree (make api-check, a step of make ci)
#
# The logic is Dart: tool/portal_api.dart (sync, stamp, check) and
# tool/normalize_contract.dart. REF is checked here, before any fvm call,
# because fvm hands its arguments to cmd.exe on Windows.

. "$(dirname "$0")/lib.sh"

REF=${REF:-}
KIVETO_BACKEND_DIR=${KIVETO_BACKEND_DIR:-../kiveto}

# The generator runs from tool/api_generator: the quiet runner's log must
# not follow it there.
case $LOG_FILE in
  /* | [A-Za-z]:*) ;;
  *) LOG_FILE=$KV_ROOT/$LOG_FILE ;;
esac

# What git checkout must restore to go back after a failed generation:
# api-sync has already rewritten contracts/ too.
KV_RESTORE=packages/kiveto_portal_api

generate_failed() {
  die "make $KV_TARGET failed - fix the cause shown above (e.g. add the missing names to tool/api_generator/tonik.yaml), then make api-generate; or go back with git checkout -- $KV_RESTORE && git clean -fdq -- packages/kiveto_portal_api"
}

generate() {
  # The normaliser writes build/ only, and the generator is resolved before
  # anything is removed: the committed client stays in place until the
  # contract is accepted (no name missing from tonik.yaml) and tonik is
  # installed (pub.dev reachable or the pub cache warm).
  step "Normalising contracts/portal.v1.yaml (build/kiveto_portal_api/portal.v1.yaml)..."
  rm -rf build/kiveto_portal_api
  run fvm dart tool/normalize_contract.dart contracts/portal.v1.yaml \
    tool/api_generator/tonik.yaml build/kiveto_portal_api/portal.v1.yaml || generate_failed

  step "Generating packages/kiveto_portal_api (tonik, tool/api_generator)..."
  cd tool/api_generator
  run fvm dart pub get --enforce-lockfile || generate_failed
  rm -rf "$KV_ROOT/packages/kiveto_portal_api" || generate_failed
  run fvm dart run tonik --config tonik.yaml || generate_failed
  cd "$KV_ROOT"
  run fvm dart tool/portal_api.dart stamp || generate_failed
  ok "packages/kiveto_portal_api generated and stamped (CONTRACT)"

  # The client's pubspec is new: the app resolves it again.
  pub_get_if_needed
}

case ${1:-} in
  sync)
    if [ -z "$REF" ]; then
      die "REF is required: make api-sync REF=<backend commit>"
    fi
    case $REF in
      -* | *[!0-9A-Za-z._/-]*)
        die "REF '$REF' may only hold letters, digits and . _ / - (not first): a commit SHA, branch or tag of the backend"
        ;;
    esac
    # It reaches fvm too, hence cmd.exe on Windows.
    case $KIVETO_BACKEND_DIR in
      *[\|\^\&\<\>%\"]*)
        die "KIVETO_BACKEND_DIR '$KIVETO_BACKEND_DIR' may not hold | ^ & < > % or \" (fvm passes it through cmd.exe on Windows): use a path without them"
        ;;
    esac
    if [ ! -d "$KIVETO_BACKEND_DIR" ]; then
      die "$KIVETO_BACKEND_DIR is not a git checkout of djamils/kiveto - set KIVETO_BACKEND_DIR, e.g. make api-sync REF=$REF KIVETO_BACKEND_DIR=//wsl.localhost/<distro>/<path>/kiveto"
    fi
    require_flutter
    pub_get_if_needed
    step "Copying openapi/portal.v1.yaml of $KIVETO_BACKEND_DIR at $REF..."
    run fvm dart tool/portal_api.dart sync "$KIVETO_BACKEND_DIR" "$REF"
    ok "contracts/portal.v1.yaml and contracts/SOURCE written"
    KV_RESTORE="contracts $KV_RESTORE"
    generate
    ;;
  generate)
    require_flutter
    pub_get_if_needed
    generate
    ;;
  check)
    require_flutter
    pub_get_if_needed
    step "Checking the contract copy and the generated client (fvm dart tool/portal_api.dart check)..."
    run_live fvm dart tool/portal_api.dart check ||
      die "make api-check failed: the contract copy and the generated client disagree (causes above)"
    ;;
  *)
    die "Unknown command '${1:-}': use sync, generate or check."
    ;;
esac
