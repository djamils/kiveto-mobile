# Shared by the plain-bash checks of test/scripts/ (sourced by each
# *_test.sh, run by make test-scripts). bash 3.2, LF only.
#
# - KV_REPO: the repository; KV_T: a temporary folder removed on exit.
# - PATH: without the folders that hold an fvm / fvm.exe executable, with
#   KV_T/bin first for the stubs (KV_REAL_FVM_DIR keeps the real fvm's
#   folder for the few cases that need it: with_real_fvm).
# - stub <name> <bash body>: an executable <name> in KV_T/bin.
# - expect_status / expect_contains / expect_not_contains / expect_eq: one
#   ✓ or ✗ line per case; finish exits 1 when a case failed.

set -u

KV_REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
KV_T=$(mktemp -d "${TMPDIR:-/tmp}/kiveto-test.XXXXXX") || KV_T=''
# Every stub, HOME and rm -rf of a test lives under KV_T: never go on
# without it (an empty KV_T would turn "$KV_T/home" into /home).
if [ -z "$KV_T" ] || [ ! -d "$KV_T" ]; then
  printf '%s: cannot create a temporary folder (mktemp -d under %s)\n' "$(basename "$0")" "${TMPDIR:-/tmp}" >&2
  exit 1
fi
trap 'rm -rf "$KV_T"' EXIT

NL='
'
KV_CASES=0
KV_FAILED=0

KV_REAL_FVM_DIR=''
kv_path=''
kv_ifs=$IFS
IFS=:
for kv_dir in $PATH; do
  if [ -n "$kv_dir" ] && { [ -x "$kv_dir/fvm" ] || [ -x "$kv_dir/fvm.exe" ]; }; then
    if [ -z "$KV_REAL_FVM_DIR" ]; then KV_REAL_FVM_DIR=$kv_dir; fi
  else
    kv_path="${kv_path:+$kv_path:}$kv_dir"
  fi
done
IFS=$kv_ifs
mkdir -p "$KV_T/bin"
PATH="$KV_T/bin:$kv_path"
export PATH
unset kv_path kv_ifs kv_dir

# The scripts under test log their quiet steps here, not in the repository.
LOG_FILE=$KV_T/make.log
NO_COLOR=1
export LOG_FILE NO_COLOR

# stub <name> <body>: writes KV_T/bin/<name>, a bash script running <body>.
stub() {
  printf '#!/usr/bin/env bash\n%s\n' "$2" >"$KV_T/bin/$1"
  chmod +x "$KV_T/bin/$1"
}

# with_real_fvm <command> [args...]: runs the command with the real fvm on
# PATH again (after the stubs).
with_real_fvm() {
  if [ -z "$KV_REAL_FVM_DIR" ]; then
    printf 'fvm not found on PATH: this case needs it (make install)\n' >&2
    return 127
  fi
  PATH="$PATH:$KV_REAL_FVM_DIR" "$@"
}

# kv_case <0|1> <name> [details]: records and prints one case.
kv_case() {
  KV_CASES=$((KV_CASES + 1))
  if [ "$1" = 0 ]; then
    printf '  ✓ %s\n' "$2"
  else
    KV_FAILED=$((KV_FAILED + 1))
    printf '  ✗ %s\n' "$2"
    if [ -n "${3:-}" ]; then printf '%s\n' "$3" | sed 's/^/      /'; fi
  fi
}

# expect_status <expected> <actual> <name> [output shown on failure]
expect_status() {
  if [ "$1" = "$2" ]; then
    kv_case 0 "$3"
  else
    kv_case 1 "$3" "expected exit $1, got $2${4:+$NL$4}"
  fi
}

# expect_contains <text> <needle> <name>
expect_contains() {
  case $1 in
    *"$2"*) kv_case 0 "$3" ;;
    *) kv_case 1 "$3" "expected to contain: $2${NL}in:$NL$1" ;;
  esac
}

# expect_not_contains <text> <needle> <name>
expect_not_contains() {
  case $1 in
    *"$2"*) kv_case 1 "$3" "expected not to contain: $2${NL}in:$NL$1" ;;
    *) kv_case 0 "$3" ;;
  esac
}

# expect_eq <expected> <actual> <name>
expect_eq() {
  if [ "$1" = "$2" ]; then
    kv_case 0 "$3"
  else
    kv_case 1 "$3" "expected: $1${NL}got:      $2"
  fi
}

# finish: the last line of every *_test.sh.
finish() {
  if [ "$KV_FAILED" -gt 0 ]; then
    printf '%s: %s of %s case(s) failed\n' "$(basename "$0")" "$KV_FAILED" "$KV_CASES"
    exit 1
  fi
  printf '%s: %s case(s) passed\n' "$(basename "$0")" "$KV_CASES"
  exit 0
}
