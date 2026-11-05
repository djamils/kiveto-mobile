#!/usr/bin/env bash
# scripts/start.sh in a temporary project (a copy of lib.sh and start.sh,
# .fvmrc, the config/env files, a pub-get stamp so that no pub get runs)
# with a stubbed fvm (4.3.2, the pinned Flutter set up, one device of the
# platform, `flutter run` logging its arguments and the environment variable
# geolocator_apple reads) and, for iOS, a stubbed macOS (uname answering
# Darwin, xcrun simctl and scutil answering from files): the env file of each
# platform, the bypass variable, the refusals that stop before any build,
# the loopback file refused for a physical iPhone, and the window of a
# running simulator (Simulator.app, else Xcode 27's DeviceHub; `open` stubbed).

. "$(dirname "$0")/support.sh"

P=$KV_T/project
FLUTTER=$(sed -n 's/.*"flutter"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$KV_REPO/.fvmrc")

# The variable must come from start.sh, not from the caller's environment.
unset BYPASS_PERMISSION_LOCATION_ALWAYS

printf '{"versions":[{"name":"%s","type":"release","directory":"/flutter","isSetup":true}]}\n' \
  "$FLUTTER" >"$KV_T/api.json"
# fvm: every call logged; `dart tool/devices.dart --platform <p>` reads the
# devices JSON on stdin and prints one id, device-<p>.
stub fvm "printf '%s\n' \"\$*\" >>'$KV_T/fvm.log'
case \"\${1:-}\" in
  --version) echo 4.3.2 ;;
  api) cat '$KV_T/api.json' ;;
  flutter)
    case \"\${2:-}\" in
      devices) echo '[]' ;;
      run)
        printf 'args=%s\n' \"\$*\" >>'$KV_T/run.log'
        printf 'bypass=%s\n' \"\${BYPASS_PERMISSION_LOCATION_ALWAYS:-unset}\" >>'$KV_T/run.log'
        ;;
      *) exit 1 ;;
    esac
    ;;
  dart)
    cat >/dev/null
    echo \"device-\${4:-}\"
    ;;
  *) exit 1 ;;
esac"

# A macOS machine for the iOS runs only (lib.sh reads uname -s): `xcrun
# simctl list devices` prints simctl.txt (fails when simctl.fail exists),
# `scutil --get LocalHostName` prints scutil.txt (fails without it).
mkdir -p "$KV_T/darwin"
printf '#!/usr/bin/env bash\necho Darwin\n' >"$KV_T/darwin/uname"
printf '#!/usr/bin/env bash\nif [ -f "%s/simctl.fail" ]; then exit 1; fi\ncat "%s/simctl.txt"\n' \
  "$KV_T" "$KV_T" >"$KV_T/darwin/xcrun"
printf '#!/usr/bin/env bash\ncat "%s/scutil.txt" 2>/dev/null\n' "$KV_T" >"$KV_T/darwin/scutil"
# `open -b <bundle id>` logs the id to open.log and fails when
# missing-<bundle id> exists (no such app on the Mac).
printf '#!/usr/bin/env bash\nprintf "%%s\\n" "$2" >>"%s/open.log"\n[ ! -f "%s/missing-$2" ]\n' \
  "$KV_T" "$KV_T" >"$KV_T/darwin/open"
chmod +x "$KV_T/darwin/uname" "$KV_T/darwin/xcrun" "$KV_T/darwin/scutil" "$KV_T/darwin/open"

# simulator <id>: simctl lists <id>, a simulator. physical: simctl lists
# another one only, so the picked device-ios is a physical iPhone.
simulator() {
  printf '== Devices ==\n-- iOS 26.0 --\n    iPhone 17 (%s) (Booted)\n' "$1" >"$KV_T/simctl.txt"
}
physical() {
  simulator 8A1F2C3D-0000-4000-8000-000000000001
}

# reset: the temporary project, both dev files created from their .dist.
reset() {
  rm -rf "$P"
  mkdir -p "$P/scripts" "$P/config/env" "$P/.dart_tool" "$P/.make"
  cp "$KV_REPO/scripts/lib.sh" "$KV_REPO/scripts/start.sh" "$P/scripts/"
  cp "$KV_REPO/.fvmrc" "$P/"
  cp "$KV_REPO/config/env/dev.json.dist" "$KV_REPO/config/env/dev.ios.json.dist" "$P/config/env/"
  cp "$P/config/env/dev.json.dist" "$P/config/env/dev.json"
  cp "$P/config/env/dev.ios.json.dist" "$P/config/env/dev.ios.json"
  printf '{}\n' >"$P/.dart_tool/package_config.json"
  printf '%s\n' "$FLUTTER" >"$P/.make/pub-get.stamp"
  : >"$KV_T/fvm.log"
  : >"$KV_T/run.log"
  : >"$KV_T/open.log"
  rm -f "$KV_T"/missing-*
  # By default the picked iOS device is a simulator; the Mac is Mac-de-Djamil.
  rm -f "$KV_T/simctl.fail"
  simulator device-ios
  printf 'Mac-de-Djamil\n' >"$KV_T/scutil.txt"
}

# start <platform> [env]: make start in the project; sets RC and OUT.
start() {
  local path=$PATH
  if [ "$1" = ios ]; then path="$KV_T/darwin:$PATH"; fi
  RC=0
  OUT=$(cd "$P" && PATH=$path PLATFORM=$1 ENV=${2:-dev} DEVICE='' EMULATOR='' SIMULATOR='' RUN_ARGS='' V=0 \
    bash scripts/start.sh 2>&1) || RC=$?
}

# --- Android --------------------------------------------------------------------

reset
start android
expect_status 0 "$RC" 'android: exit 0' "$OUT"
expect_contains "$(cat "$KV_T/run.log")" 'args=flutter run -d device-android --no-pub --dart-define-from-file=config/env/dev.json' 'android: flutter run gets config/env/dev.json'
expect_contains "$(cat "$KV_T/run.log")" 'bypass=1' 'android: BYPASS_PERMISSION_LOCATION_ALWAYS=1 in the run'
expect_not_contains "$(cat "$KV_T/fvm.log")" 'pub get' 'android: no pub get (stamp up to date)'

reset
rm "$P/config/env/dev.json"
start android
expect_status 1 "$RC" 'android without dev.json: exit 1' "$OUT"
expect_contains "$OUT" 'config/env/dev.json is missing - fix: make install (creates it from config/env/dev.json.dist)' 'android without dev.json: names the make install fix'
expect_eq '' "$(cat "$KV_T/run.log")" 'android without dev.json: no flutter run'

# --- iOS ------------------------------------------------------------------------

reset
start ios
expect_status 0 "$RC" 'ios: exit 0' "$OUT"
expect_contains "$(cat "$KV_T/run.log")" 'args=flutter run -d device-ios --no-pub --dart-define-from-file=config/env/dev.ios.json' 'ios: flutter run gets config/env/dev.ios.json'
expect_contains "$(cat "$KV_T/run.log")" 'bypass=1' 'ios: BYPASS_PERMISSION_LOCATION_ALWAYS=1 in the run'

reset
rm "$P/config/env/dev.ios.json"
start ios
expect_status 1 "$RC" 'ios without dev.ios.json: exit 1' "$OUT"
expect_contains "$OUT" 'config/env/dev.ios.json is missing - fix: make install (creates it from config/env/dev.ios.json.dist)' 'ios without dev.ios.json: names the make install fix'
expect_eq '' "$(cat "$KV_T/run.log")" 'ios without dev.ios.json: no flutter run'

reset
cp "$P/config/env/dev.json" "$P/config/env/dev.ios.json"
start ios
expect_status 1 "$RC" 'ios with 10.0.2.2: exit 1' "$OUT"
expect_contains "$OUT" 'config/env/dev.ios.json points at 10.0.2.2' 'ios with 10.0.2.2: says the file points at the Android alias'
expect_contains "$OUT" 'the iOS simulator reaches the Mac at 127.0.0.1' 'ios with 10.0.2.2: says where the simulator reaches the Mac'
expect_contains "$OUT" 'fix: rm config/env/dev.ios.json && make install' 'ios with 10.0.2.2: names the fix'
expect_eq '' "$(cat "$KV_T/run.log")" 'ios with 10.0.2.2: no flutter run'
expect_eq '' "$(cat "$KV_T/fvm.log")" 'ios with 10.0.2.2: stops before any fvm call'

# A Mac LAN address that starts like the alias (a physical iPhone).
reset
printf '{"API_BASE_URL": "http://10.0.2.23:81", "API_HOST_HEADER": "portal.kiveto.local"}\n' \
  >"$P/config/env/dev.ios.json"
start ios
expect_status 0 "$RC" 'ios with 10.0.2.23 (a LAN address): exit 0' "$OUT"
expect_contains "$(cat "$KV_T/run.log")" '--dart-define-from-file=config/env/dev.ios.json' 'ios with 10.0.2.23: flutter run gets config/env/dev.ios.json'

reset
printf '{"API_BASE_URL": "http://10.0.2.2:81", "API_HOST_HEADER": "portal.kiveto.local"}\n' \
  >"$P/config/env/staging.ios.json"
start ios staging
expect_status 1 "$RC" 'ios ENV=staging with 10.0.2.2: exit 1' "$OUT"
expect_contains "$OUT" 'point API_BASE_URL of config/env/staging.ios.json at 127.0.0.1 (simulator) or Mac-de-Djamil.local (iPhone)' 'ios ENV=staging with 10.0.2.2: names the edit to make'
expect_eq '' "$(cat "$KV_T/run.log")" 'ios ENV=staging with 10.0.2.2: no flutter run'

# --- iOS, a physical iPhone -------------------------------------------------------

reset
start ios
expect_status 0 "$RC" 'simulator + loopback file: exit 0' "$OUT"
expect_contains "$(cat "$KV_T/run.log")" '--dart-define-from-file=config/env/dev.ios.json' 'simulator + loopback file: flutter run gets dev.ios.json'

# --- iOS, the window of a simulator already running ---------------------------------

reset
start ios
expect_eq 'com.apple.iphonesimulator' "$(cat "$KV_T/open.log")" 'running simulator: Simulator.app opened'
expect_not_contains "$OUT" 'without a window' 'running simulator: no warning'

reset
: >"$KV_T/missing-com.apple.iphonesimulator"
start ios
expect_status 0 "$RC" 'running simulator, Xcode 27 (no Simulator.app): exit 0' "$OUT"
expect_eq "$(printf 'com.apple.iphonesimulator\ncom.apple.dt.Devices')" "$(cat "$KV_T/open.log")" 'running simulator, Xcode 27: DeviceHub opened'
expect_not_contains "$OUT" 'without a window' 'running simulator, Xcode 27: no warning'

reset
: >"$KV_T/missing-com.apple.iphonesimulator"
: >"$KV_T/missing-com.apple.dt.Devices"
start ios
expect_status 0 "$RC" 'running simulator, no window app: exit 0' "$OUT"
expect_contains "$OUT" 'Neither Simulator.app nor DeviceHub found: the simulator runs without a window' 'running simulator, no window app: warns'
expect_contains "$(cat "$KV_T/run.log")" '--dart-define-from-file=config/env/dev.ios.json' 'running simulator, no window app: flutter run'

reset
physical
start ios
expect_status 1 "$RC" 'physical iPhone + loopback file: exit 1' "$OUT"
expect_contains "$OUT" 'device-ios is a physical iPhone and the API_BASE_URL of config/env/dev.ios.json is on the loopback' 'physical iPhone + loopback file: says why'
expect_contains "$OUT" 'fix: in config/env/dev.ios.json, replace that host with Mac-de-Djamil.local' 'physical iPhone + loopback file: names the Bonjour name of the Mac'
expect_contains "$OUT" 'e.g. http://Mac-de-Djamil.local:81 for the dev backend' 'physical iPhone + loopback file: gives the dev URL as an example'
expect_eq '' "$(cat "$KV_T/run.log")" 'physical iPhone + loopback file: no flutter run'

reset
physical
printf '{"API_BASE_URL": "http://localhost:81", "API_HOST_HEADER": "portal.kiveto.local"}\n' \
  >"$P/config/env/dev.ios.json"
start ios
expect_status 1 "$RC" 'physical iPhone + localhost file: exit 1' "$OUT"
expect_eq '' "$(cat "$KV_T/run.log")" 'physical iPhone + localhost file: no flutter run'

reset
physical
rm "$KV_T/scutil.txt"
start ios
expect_status 1 "$RC" 'physical iPhone, scutil failing: exit 1' "$OUT"
expect_contains "$OUT" 'replace that host with <mac-name>.local' 'physical iPhone, scutil failing: says <mac-name>'

# Every loopback host of API_BASE_URL, whatever its case.
for host in 127.0.0.2 '[::1]' LOCALHOST; do
  reset
  physical
  printf '{"API_BASE_URL": "http://%s:81", "API_HOST_HEADER": "portal.kiveto.local"}\n' "$host" \
    >"$P/config/env/dev.ios.json"
  start ios
  expect_status 1 "$RC" "physical iPhone + $host: exit 1" "$OUT"
  expect_eq '' "$(cat "$KV_T/run.log")" "physical iPhone + $host: no flutter run"
done

# Only the host of API_BASE_URL counts, not another key.
reset
physical
printf '{"API_BASE_URL": "http://Mac-de-Djamil.local:81", "API_HOST_HEADER": "portal.kiveto.local", "OTHER": "http://localhost:9000"}\n' \
  >"$P/config/env/dev.ios.json"
start ios
expect_status 0 "$RC" 'physical iPhone, localhost in another key: exit 0' "$OUT"
expect_contains "$(cat "$KV_T/run.log")" '--dart-define-from-file=config/env/dev.ios.json' 'physical iPhone, localhost in another key: flutter run'

reset
printf '{"API_BASE_URL": "http://127.0.0.1:81", "API_HOST_HEADER": "portal.kiveto.local", "OTHER": "http://10.0.2.2:81"}\n' \
  >"$P/config/env/dev.ios.json"
start ios
expect_status 0 "$RC" 'ios, 10.0.2.2 in another key: exit 0' "$OUT"
expect_contains "$(cat "$KV_T/run.log")" '--dart-define-from-file=config/env/dev.ios.json' 'ios, 10.0.2.2 in another key: flutter run'

reset
physical
printf '{"API_BASE_URL": "http://Mac-de-Djamil.local:81", "API_HOST_HEADER": "portal.kiveto.local"}\n' \
  >"$P/config/env/dev.ios.json"
start ios
expect_status 0 "$RC" 'physical iPhone + Bonjour file: exit 0' "$OUT"
expect_contains "$(cat "$KV_T/run.log")" '--dart-define-from-file=config/env/dev.ios.json' 'physical iPhone + Bonjour file: flutter run gets dev.ios.json'
expect_eq '' "$(cat "$KV_T/open.log")" 'physical iPhone: no simulator window opened'

reset
physical
: >"$KV_T/simctl.fail"
start ios
expect_status 0 "$RC" 'xcrun simctl failing: no refusal (cannot tell), exit 0' "$OUT"
expect_contains "$(cat "$KV_T/run.log")" '--dart-define-from-file=config/env/dev.ios.json' 'xcrun simctl failing: flutter run gets dev.ios.json'
expect_eq '' "$(cat "$KV_T/open.log")" 'xcrun simctl failing: no window opened (cannot tell)'

reset
start ios staging
expect_status 1 "$RC" 'ios ENV=staging without its file: exit 1' "$OUT"
expect_contains "$OUT" 'config/env/staging.ios.json is missing for ENV=staging - fix: create config/env/staging.ios.json, or use ENV=dev' 'ios ENV=staging without its file: names the file to create'
expect_eq '' "$(cat "$KV_T/run.log")" 'ios ENV=staging without its file: no flutter run'

finish
