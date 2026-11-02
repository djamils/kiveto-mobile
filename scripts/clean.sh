#!/usr/bin/env bash
# make clean: fvm flutter clean when Flutter is available, then removes the
# .make/ stamps. The log is kept.

. "$(dirname "$0")/lib.sh"

if fvm_version >/dev/null && flutter_cached; then
  step "Removing Flutter build outputs (fvm flutter clean)..."
  run fvm flutter clean
  ok "Flutter build outputs removed"
else
  warn "Flutter $FLUTTER_VERSION is not available through FVM: fvm flutter clean skipped"
fi

rm -f "$KV_STAMPS"/*.stamp
ok "Stamps removed from $KV_STAMPS/ (log kept)"
