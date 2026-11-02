#!/usr/bin/env bash
# make devices: where the app can run - connected devices, AVDs and, on
# macOS, the available simulators.

. "$(dirname "$0")/lib.sh"

require_flutter

step "Connected devices (fvm flutter devices)"
run_live fvm flutter devices

step "Emulators (fvm flutter emulators)"
run_live fvm flutter emulators

if [ "$KV_OS" = macos ]; then
  step "iOS simulators (xcrun simctl list devices available)"
  run_live xcrun simctl list devices available
fi
