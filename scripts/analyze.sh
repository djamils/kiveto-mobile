#!/usr/bin/env bash
# make analyze: fvm dart analyze with infos and warnings fatal, on the rules
# of analysis_options.yaml (very_good_analysis, riverpod_lint).

. "$(dirname "$0")/lib.sh"

require_flutter
pub_get_if_needed

step "Analyzing (fvm dart analyze --fatal-infos --fatal-warnings)..."
run fvm dart analyze --fatal-infos --fatal-warnings
ok "No analyzer issue"
