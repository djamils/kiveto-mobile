#!/usr/bin/env bash
# make doctor: read-only check of every prerequisite, one line per check with
# its fix; exits 1 when a blocker fails. FULL=1 adds `fvm flutter doctor -v`.
#
#   bash scripts/doctor.sh           every check (make doctor)
#   bash scripts/doctor.sh --quiet   only the warnings and failures (make install)

. "$(dirname "$0")/lib.sh"

QUIET=0
if [ "${1:-}" = "--quiet" ]; then QUIET=1; fi

BLOCKERS=0
WARNINGS=0

pass() { if [ "$QUIET" = 0 ]; then ok "$1"; fi; }
blocker() {
  fail "$1 - fix: $2"
  BLOCKERS=$((BLOCKERS + 1))
}
warning() {
  warn "$1 - $2"
  WARNINGS=$((WARNINGS + 1))
}

if [ "$QUIET" = 0 ]; then step "Checking prerequisites ($KV_OS)..."; fi

# --- Xcode licence (macOS) --------------------------------------------------
# Until the Xcode licence is accepted, the xcrun shims (/usr/bin/make, git,
# xcrun) exit 69 instead of running, so make doctor itself cannot start:
# name that cause here instead of "not found" below.

xcode_licence_ok=1
if [ "$KV_OS" = macos ] && command -v xcodebuild >/dev/null 2>&1; then
  licence_rc=0
  xcodebuild -license check >/dev/null 2>&1 || licence_rc=$?
  if [ "$licence_rc" = 69 ]; then
    xcode_licence_ok=0
    blocker "Xcode licence not accepted (/usr/bin/make, /usr/bin/git and xcrun refuse to run)" "sudo xcodebuild -license accept, then sudo xcodebuild -runFirstLaunch"
  fi
fi

# --- Shell, make, git -------------------------------------------------------

if version_ge "${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}" 3.2; then
  pass "bash $BASH_VERSION"
else
  blocker "bash $BASH_VERSION is older than 3.2" "install Git for Windows / use the system bash"
fi

make_version=${MAKE_VERSION:-}
if [ -z "$make_version" ] && command -v make >/dev/null 2>&1; then
  make_version=$(make --version 2>/dev/null | sed -n 's/^GNU Make \([0-9.]*\).*/\1/p') || make_version=''
fi
make_fix='winget install ezwinports.make (Windows), /usr/bin/make from the Xcode Command Line Tools (macOS)'
if [ -z "$make_version" ] && [ "$xcode_licence_ok" = 0 ]; then
  warning "GNU Make not checked" "/usr/bin/make waits for the Xcode licence"
elif [ -z "$make_version" ]; then
  blocker "GNU Make not found" "$make_fix"
elif version_ge "$make_version" 3.81; then
  pass "GNU Make $make_version"
else
  blocker "GNU Make $make_version is older than 3.81" "$make_fix"
fi

if git_version=$(git --version 2>/dev/null); then
  pass "$git_version"
elif [ "$xcode_licence_ok" = 0 ]; then
  warning "git not checked" "/usr/bin/git waits for the Xcode licence"
else
  blocker "git not found" "install Git"
fi

repo_path=$KV_ROOT
if [ "$KV_OS" = windows ]; then repo_path=$(pwd -W); fi
case $repo_path in
  //* | \\\\*) warning "Repository on a UNC path ($repo_path)" "clone on a local disk, in a path without spaces" ;;
  *' '*) warning "Repository path has spaces ($repo_path)" "clone on a local disk, in a path without spaces" ;;
  *) pass "Repository path $repo_path" ;;
esac

autocrlf=$(git config --get core.autocrlf 2>/dev/null) || autocrlf=''
case "$(printf '%s' "$autocrlf" | tr '[:upper:]' '[:lower:]')" in
  true | yes | on | 1) autocrlf_true=1 ;;
  *) autocrlf_true=0 ;;
esac
if [ "$autocrlf_true" = 1 ]; then
  warning "core.autocrlf=$autocrlf" "neutralised by .gitattributes, no fix needed"
else
  pass "core.autocrlf=${autocrlf:-unset}"
fi

# --- FVM and Flutter --------------------------------------------------------

fvm_ok=0
if ! fvm_version=$(fvm_version); then
  blocker "FVM not found on PATH" "$(fvm_fix)"
elif ! version_ge "$fvm_version" 4; then
  blocker "FVM $fvm_version is older than 4" "$(fvm_upgrade_fix)"
else
  fvm_ok=1
  pass "FVM $fvm_version ($(command -v fvm))"
fi

flutter_ok=0
if [ "$fvm_ok" = 0 ]; then
  warning "Flutter $FLUTTER_VERSION not checked (no FVM)" "install FVM first, then make install"
elif flutter_cached; then
  flutter_ok=1
  pass "Flutter $FLUTTER_VERSION in the FVM cache"
elif [ "${KV_CALLER:-}" != install ]; then
  warning "Flutter $FLUTTER_VERSION not in the FVM cache yet" "make install (needed by make start)"
fi

# --- Windows ----------------------------------------------------------------

if [ "$KV_OS" = windows ]; then
  dev_mode=$(reg_value 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' AllowDevelopmentWithoutDevLicense) || dev_mode=''
  if [ "$dev_mode" = 0x1 ]; then
    pass "Windows Developer Mode on"
  else
    blocker "Windows Developer Mode off (FVM needs symbolic links)" "Settings › System › Advanced › Developer Mode"
  fi

  long_paths=$(reg_value 'HKLM\SYSTEM\CurrentControlSet\Control\FileSystem' LongPathsEnabled) || long_paths=''
  if [ "$long_paths" = 0x1 ]; then
    pass "Windows long paths enabled"
  else
    warning "Windows long paths disabled" "optional, needs admin (LongPathsEnabled=1 under HKLM\\SYSTEM\\CurrentControlSet\\Control\\FileSystem)"
  fi
fi

# --- Android ----------------------------------------------------------------

if sdk=$(android_sdk); then
  pass "Android SDK $sdk"

  sdkmanager=''
  for candidate in "$sdk"/cmdline-tools/*/bin/sdkmanager$KV_BAT; do
    if [ -f "$candidate" ]; then sdkmanager=$candidate; fi
  done
  if [ -n "$sdkmanager" ]; then
    pass "Android SDK cmdline-tools ($(basename "$(dirname "$(dirname "$sdkmanager")")"))"
  else
    blocker "Android SDK cmdline-tools missing" "SDK Manager › SDK Tools › Command-line Tools"
  fi

  if [ -d "$sdk/platforms/android-36" ]; then
    pass "Android SDK platform android-36"
  else
    warning "Android SDK platform android-36 missing" "SDK Manager › SDK Platforms › Android 16.0 (API 36)"
  fi

  if [ -f "$sdk/licenses/android-sdk-license" ]; then
    pass "Android SDK licence accepted"
  else
    blocker "Android SDK licence not accepted" "accept the licence in Android Studio's SDK Manager"
  fi

  # NDK: the version the app builds with, a literal ndkVersion of the app's
  # Gradle file, else the default of the pinned Flutter. Gradle installs it
  # on demand, except on Windows: cmdline-tools 23's sdkmanager.bat splits
  # ndk;<version> at the ';', so the first build fails without it.
  ndk=$(sed -n 's/^[[:space:]]*ndkVersion[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' android/app/build.gradle.kts 2>/dev/null) || ndk=''
  ndk=${ndk%%"$NL"*}
  if [ -z "$ndk" ] && [ "$flutter_ok" = 1 ] && flutter_dir=$(flutter_sdk_dir); then
    ndk=$(sed -n 's/.*val ndkVersion: String = "\([^"]*\)".*/\1/p' \
      "$flutter_dir/packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt" 2>/dev/null) || ndk=''
    ndk=${ndk%%"$NL"*}
  fi
  ndk_fix="\"$sdk/cmdline-tools/latest/bin/android$KV_EXE\" --no-metrics sdk install ndk/$ndk, or SDK Manager › SDK Tools › NDK (Side by side) with \"Show Package Details\""
  if [ -n "$ndk" ] && [ -f "$sdk/ndk/$ndk/source.properties" ]; then
    pass "NDK $ndk (the version Flutter $FLUTTER_VERSION builds with)"
  elif [ -n "$ndk" ] && [ "$KV_OS" = windows ]; then
    blocker "NDK $ndk missing (the version Flutter $FLUTTER_VERSION builds with; Gradle cannot install it on Windows)" "$ndk_fix"
  elif [ -n "$ndk" ]; then
    warning "NDK $ndk missing (the version Flutter $FLUTTER_VERSION builds with; the first Android build installs it)" "or install it now: $ndk_fix"
  elif [ "$flutter_ok" = 0 ]; then
    if [ "${KV_CALLER:-}" != install ]; then
      warning "NDK not checked until Flutter $FLUTTER_VERSION is installed" "make install"
    fi
  else
    warning "NDK version not found in Flutter $FLUTTER_VERSION (FlutterExtension.kt)" "check the NDK the first Android build asks for"
  fi
else
  blocker "Android SDK not found (ANDROID_HOME=${ANDROID_HOME:-unset})" "install Android Studio, then SDK Manager"
  sdk=''
fi

if find_jdk && jdk=$(jdk_major "$JDK_HOME") && [ "$jdk" -ge 17 ]; then
  pass "JDK $jdk ($JDK_FROM: $JDK_HOME)"
elif [ -n "$JDK_HOME" ]; then
  blocker "JDK ${jdk:-of unknown version} at $JDK_HOME ($JDK_FROM) is not a JDK 17 or later" "install Android Studio"
else
  blocker "No JDK found (Android Studio jbr, JAVA_HOME, javac on PATH)" "install Android Studio"
fi

emulator=$sdk/emulator/emulator$KV_EXE
if [ -z "$sdk" ]; then
  warning "AVDs and emulator acceleration not checked (no Android SDK)" "install Android Studio, then SDK Manager"
elif [ ! -f "$emulator" ]; then
  warning "Android Emulator not installed" "SDK Manager › SDK Tools › Android Emulator"
else
  avds=$("$emulator" -list-avds 2>/dev/null | tr -d '\r' | grep -E '^[A-Za-z0-9._-]+$') || avds=''
  if [ -n "$avds" ]; then
    pass "AVD: $(printf '%s' "$avds" | tr '\n' ' ')"
  else
    warning "No AVD" "Android Studio › Device Manager"
  fi

  if accel=$("$emulator" -accel-check 2>&1); then
    accel=$(tr -d '\r' <<<"$accel" | grep -v -E '^(accel:?|[0-9]+|INFO.*)$' | sed -n '1p') || accel=''
    pass "Emulator acceleration: ${accel:-ok}"
  else
    warning "Emulator acceleration unavailable" "enable Windows Hypervisor Platform / check virtualisation in firmware"
  fi
fi

# --- macOS ------------------------------------------------------------------

if [ "$KV_OS" = macos ]; then
  xcode_dir=$(xcode-select -p 2>/dev/null) || xcode_dir=''
  xcode=$(xcodebuild -version 2>/dev/null | sed -n 's/^Xcode \([0-9][0-9.]*\).*/\1/p') || xcode=''
  xcode_fix='install Xcode from the App Store, then sudo xcode-select -s /Applications/Xcode.app/Contents/Developer'
  if [ -z "$xcode" ] || [ -z "$xcode_dir" ]; then
    blocker "Xcode not found (xcode-select -p: ${xcode_dir:-none})" "$xcode_fix"
  elif ! version_ge "$xcode" 15; then
    blocker "Xcode $xcode is older than 15" "$xcode_fix"
  else
    pass "Xcode $xcode ($xcode_dir)"
    if version_ge "$xcode" 26; then
      pass "Xcode 26 or later (App Store uploads)"
    else
      warning "Xcode $xcode is older than 26" "App Store uploads need Xcode 26"
    fi
  fi

  if [ "$xcode_licence_ok" = 1 ] && [ -n "$xcode" ] && ! xcodebuild -checkFirstLaunchStatus >/dev/null 2>&1; then
    blocker "Xcode first launch not done (system components missing)" "sudo xcodebuild -runFirstLaunch"
  fi

  runtimes=$(xcrun simctl list runtimes 2>/dev/null | grep -E '^iOS ') || runtimes=''
  if [ "$xcode_licence_ok" = 0 ]; then
    warning "iOS simulator runtimes not checked" "xcrun waits for the Xcode licence"
  elif [ -n "$runtimes" ]; then
    pass "iOS simulator runtime: ${runtimes%%"$NL"*}"
  else
    warning "No iOS simulator runtime" "Xcode › Settings › Components"
  fi
fi

# --- BMAD -------------------------------------------------------------------

node=$(node --version 2>/dev/null) || node=''
node=${node#v}
if [ -z "$node" ]; then
  warning "Node not found" "needed by BMAD only (Node 20.12 or later)"
elif version_ge "$node" 20.12; then
  pass "Node $node"
else
  warning "Node $node is older than 20.12" "needed by BMAD only (Node 20.12 or later)"
fi

if uv=$(uv --version 2>/dev/null); then
  pass "$uv"
else
  warning "uv not found" "needed by BMAD only (bmad-build)"
fi

# --- Summary ----------------------------------------------------------------

if [ "$FULL" = 1 ]; then
  if [ "$flutter_ok" = 1 ]; then
    step "fvm flutter doctor -v"
    run_live fvm flutter doctor -v || warning "fvm flutter doctor reported problems" "see its output above"
  else
    warning "FULL=1 skipped" "flutter doctor needs Flutter $FLUTTER_VERSION: make install"
  fi
fi

if [ "$BLOCKERS" -gt 0 ]; then
  fail "$BLOCKERS blocker(s), $WARNINGS warning(s): fix the blockers above, then run make ${KV_CALLER:-doctor} again."
  exit 1
fi
if [ "$QUIET" = 0 ]; then ok "Ready ($WARNINGS warning(s))"; fi
