#!/usr/bin/env bash
# make format / make format-check: fvm dart format on lib/, test/, tool/ and
# integration_test/ when it exists. The formatter reads its options (VGA's
# trailing commas, the language version) through analysis_options.yaml and
# the package config, hence the pub get first.
#
#   bash scripts/format.sh           rewrites the files (make format)
#   bash scripts/format.sh --check   changes nothing, fails when a file is
#                                    not formatted (make format-check)

. "$(dirname "$0")/lib.sh"

CHECK=0
case ${1:-} in
  '') ;;
  --check) CHECK=1 ;;
  *) die "Unknown argument '$1': use --check or nothing." ;;
esac

dirs=(lib test tool)
if [ -d integration_test ]; then dirs+=(integration_test); fi

require_flutter
pub_get_if_needed

if [ "$CHECK" = 0 ]; then
  step "Formatting ${dirs[*]} (fvm dart format)..."
  run fvm dart format "${dirs[@]}"
  ok "Dart files formatted"
  exit 0
fi

step "Checking the format of ${dirs[*]} (fvm dart format)..."
if ! run fvm dart format --output=none --set-exit-if-changed "${dirs[@]}"; then
  # dart format prints "Changed <file>" for each file it would rewrite: in
  # the lines above (quiet run) or in its live output (V=1).
  die "Dart files not formatted (the \"Changed\" lines above) - fix: make format"
fi
ok "Dart files formatted"
