#!/usr/bin/env bash
# scripts/doctor.sh and scripts/install.sh with a stubbed fvm and a fake
# Android SDK: a blocker stops make install before `fvm install`; the NDK
# check names the version Flutter asks for and both fixes.

. "$(dirname "$0")/support.sh"

cd "$KV_REPO" || exit 1

FLUTTER=$(sed -n 's/.*"flutter"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' .fvmrc)
NDK=28.2.13676358
case "$(uname -s)" in
  MINGW* | MSYS* | CLANG* | UCRT64*) WINDOWS=1 ;;
  *) WINDOWS=0 ;;
esac

# --- Doctor blocker -------------------------------------------------------------

# fvm 3.0.0: answers --version, logs every call, fails on anything else.
stub fvm "printf '%s\n' \"\$*\" >>'$KV_T/fvm.log'
if [ \"\${1:-}\" = --version ]; then echo 3.0.0; exit 0; fi
exit 1"
mkdir -p "$KV_T/empty-sdk"
export ANDROID_HOME=$KV_T/empty-sdk

rc=0
out=$(bash scripts/install.sh 2>&1) || rc=$?
expect_eq 1 "$rc" 'install: exits 1 on a doctor blocker'
expect_contains "$out" 'FVM 3.0.0 is older than 4 - fix:' 'install: prints the FVM blocker and its fix'
expect_not_contains "$(cat "$KV_T/fvm.log")" 'install' 'install: never calls fvm install'
expect_not_contains "$out" 'Installing Flutter' 'install: stops before the Flutter step'

rc=0
out=$(bash scripts/doctor.sh 2>&1) || rc=$?
expect_eq 1 "$rc" 'doctor: exits 1 on a blocker'
expect_contains "$out" '✗ FVM 3.0.0 is older than 4' 'doctor: reports the FVM blocker'
expect_contains "$out" 'blocker(s)' 'doctor: summarises the blockers'

# --- NDK ------------------------------------------------------------------------

# fvm 4.3.2 whose cache holds the pinned Flutter in a fake SDK folder.
sdk_dir=$KV_T/flutter
mkdir -p "$sdk_dir/packages/flutter_tools/gradle/src/main/kotlin"
printf '    val ndkVersion: String = "%s"\n' "$NDK" \
  >"$sdk_dir/packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt"
if [ "$WINDOWS" = 1 ]; then
  directory=$(cygpath -w "$sdk_dir" | sed 's/\\/\\\\/g')
else
  directory=$sdk_dir
fi
printf '{"versions":[{"name":"%s","type":"release","directory":"%s","isSetup":%s}]}\n' \
  "$FLUTTER" "$directory" true >"$KV_T/api-setup.json"
printf '{"versions":[{"name":"%s","type":"release","directory":"%s","isSetup":%s}]}\n' \
  "$FLUTTER" "$directory" false >"$KV_T/api-missing.json"
cp "$KV_T/api-setup.json" "$KV_T/api.json"
stub fvm "case \"\${1:-}\" in
  --version) echo 4.3.2 ;;
  api) cat '$KV_T/api.json' ;;
  *) exit 1 ;;
esac"

android=$KV_T/android-sdk
mkdir -p "$android/ndk"
export ANDROID_HOME=$android

rc=0
out=$(bash scripts/doctor.sh 2>&1) || rc=$?
expect_contains "$out" "NDK $NDK missing" 'NDK: names the version Flutter asks for'
expect_contains "$out" "--no-metrics sdk install ndk/$NDK" 'NDK: prints the Android CLI fix'
expect_contains "$out" 'NDK (Side by side) with "Show Package Details"' 'NDK: prints the SDK Manager fix'
if [ "$WINDOWS" = 1 ]; then
  expect_contains "$out" "✗ NDK $NDK missing" 'NDK: missing is a blocker on Windows'
  expect_eq 1 "$rc" 'NDK: doctor exits 1 on Windows'
else
  expect_contains "$out" "! NDK $NDK missing" 'NDK: missing is a warning outside Windows'
fi

mkdir -p "$android/ndk/$NDK"
printf 'Pkg.Revision = %s\n' "$NDK" >"$android/ndk/$NDK/source.properties"
out=$(bash scripts/doctor.sh 2>&1)
expect_contains "$out" "✓ NDK $NDK" 'NDK: present once ndk/<version>/source.properties exists'
expect_not_contains "$out" 'NDK 28.2.13676358 missing' 'NDK: no longer reported missing'

cp "$KV_T/api-missing.json" "$KV_T/api.json"
out=$(bash scripts/doctor.sh 2>&1)
expect_contains "$out" "! NDK not checked until Flutter $FLUTTER is installed" 'NDK: not checked before Flutter is installed'

finish
