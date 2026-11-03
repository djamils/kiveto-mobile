#!/usr/bin/env bash
# make start: pub get only when a pubspec changed, device selection, then
#   fvm flutter run -d <id> --no-pub --dart-define-from-file=config/env/$ENV.json $RUN_ARGS
# (--no-pub: the dependencies were just checked, flutter run must not redo it).
#
# Device selection: DEVICE when set (it must be listed) -> the only running
# device of PLATFORM -> otherwise boot EMULATOR / the first AVD (android) or
# SIMULATOR / the first iPhone simulator (ios, macOS only) and wait up to
# BOOT_WAIT seconds. Several running devices: list them and ask for DEVICE=.

. "$(dirname "$0")/lib.sh"

case $PLATFORM in
  android | ios) ;;
  *) die "PLATFORM=$PLATFORM is not supported: use PLATFORM=android or PLATFORM=ios." ;;
esac
if [ "$PLATFORM" = ios ] && [ "$KV_OS" != macos ]; then
  die "iOS builds need macOS: on $KV_OS, use PLATFORM=android."
fi
case $BOOT_WAIT in
  '' | *[!0-9]*) die "BOOT_WAIT=$BOOT_WAIT must be a number of seconds." ;;
esac
BOOT_WAIT=$((10#$BOOT_WAIT))

env_file=config/env/$ENV.json
if [ ! -f "$env_file" ]; then
  if [ "$ENV" = dev ]; then
    die "$env_file is missing - fix: make install (creates it from $env_file.dist)"
  fi
  die "$env_file is missing for ENV=$ENV - fix: create it, or use ENV=dev"
fi

require_flutter
pub_get_if_needed

# --- Device selection -------------------------------------------------------

PICKED=''

# pick [<device>]: asks tool/devices.dart about the current `flutter devices`.
# Sets PICKED to its output and returns its exit code (0 one, 2 none,
# 3 several, 1 error).
pick() {
  local json rc=0
  mkdir -p "$(dirname "$LOG_FILE")"
  json=$(fvm flutter devices --machine </dev/null 2>>"$LOG_FILE") || die "fvm flutter devices failed (details in $LOG_FILE)."
  if [ "$#" -gt 0 ]; then
    PICKED=$(fvm dart tool/devices.dart --platform "$PLATFORM" --device "$1" <<<"$json") || rc=$?
  else
    PICKED=$(fvm dart tool/devices.dart --platform "$PLATFORM" <<<"$json") || rc=$?
  fi
  return "$rc"
}

# print_devices: PICKED as an indented "<id>  <name>" list.
print_devices() {
  local id name
  while IFS="$TAB" read -r id name; do
    if [ -n "$id" ]; then printf '    %-28s %s\n' "$id" "$name"; fi
  done <<<"$PICKED"
}

several() {
  fail "Several $PLATFORM devices are running: choose one with DEVICE=<id>"
  print_devices
  info "e.g. make start DEVICE=${PICKED%%"$TAB"*}"
  exit 1
}

# adb_boot_completed <id>: true once Android has booted (sys.boot_completed
# is 1) and its package manager answers (`pm path android` prints a
# package: line). The emulator once reported boot completed with dead
# services, and flutter run then hung for 15 minutes. pm itself can block
# while system_server is wedged: the device's own (toybox) timeout bounds
# it, so the BOOT_WAIT deadline is checked again.
adb_boot_completed() {
  local sdk adb value
  sdk=$(android_sdk) || return 1
  adb=$sdk/platform-tools/adb$KV_EXE
  value=$("$adb" -s "$1" shell getprop sys.boot_completed 2>/dev/null) || return 1
  [ "${value%"$CR"}" = 1 ] || return 1
  value=$("$adb" -s "$1" shell timeout 10 pm path android 2>/dev/null) || return 1
  case "$NL$value" in
    *"${NL}package:"*) return 0 ;;
  esac
  return 1
}

# wait_for_device: polls the picker (and, on Android, adb_boot_completed)
# until the booted device shows up or BOOT_WAIT seconds have passed.
wait_for_device() {
  local deadline=$((SECONDS + BOOT_WAIT)) rc
  printf 'Waiting up to %ss (BOOT_WAIT) for it to boot' "$BOOT_WAIT"
  while :; do
    rc=0
    pick || rc=$?
    case $rc in
      0)
        if [ "$PLATFORM" = ios ] || adb_boot_completed "$PICKED"; then
          printf '\n'
          DEVICE_ID=$PICKED
          return 0
        fi
        ;;
      2) ;;
      3) printf '\n' && several ;;
      *) printf '\n' && exit 1 ;;
    esac
    if [ "$SECONDS" -ge "$deadline" ]; then
      printf '\n'
      die "Not booted after ${BOOT_WAIT}s (BOOT_WAIT) - check the emulator or simulator window and $LOG_FILE first, then retry with a longer wait, e.g. make start BOOT_WAIT=300"
    fi
    printf '.'
    sleep 3
  done
}

boot_emulator() {
  local sdk out avds avd
  sdk=$(android_sdk) || die "Android SDK not found - fix: make doctor"
  out=$("$sdk/emulator/emulator$KV_EXE" -list-avds 2>>"$LOG_FILE") || die "emulator -list-avds failed (details in $LOG_FILE) - fix: make doctor"
  avds=$(tr -d '\r' <<<"$out" | grep -E '^[A-Za-z0-9._-]+$') || avds=''
  if [ -n "$EMULATOR" ]; then
    if ! grep -Fx -- "$EMULATOR" <<<"$avds" >/dev/null; then
      fail "EMULATOR=$EMULATOR is not an AVD. Available AVDs:"
      printf '    %s\n' ${avds:-(none)}
      exit 1
    fi
    avd=$EMULATOR
  else
    avd=${avds%%"$NL"*}
  fi
  if [ -z "$avd" ]; then
    die "No Android device running and no AVD to boot - fix: create one in Android Studio › Device Manager, then make start"
  fi
  step "No Android device running: booting the emulator $avd..."
  run fvm flutter emulators --launch "$avd"
  wait_for_device
  ok "Emulator $avd booted ($DEVICE_ID)"
}

boot_simulator() {
  local list udid
  list=$(xcrun simctl list devices available 2>/dev/null) || die "xcrun simctl failed - fix: check Xcode with make doctor"
  # Lines "    <name> (<UDID>) (<state>)" under "-- iOS <version> --" headers.
  udid=$(awk -v want="$SIMULATOR" '
    /^-- / { ios = ($2 == "iOS"); next }
    ios && match($0, / \([0-9A-F]+-[0-9A-F]+-[0-9A-F]+-[0-9A-F]+-[0-9A-F]+\) \(/) {
      name = substr($0, 1, RSTART - 1)
      sub(/^[ \t]+/, "", name)
      if ((want == "" && name ~ /^iPhone/) || name == want) {
        print substr($0, RSTART + 2, RLENGTH - 5)
        exit
      }
    }' <<<"$list")
  if [ -z "$udid" ]; then
    if [ -n "$SIMULATOR" ]; then
      die "SIMULATOR=$SIMULATOR is not an available iOS simulator - fix: pick a name from make devices"
    fi
    die "No iPhone simulator available - fix: add an iOS runtime in Xcode › Settings › Components"
  fi
  step "No iOS device running: booting the simulator ${SIMULATOR:-$udid}..."
  run xcrun simctl boot "$udid"
  # The window is only for the user: the booted simulator runs without it,
  # and some Xcode installs ship no Simulator.app (Xcode 27.2 seen without).
  if ! open -b com.apple.iphonesimulator >/dev/null 2>&1; then
    warn "Simulator.app not found: the simulator runs without a window"
  fi
  wait_for_device
  ok "Simulator booted ($DEVICE_ID)"
}

DEVICE_ID=''
step "Selecting a device ($PLATFORM)..."
if [ -n "$DEVICE" ]; then
  rc=0
  pick "$DEVICE" || rc=$?
  case $rc in
    0) DEVICE_ID=$PICKED ;;
    2)
      fail "DEVICE=$DEVICE is not listed by fvm flutter devices. Available ids:"
      print_devices
      exit 1
      ;;
    *) exit 1 ;;
  esac
else
  rc=0
  pick || rc=$?
  case $rc in
    0) DEVICE_ID=$PICKED ;;
    2) if [ "$PLATFORM" = ios ]; then boot_simulator; else boot_emulator; fi ;;
    3) several ;;
    *) exit 1 ;;
  esac
fi
ok "Device $DEVICE_ID"

# --- Run ----------------------------------------------------------------------

run_args=()
if [ -n "$RUN_ARGS" ]; then read -r -a run_args <<<"$RUN_ARGS"; fi

step "fvm flutter run -d $DEVICE_ID --no-pub --dart-define-from-file=$env_file${RUN_ARGS:+ $RUN_ARGS}"
run_live fvm flutter run -d "$DEVICE_ID" --no-pub --dart-define-from-file="$env_file" ${run_args[@]+"${run_args[@]}"}
