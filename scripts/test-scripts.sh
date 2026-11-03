#!/usr/bin/env bash
# make test-scripts: the plain-bash checks of test/scripts/ (the scripts,
# the git hooks and the thin Dart entry points). Each *_test.sh prints one
# line per case; this fails when one of them fails. Flutter is needed: a few
# cases run the real fvm dart (devices.dart, the pre-commit formatter).

. "$(dirname "$0")/lib.sh"

require_flutter
pub_get_if_needed

files=()
for file in test/scripts/*_test.sh; do
  if [ -f "$file" ]; then files+=("$file"); fi
done
if [ "${#files[@]}" -eq 0 ]; then
  ok "No test/scripts/*_test.sh: nothing to run"
  exit 0
fi

failed=''
for file in "${files[@]}"; do
  step "bash $file"
  if ! run_live bash "$file"; then failed="$failed $file"; fi
done

if [ -n "$failed" ]; then
  die "Plain-bash checks failed:$failed"
fi
ok "Plain-bash checks passed (${#files[@]} files)"
