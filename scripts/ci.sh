#!/usr/bin/env bash
# make ci: the quality gate, run before every commit and by GitHub Actions.
# Runs the targets of KV_CI_TARGETS in order, each through the make that
# called this script (MAKE, passed by the recipe, so that V=1 and the other
# options follow), stops at the first failure and prints the duration of
# each step and the total.

. "$(dirname "$0")/lib.sh"

# api-check last: the generated client matches the contract copy.
KV_CI_TARGETS="format-check analyze test-architecture test-coverage coverage-gate test-scripts api-check"

MAKE=${MAKE:-make}

# duration <seconds>: 42s, 3m07s.
duration() {
  if [ "$1" -lt 60 ]; then
    printf '%ss' "$1"
  else
    printf '%sm%02ds' "$(($1 / 60))" "$(($1 % 60))"
  fi
}

total_start=$SECONDS
report=''
count=0
for target in $KV_CI_TARGETS; do count=$((count + 1)); done
index=0
for target in $KV_CI_TARGETS; do
  index=$((index + 1))
  step "make ci [$index/$count]: make $target"
  start=$SECONDS
  rc=0
  run_live "$MAKE" "$target" || rc=$?
  took=$(duration $((SECONDS - start)))
  if [ "$rc" -ne 0 ]; then
    printf '%s' "$report"
    die "make ci failed at $target (exit $rc, after $took; total $(duration $((SECONDS - total_start))))"
  fi
  report="$report$(printf '  %-18s %8s' "$target" "$took")$NL"
  ok "make $target ($took)"
done

step "make ci passed in $(duration $((SECONDS - total_start)))"
printf '%s' "$report"
