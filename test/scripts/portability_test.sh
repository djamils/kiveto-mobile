#!/usr/bin/env bash
# The shell files stay bash 3.2 (macOS /bin/bash) and LF only: no bash 4
# construct and no CR in scripts/*.sh, .githooks/*, test/scripts/*.sh and the
# Makefile. The patterns below are written so that they do not match
# themselves (this file is scanned too).

. "$(dirname "$0")/support.sh"

cd "$KV_REPO" || exit 1

files=()
for file in scripts/*.sh .githooks/* test/scripts/*.sh Makefile; do
  if [ -f "$file" ]; then files+=("$file"); fi
done
expect_eq yes "$([ "${#files[@]}" -gt 10 ] && echo yes || echo no)" "the scan covers the shell files (${#files[@]})"

# forbid <name> <extended regex>: one case, listing the offending lines.
forbid() {
  local found
  found=$(grep -nE -e "$2" "${files[@]}" 2>/dev/null) || found=''
  expect_eq '' "$found" "no $1"
}

forbid 'associative arrays' '(declare|local|typeset)[[:space:]]+-[a-zA-Z]*A'
forbid 'case-changing expansion' '\$\{[A-Za-z_][A-Za-z0-9_]*(\[[^]]*\])?[,^]'
forbid 'builtins reading lines into an array' '(^|[^A-Za-z0-9_])(map[f]ile|read[a]rray)([^A-Za-z0-9_]|$)'
forbid 'strftime format of printf' "printf[[:space:]]+['\"]?[^'\"]*%[(]"
forbid 'set-variable test' '\[\[[[:space:]]+-v[[:space:]]'
forbid 'append of stdout and stderr' '&[>]>'
forbid 'pipe of stdout and stderr' '[|]&'
forbid 'case fall-through or test-next' ';;?[&]'
forbid 'coprocess' '(^|[^A-Za-z0-9_])co[p]roc([^A-Za-z0-9_]|$)'
forbid 'name references' '(declare|local|typeset)[[:space:]]+-[a-zA-Z]*n'
forbid 'negative array subscript' '\$\{[A-Za-z_][A-Za-z0-9_]*\[-[0-9]'
forbid 'parameter transformation' '\$\{[A-Za-z_][A-Za-z0-9_]*(\[[^]]*\])?@[A-Za-z]'
forbid 'recursive glob option' 'glo[b]star'
forbid 'epoch variables' 'EPOC[H](SECONDS|REALTIME)'
forbid 'waiting for the next job' '(^|[^A-Za-z0-9_])wai[t][[:space:]]+-[a-zA-Z]*n'
forbid 'single-bracket set-variable test' '(^|[^A-Za-z0-9_])(\[|tes[t])[[:space:]]+-v[[:space:]]'
forbid 'global or case-folding declarations' '(declare|local|typeset)[[:space:]]+-[a-zA-Z]*[glu]'
forbid 'negative substring length' '\$\{[A-Za-z_][A-Za-z0-9_]*:[^}:]*:[[:space:]]*-[0-9]'
forbid 'named file descriptors' '(^|[^$A-Za-z0-9_])\{[A-Za-z_][A-Za-z0-9_]*\}[<>]'
forbid 'subshell pid variable' 'BASHPI[D]'
forbid 'read with a count or an initial text' '(^|[^A-Za-z0-9_])rea[d][[:space:]]+(-[A-Za-z]+[[:space:]]+[^-[:space:]]*[[:space:]]*)*-[a-zA-Z]*[Ni]'
forbid 'brace sequences with a step or zero padding' '\{(-?[0-9]+\.\.-?[0-9]+\.\.|-?0[0-9]+\.\.)'
forbid 'last pipeline stage in the shell' 'lastpip[e]'

cr=$(grep -l "$(printf '\r')" "${files[@]}" 2>/dev/null) || cr=''
expect_eq '' "$cr" 'no CR (LF line endings only)'

broken=''
for file in "${files[@]}"; do
  case $file in
    Makefile) ;;
    *) bash -n "$file" 2>/dev/null || broken="$broken $file" ;;
  esac
done
expect_eq '' "$broken" 'every shell file parses (bash -n)'

finish
