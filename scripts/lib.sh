# Shared helpers of the make targets, sourced by every scripts/*.sh.
#
# Written for bash 3.2 (macOS /bin/bash) and Git Bash, LF line endings: no
# bash 4 feature (associative arrays, case-changing expansions, reading
# lines into arrays, the strftime format of printf, set-variable tests) and
# no expansion of a possibly empty array under set -u. The architecture
# document (section 7) lists the rules; the spec's grep checks them.
# Options come from the Makefile as environment variables; the defaults
# below only matter when a script is run by hand.

set -euo pipefail

KV_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$KV_ROOT"

# The make target, for the log: the Makefile passes it (KV_TARGET=$@), a
# script run by hand uses its own name.
KV_TARGET=${KV_TARGET:-$(basename "$0" .sh)}

PLATFORM=${PLATFORM:-android}
DEVICE=${DEVICE:-}
EMULATOR=${EMULATOR:-}
SIMULATOR=${SIMULATOR:-}
ENV=${ENV:-dev}
RUN_ARGS=${RUN_ARGS:-}
BOOT_WAIT=${BOOT_WAIT:-180}
V=${V:-0}
NO_COLOR=${NO_COLOR:-}
LOG_FILE=${LOG_FILE:-.make/make.log}
FULL=${FULL:-0}

KV_STAMPS=.make
KV_PUB_STAMP=$KV_STAMPS/pub-get.stamp

# The files whose change calls for a pub get (missing ones are skipped).
# Phase 4 adds the generated client's packages/kiveto_portal_api/pubspec.yaml.
KV_PUB_INPUTS="pubspec.yaml pubspec.lock tool/pubspec.yaml"

# The test suites, folders of test/: `make test` runs them all, `make
# test-coverage` the ones that load lib/ and tool/lib/ (the architecture
# tests only read files).
KV_TEST_SUITES="unit widget integration tool architecture"
KV_COVERAGE_SUITES="unit widget integration tool"

# suite_has_tests <suite>: true when test/<suite>/ holds a *_test.dart file.
suite_has_tests() {
  [ -d "test/$1" ] && [ -n "$(find "test/$1" -name '*_test.dart' -type f 2>/dev/null | head -n 1)" ]
}

NL='
'
TAB=$(printf '\t')
CR=$(printf '\r')

# --- Output -----------------------------------------------------------------

if [ -n "$NO_COLOR" ] && [ "$NO_COLOR" != "0" ]; then
  C_RESET='' C_GREEN='' C_YELLOW='' C_BLUE='' C_RED='' C_DIM=''
else
  C_RESET=$(printf '\033[0m')
  C_GREEN=$(printf '\033[0;32m')
  C_YELLOW=$(printf '\033[0;33m')
  C_BLUE=$(printf '\033[0;34m')
  C_RED=$(printf '\033[0;31m')
  C_DIM=$(printf '\033[2m')
fi

step() { printf '\n%s→ %s%s\n' "$C_BLUE" "$*" "$C_RESET"; }
ok() { printf '%s✓ %s%s\n' "$C_GREEN" "$*" "$C_RESET"; }
warn() { printf '%s! %s%s\n' "$C_YELLOW" "$*" "$C_RESET"; }
fail() { printf '%s✗ %s%s\n' "$C_RED" "$*" "$C_RESET"; }
info() { printf '  %s\n' "$*"; }
die() {
  fail "$*"
  exit 1
}

# --- Platform ---------------------------------------------------------------

case "$(uname -s)" in
  MINGW* | MSYS* | CLANG64_NT* | CLANGARM64_NT* | UCRT64_NT*) KV_OS=windows KV_EXE=.exe KV_BAT=.bat ;;
  Darwin) KV_OS=macos KV_EXE='' KV_BAT='' ;;
  # GitHub Actions runs make ci on Linux; the developer targets (install,
  # start, install-fvm) stay Windows and macOS.
  Linux*) KV_OS=linux KV_EXE='' KV_BAT='' ;;
  *) die "Unsupported system '$(uname -s)': use Git Bash on Windows 11, or macOS." ;;
esac

# to_unix <path>: a path as this shell sees it (C:\x becomes /c/x in Git Bash).
to_unix() {
  if [ "$KV_OS" = windows ]; then cygpath -u "$1"; else printf '%s\n' "$1"; fi
}

# version_ge <a> <b>: true when the dotted version a is >= b.
version_ge() {
  local a=$1 b=$2 x y
  while [ -n "$a" ] || [ -n "$b" ]; do
    x=${a%%.*} y=${b%%.*}
    case $a in *.*) a=${a#*.} ;; *) a='' ;; esac
    case $b in *.*) b=${b#*.} ;; *) b='' ;; esac
    x=${x%%[!0-9]*} y=${y%%[!0-9]*}
    x=$((10#${x:-0})) y=$((10#${y:-0}))
    if [ "$x" -gt "$y" ]; then return 0; fi
    if [ "$x" -lt "$y" ]; then return 1; fi
  done
  return 0
}

# --- Quiet runner -----------------------------------------------------------
# Same contract as the `run` macro of the Kiveto Symfony Makefile: output
# goes to LOG_FILE with a timestamp per line, and the last 30 lines of the
# target are shown when the command fails. V=1 runs the command live.

KV_LOG_FROM=''

log_open() {
  if [ -n "$KV_LOG_FROM" ]; then return 0; fi
  mkdir -p "$(dirname "$LOG_FILE")"
  touch "$LOG_FILE"
  KV_LOG_FROM=$(($(wc -l <"$LOG_FILE") + 1))
  printf '\n[%s] ▶ make %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$KV_TARGET" >>"$LOG_FILE"
}

# Prefixes each line of stdin with a timestamp. date(1) runs at most once a
# second (bash 3.2 has no strftime builtin), and Windows tools lose their CR.
timestamp_lines() {
  local line ts='' last=-1
  while IFS= read -r line || [ -n "$line" ]; do
    if [ "$SECONDS" != "$last" ]; then
      ts=$(date '+%Y-%m-%d %H:%M:%S')
      last=$SECONDS
    fi
    printf '[%s] %s\n' "$ts" "${line%"$CR"}"
  done
}

# run <command> [args...]: runs the command quietly (see above).
run() {
  local rc=0
  if [ "$V" = "1" ]; then
    printf '%s+ %s%s\n' "$C_DIM" "$*" "$C_RESET"
    "$@" || rc=$?
    return "$rc"
  fi
  log_open
  printf '[%s] $ %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >>"$LOG_FILE"
  set +e
  "$@" </dev/null 2>&1 | timestamp_lines >>"$LOG_FILE"
  rc=${PIPESTATUS[0]}
  set -e
  if [ "$rc" -ne 0 ]; then
    printf '[%s] ✗ make %s failed (exit %s)\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$KV_TARGET" "$rc" >>"$LOG_FILE"
    fail "make $KV_TARGET failed (exit $rc) - last lines of $LOG_FILE:"
    tail -n +"$KV_LOG_FROM" "$LOG_FILE" | tail -n 30 >&2
    return "$rc"
  fi
}

# run_live <command> [args...]: interactive commands (flutter run, lists).
run_live() {
  if [ "$V" = "1" ]; then printf '%s+ %s%s\n' "$C_DIM" "$*" "$C_RESET"; fi
  "$@"
}

# --- FVM and Flutter --------------------------------------------------------

FLUTTER_VERSION=$(sed -n 's/.*"flutter"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' .fvmrc 2>/dev/null) || FLUTTER_VERSION=''
FLUTTER_VERSION=${FLUTTER_VERSION%%"$NL"*}
if [ -z "$FLUTTER_VERSION" ]; then die "No Flutter version pinned in .fvmrc."; fi

fvm_fix() {
  case $KV_OS in
    windows) printf 'make install-fvm, or choco install fvm' ;;
    macos) printf 'make install-fvm, or brew tap btwld/fvm && brew install btwld/fvm/fvm' ;;
    linux) printf 'install FVM 4.3.2 from its GitHub release (see .github/workflows/ci.yml)' ;;
  esac
}

# fvm_upgrade_fix: make install-fvm refuses while an fvm is on PATH.
fvm_upgrade_fix() {
  case $KV_OS in
    windows) printf 'choco upgrade fvm' ;;
    macos) printf 'brew upgrade btwld/fvm/fvm' ;;
    linux) printf 'install FVM 4.3.2 from its GitHub release' ;;
  esac
  printf ', or dart pub global activate fvm, or remove the old fvm from PATH then make install-fvm'
}

# fvm_version: the version of the fvm found on PATH; fails when there is none.
fvm_version() {
  local out
  command -v fvm >/dev/null 2>&1 || return 1
  out=$(fvm --version 2>/dev/null) || return 1
  out=${out%%"$NL"*}
  printf '%s\n' "${out%"$CR"}"
}

# flutter_cached: true when the pinned Flutter is set up in the FVM cache.
flutter_cached() {
  local list
  list=$(fvm api list --compress --skip-size-calculation 2>/dev/null) || return 1
  grep -o '{[^{}]*}' <<<"$list" | grep -F "\"name\":\"$FLUTTER_VERSION\"" | grep -F '"isSetup":true' >/dev/null
}

# require_flutter: stops unless FVM >= 4 and the pinned Flutter are installed.
require_flutter() {
  local version
  version=$(fvm_version) || die "FVM is not on PATH - fix: $(fvm_fix)"
  version_ge "$version" 4 || die "FVM $version is too old (4 or later needed) - fix: $(fvm_upgrade_fix)"
  flutter_cached || die "Flutter $FLUTTER_VERSION is not in the FVM cache - fix: make install"
}

# flutter_sdk_dir: the directory of the pinned Flutter SDK in the FVM cache
# (the "directory" of its entry in `fvm api list`, JSON-escaped on Windows:
# D:\\Dev\\fvm\\versions\\3.47.9); fails when FVM does not list it.
flutter_sdk_dir() {
  local list dir
  list=$(fvm api list --compress --skip-size-calculation 2>/dev/null) || return 1
  dir=$(grep -o '{[^{}]*}' <<<"$list" | grep -F "\"name\":\"$FLUTTER_VERSION\"" |
    sed -n 's/.*"directory":"\([^"]*\)".*/\1/p') || return 1
  dir=${dir%%"$NL"*}
  [ -n "$dir" ] || return 1
  dir=$(printf '%s\n' "$dir" | sed 's/\\\\/\\/g')
  to_unix "$dir"
}

# pub_get_needed: true when a file of KV_PUB_INPUTS changed since the last
# pub get, the Flutter pin changed, or `flutter clean` removed .dart_tool/.
pub_get_needed() {
  local input
  if [ ! -f "$KV_PUB_STAMP" ] || [ ! -f .dart_tool/package_config.json ]; then return 0; fi
  for input in $KV_PUB_INPUTS; do
    if [ -f "$input" ] && [ "$input" -nt "$KV_PUB_STAMP" ]; then return 0; fi
  done
  if [ "$(cat "$KV_PUB_STAMP")" != "$FLUTTER_VERSION" ]; then return 0; fi
  return 1
}

# pub_get_if_needed: fvm flutter pub get, only when pub_get_needed.
pub_get_if_needed() {
  if ! pub_get_needed; then
    ok "Dart dependencies up to date (pub get skipped)"
    return 0
  fi
  step "Resolving Dart dependencies..."
  run fvm flutter pub get
  mkdir -p "$KV_STAMPS"
  printf '%s\n' "$FLUTTER_VERSION" >"$KV_PUB_STAMP"
  ok "Dart dependencies resolved"
}

# --- Android SDK and JDK ----------------------------------------------------

# android_sdk: the Android SDK directory (ANDROID_HOME, else the OS default).
android_sdk() {
  local sdk=${ANDROID_HOME:-}
  if [ -z "$sdk" ]; then
    case $KV_OS in
      windows) sdk="$(to_unix "${LOCALAPPDATA:-$HOME/AppData/Local}")/Android/Sdk" ;;
      macos) sdk="$HOME/Library/Android/sdk" ;;
      linux) sdk="$HOME/Android/Sdk" ;;
    esac
  fi
  sdk=$(to_unix "$sdk")
  [ -d "$sdk" ] || return 1
  printf '%s\n' "$sdk"
}

# reg_value <key> <name>: the data of a Windows registry value.
reg_value() {
  local out
  out=$(MSYS_NO_PATHCONV=1 reg query "$1" /v "$2" 2>/dev/null) || return 1
  tr -d '\r' <<<"$out" | sed -n "s/^[[:space:]]*$2[[:space:]]\{1,\}REG_[A-Z_]*[[:space:]]\{1,\}//p"
}

# studio_jbr: the JDK bundled with Android Studio, when Android Studio is found.
studio_jbr() {
  local dir='' home
  case $KV_OS in
    windows)
      dir=$(reg_value 'HKLM\SOFTWARE\Android Studio' Path) || dir=''
      if [ -z "$dir" ]; then
        for home in "$(to_unix "${LOCALAPPDATA:-$HOME/AppData/Local}")"/Google/AndroidStudio*/.home; do
          if [ -f "$home" ]; then dir=$(tr -d '\r' <"$home"); fi
        done
      fi
      if [ -z "$dir" ]; then dir="${PROGRAMFILES:-C:\\Program Files}\\Android\\Android Studio"; fi
      dir="$(to_unix "$dir")/jbr"
      ;;
    macos)
      for home in "/Applications/Android Studio.app" "$HOME/Applications/Android Studio.app"; do
        if [ -d "$home" ]; then dir="$home/Contents/jbr/Contents/Home"; fi
      done
      ;;
    linux) ;; # make ci only: no Android Studio lookup (JAVA_HOME or PATH).
  esac
  [ -n "$dir" ] && [ -f "$dir/bin/javac$KV_EXE" ] || return 1
  printf '%s\n' "$dir"
}

# find_jdk: sets JDK_HOME and JDK_FROM to the JDK Gradle gets: Android
# Studio's jbr, else JAVA_HOME, else the java on PATH when javac is there too.
find_jdk() {
  local javac
  JDK_HOME='' JDK_FROM=''
  if JDK_HOME=$(studio_jbr); then
    JDK_FROM="Android Studio jbr"
  elif [ -n "${JAVA_HOME:-}" ] && [ -f "$(to_unix "$JAVA_HOME")/bin/javac$KV_EXE" ]; then
    JDK_HOME=$(to_unix "$JAVA_HOME") JDK_FROM=JAVA_HOME
  elif command -v java >/dev/null 2>&1 && javac=$(command -v javac 2>/dev/null); then
    JDK_HOME=$(cd "$(dirname "$javac")/.." && pwd) JDK_FROM=PATH
  else
    JDK_HOME=''
    return 1
  fi
}

# jdk_major <jdk home>: the feature version of that JDK (17, 21, 25...).
jdk_major() {
  local out v
  out=$("$1/bin/javac$KV_EXE" -version 2>&1) || return 1
  v=$(sed -n 's/^javac \([0-9][0-9._]*\).*/\1/p' <<<"$out")
  v=${v%%"$NL"*}
  case $v in 1.*) v=${v#1.} ;; esac
  v=${v%%[._]*}
  [ -n "$v" ] || return 1
  printf '%s\n' "$v"
}
