#!/usr/bin/env bash
# scripts/install-fvm.sh on a simulated Apple Silicon Mac (stubbed uname,
# curl and sha256sum, HOME and TMPDIR in a temporary folder): a wrong digest
# installs nothing, an archive with an unsafe path writes nothing, the
# pinned digest with the expected layout installs FVM for the user.

. "$(dirname "$0")/support.sh"

cd "$KV_REPO" || exit 1

PINNED=$(sed -n '/macos-arm64\.tar\.gz/{n;s/.*sha256=\([0-9a-f]*\).*/\1/p;}' scripts/install-fvm.sh)
expect_eq 64 "${#PINNED}" 'the macOS arm64 digest is read from install-fvm.sh'

stub uname 'case "${1:-}" in -m) echo arm64 ;; *) echo Darwin ;; esac'
# curl -o <path> <url>: copies the prepared archive to <path>.
stub curl "out=''
while [ \$# -gt 0 ]; do
  if [ \"\$1\" = -o ]; then out=\$2; shift; fi
  shift
done
cp '$KV_T/archive.tar.gz' \"\$out\""

# Archives: fvm/fvm prints 4.3.2; the unsafe one also holds ../evil.
pack=$KV_T/pack
mkdir -p "$pack/src/fvm"
printf '#!/usr/bin/env bash\necho 4.3.2\n' >"$pack/src/fvm/fvm"
chmod +x "$pack/src/fvm/fvm"
printf 'evil\n' >"$pack/evil"
tar -czf "$pack/good.tar.gz" -C "$pack/src" fvm
tar -czPf "$pack/unsafe.tar.gz" -C "$pack/src" fvm ../evil
expect_contains "$(tar -tzf "$pack/unsafe.tar.gz" 2>/dev/null)" '../evil' 'the unsafe archive holds ../evil'

# install <archive> <digest printed by sha256sum>: runs make install-fvm's
# script with a fresh HOME and TMPDIR; sets RC and OUT.
install() {
  rm -rf "$KV_T/home" "$KV_T/tmp"
  mkdir -p "$KV_T/home" "$KV_T/tmp"
  cp "$pack/$1" "$KV_T/archive.tar.gz"
  stub sha256sum "printf '%s  %s\n' '$2' \"\$1\""
  RC=0
  OUT=$(HOME=$KV_T/home TMPDIR=$KV_T/tmp bash scripts/install-fvm.sh 2>&1) || RC=$?
}

# leftovers: what exists under HOME and in TMPDIR, next to it.
leftovers() {
  (cd "$KV_T" && find home tmp -mindepth 1 | sort)
}

install good.tar.gz 0000000000000000000000000000000000000000000000000000000000000000
expect_status 1 "$RC" 'wrong digest: exit 1' "$OUT"
expect_contains "$OUT" 'SHA-256 mismatch for fvm-4.3.2-macos-arm64.tar.gz' 'wrong digest: says so'
expect_contains "$OUT" 'Nothing installed.' 'wrong digest: says nothing is installed'
expect_eq '' "$(leftovers)" 'wrong digest: nothing under HOME or TMPDIR'

install unsafe.tar.gz "$PINNED"
expect_status 1 "$RC" 'unsafe path: exit 1' "$OUT"
expect_contains "$OUT" 'contains unsafe paths. Nothing installed.' 'unsafe path: refused'
expect_eq '' "$(leftovers)" 'unsafe path: nothing under HOME or TMPDIR'
expect_eq '' "$(cd "$KV_T" && find . -name evil ! -path './pack/*')" 'unsafe path: no evil file written anywhere'

install good.tar.gz "$PINNED"
expect_status 0 "$RC" 'pinned digest, good layout: exit 0' "$OUT"
expect_contains "$OUT" 'FVM 4.3.2 installed in' 'pinned digest: installed'
expect_contains "$OUT" 'export PATH=' 'pinned digest: prints the PATH line instead of editing it'
expect_eq 4.3.2 "$("$KV_T/home/fvm/bin/fvm" --version)" 'pinned digest: fvm --version prints 4.3.2'
expect_eq "home/fvm${NL}home/fvm/bin${NL}home/fvm/bin/fvm" "$(leftovers)" 'pinned digest: only ~/fvm/bin/fvm written'

finish
