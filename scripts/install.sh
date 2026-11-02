#!/usr/bin/env bash
# make install: doctor blockers, pinned Flutter through FVM, pub get, git
# hooks once .githooks/ exists, config/env/dev.json, summary. Idempotent:
# a second run downloads nothing. Installs nothing system-wide.

. "$(dirname "$0")/lib.sh"

step "Checking prerequisites..."
KV_CALLER=install bash scripts/doctor.sh --quiet
ok "Prerequisites ok"

step "Installing Flutter $FLUTTER_VERSION (fvm install)..."
if ! flutter_cached; then
  info "Not in the FVM cache yet: FVM downloads it once, this takes a while (output in $LOG_FILE)."
fi
run fvm install --skip-pub-get
ok "Flutter $FLUTTER_VERSION ready"

pub_get_if_needed

if [ -d .githooks ]; then
  if [ "$(git config --local --get core.hooksPath 2>/dev/null || true)" != .githooks ]; then
    git config --local core.hooksPath .githooks
  fi
  ok "Git hooks active (core.hooksPath=.githooks, this repository only)"
fi

if [ -f config/env/dev.json ]; then
  ok "config/env/dev.json kept"
else
  cp config/env/dev.json.dist config/env/dev.json
  ok "config/env/dev.json created from config/env/dev.json.dist"
fi

step "Install complete: Flutter $FLUTTER_VERSION through FVM $(fvm_version)"
info "make start      run the app (PLATFORM=android|ios, DEVICE=<id>, ENV=dev)"
info "make devices    list devices, emulators and simulators"
info "make doctor     check the prerequisites again"
info "make help       every target and option"
