#!/usr/bin/env bash
# .githooks/commit-msg on accepted and refused subjects (every subject of
# this repository's history included), and .githooks/pre-commit in a
# temporary git repository: it checks the staged content, not the working
# copy.

. "$(dirname "$0")/support.sh"

# --- commit-msg -----------------------------------------------------------------

msg=$KV_T/COMMIT_EDITMSG

# commit_msg <message>: RC and OUT of the hook on that message file.
commit_msg() {
  printf '%s' "$1" >"$msg"
  RC=0
  OUT=$(bash "$KV_REPO/.githooks/commit-msg" "$msg" 2>&1) || RC=$?
}

for subject in \
  'feat(patient): x' \
  'fix!: x' \
  'chore(identity_access): x' \
  'refactor(core,shared): split the clock' \
  "Merge branch 'a/b'" \
  "Merge branches 'a/b' and 'c/d'" \
  "Merge remote-tracking branches 'origin/a' and 'origin/b'" \
  "Merge tags 'v1.0.0' and 'v1.1.0'" \
  'Revert "feat(patient): x"' \
  'Reapply "Revert "feat(patient): x""' \
  'fixup! feat(patient): x'; do
  commit_msg "$subject$NL"
  expect_status 0 "$RC" "commit-msg accepts: $subject" "$OUT"
done

commit_msg "# Please enter the commit message.$NL$NL  ${NL}docs: explain the gate$NL${NL}Body.$NL"
expect_status 0 "$RC" 'commit-msg skips leading comments and blank lines' "$OUT"

commit_msg "$(printf 'feat(patient): x\r\n')"
expect_status 0 "$RC" 'commit-msg accepts a CRLF message' "$OUT"

# The subjects of this repository's history when the hook was written
# (`git log --format=%s` of phase 3), frozen on purpose: the live history
# would turn make ci red on every branch the day a subject the hook refuses
# reaches master (a GitHub web edit, a squash title), and CI's shallow
# checkout holds a single commit anyway.
history_refused=''
while IFS= read -r subject; do
  commit_msg "$subject$NL"
  if [ "$RC" != 0 ]; then history_refused="$history_refused$subject$NL"; fi
done <<'EOF'
docs: record decision D15 and the phase 3 quality gates
chore(tooling): add the phase 3 quality gates and make ci
Merge branch 'fix/macos-v1'
fix(tooling): validate phase 2 on macOS
Merge branch 'chore/toolchain-bootstrap'
Merge branch 'chore/repo-foundations'
chore: bootstrap the Flutter toolchain (phase 2)
chore: add repository foundations, BMAD 6.12.4 and architecture decisions
chore: initialize repository
EOF
expect_eq '' "$history_refused" 'commit-msg accepts every subject of the history (phase 3)'

for subject in 'update stuff' 'feat: ' 'Feat: x' 'feat(Patient): x' 'feat:x'; do
  commit_msg "$subject$NL"
  expect_status 1 "$RC" "commit-msg refuses: '$subject'" "$OUT"
done
commit_msg ''
expect_status 1 "$RC" 'commit-msg refuses an empty message' "$OUT"

commit_msg "update stuff$NL"
expect_contains "$OUT" '<type>(<scope>): <short imperative summary>' 'the refusal shows the format'
expect_contains "$OUT" 'feat, fix, test, refactor, chore, docs, style, perf, build, ci, revert' 'the refusal lists the types'
expect_contains "$OUT" 'example:  feat(patient):' 'the refusal gives an example'
expect_contains "$OUT" 'CONTRIBUTING.md §3' 'the refusal points to CONTRIBUTING.md'

# --- pre-commit -----------------------------------------------------------------

repo=$KV_T/repo
mkdir -p "$repo/.dart_tool" "$repo/lib" "$repo/packages/api/lib"
cp "$KV_REPO/.fvmrc" "$KV_REPO/analysis_options.yaml" "$repo/"
cp "$KV_REPO/.dart_tool/package_config.json" "$repo/.dart_tool/"
git -C "$repo" init -q
git -C "$repo" config core.autocrlf false

# pre_commit [with_real_fvm]: RC and OUT of the hook in the temporary repo.
pre_commit() {
  RC=0
  OUT=$(cd "$repo" && "$@" bash "$KV_REPO/.githooks/pre-commit" 2>&1) || RC=$?
}

UNFORMATTED='void main( ) {print(1);}'
FORMATTED="void main() {${NL}  print(1);${NL}}"

printf '%s\n' "$UNFORMATTED" >"$repo/packages/api/lib/api.dart"
printf 'notes\n' >"$repo/notes.txt"
git -C "$repo" add packages notes.txt
pre_commit env
expect_status 0 "$RC" 'pre-commit: no staged Dart file outside packages/ -> exit 0, no fvm needed' "$OUT"

printf '%s\n' "$UNFORMATTED" >"$repo/lib/a.dart"
git -C "$repo" add lib/a.dart
pre_commit env
expect_status 1 "$RC" 'pre-commit: refuses without fvm' "$OUT"
expect_contains "$OUT" 'fix: make install' 'pre-commit: without fvm, points to make install'

pre_commit with_real_fvm
expect_status 1 "$RC" 'pre-commit: staged unformatted file -> exit 1' "$OUT"
expect_contains "$OUT" "  lib/a.dart$NL" 'pre-commit: names the unformatted file'
expect_contains "$OUT" 'make format, then git add' 'pre-commit: suggests make format'
expect_not_contains "$OUT" 'packages/' 'pre-commit: leaves packages/ out'

printf '%s\n' "$FORMATTED" >"$repo/lib/a.dart"
pre_commit with_real_fvm
expect_status 1 "$RC" 'pre-commit: staged unformatted, working copy formatted -> exit 1' "$OUT"
expect_contains "$OUT" "  lib/a.dart$NL" 'pre-commit: checks the staged content'

git -C "$repo" add lib/a.dart
pre_commit with_real_fvm
expect_status 0 "$RC" 'pre-commit: staged formatted file -> exit 0' "$OUT"

printf '%s\n' "$UNFORMATTED" >"$repo/lib/c.dart"
printf 'void broken( {\n' >"$repo/lib/d.dart"
git -C "$repo" add lib/c.dart lib/d.dart
pre_commit with_real_fvm
expect_status 1 "$RC" 'pre-commit: one unformatted and one unparsable file -> exit 1' "$OUT"
expect_contains "$OUT" 'could not be parsed' 'pre-commit: shows the parse error'
expect_contains "$OUT" "  lib/c.dart$NL" 'pre-commit: still names the unformatted file'
git -C "$repo" rm -q --cached lib/c.dart lib/d.dart

mv "$repo/.dart_tool/package_config.json" "$KV_T/package_config.json"
pre_commit with_real_fvm
expect_status 1 "$RC" 'pre-commit: refuses without package config' "$OUT"
expect_contains "$OUT" 'no .dart_tool/package_config.json' 'pre-commit: names the missing package config'

finish
