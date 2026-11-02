#!/usr/bin/env bash
# make install-fvm: opt-in install of FVM for the current user only, from
# the official GitHub release, checked against the SHA-256 digests pinned
# below (published by GitHub for the release assets). Prints the PATH line
# to add instead of writing it. Does nothing when FVM is already on PATH.

. "$(dirname "$0")/lib.sh"

FVM_VERSION=4.3.2
FVM_RELEASES=https://github.com/btwld/fvm/releases/download

if command -v fvm >/dev/null 2>&1; then
  ok "FVM $(fvm_version || echo '(unknown version)') is already on PATH ($(command -v fvm)): nothing to do"
  exit 0
fi

case $KV_OS in
  windows)
    asset=fvm-$FVM_VERSION-windows-x64.zip
    sha256=97696d118ad35bf25dc91fd28c70bb3d77b6d1fee6658fbd744e838b5f81da4a
    dest="$(to_unix "${LOCALAPPDATA:-$HOME/AppData/Local}")/Programs/fvm"
    bin=fvm.exe
    ;;
  macos)
    case "$(uname -m)" in
      arm64)
        asset=fvm-$FVM_VERSION-macos-arm64.tar.gz
        sha256=c9b1e67e5ff4ddae4710669ff9aa312f750947f68fac5b15fc5d248fb4419342
        ;;
      x86_64)
        asset=fvm-$FVM_VERSION-macos-x64.tar.gz
        sha256=66a4e7c8907ba6141eea13168af54be01f07258162ee1d0ed82299b37302e7d2
        ;;
      *) die "No FVM $FVM_VERSION release for macOS $(uname -m)." ;;
    esac
    dest=$HOME/fvm/bin
    bin=fvm
    ;;
esac

print_path_line() {
  step "Add FVM to your PATH (not done for you), then open a new terminal:"
  case $KV_OS in
    windows)
      info "Git Bash, in ~/.bashrc:  export PATH=\"$dest:\$PATH\""
      info "Windows user PATH:       $(cygpath -w "$dest")"
      ;;
    macos)
      info "In ~/.zshrc:  export PATH=\"$dest:\$PATH\""
      ;;
  esac
}

if [ -f "$dest/$bin" ]; then
  ok "FVM is already installed in $dest, but not on PATH"
  print_path_line
  exit 0
fi

sha256_of() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{ print $1 }'
  else
    shasum -a 256 "$1" | awk '{ print $1 }'
  fi
}

work=$(mktemp -d "${TMPDIR:-/tmp}/kiveto-fvm.XXXXXX")
trap 'rm -rf "$work"' EXIT
archive=$work/$asset

step "Downloading $asset (official FVM release)..."
run curl -fsSL --proto '=https' --tlsv1.2 -o "$archive" "$FVM_RELEASES/$FVM_VERSION/$asset"
actual=$(sha256_of "$archive")
if [ "$actual" != "$sha256" ]; then
  die "SHA-256 mismatch for $asset: expected $sha256, got $actual. Nothing installed."
fi
ok "SHA-256 verified ($sha256)"

step "Extracting into $dest..."
case $asset in
  *.zip) entries=$(unzip -Z1 "$archive") ;;
  *) entries=$(tar -tzf "$archive") ;;
esac
if grep -E '^/|^\.\.$|^\.\./|/\.\.$|/\.\./' <<<"$entries" >/dev/null; then
  die "$asset contains unsafe paths. Nothing installed."
fi
mkdir -p "$work/x"
case $asset in
  *.zip) run unzip -q "$archive" -d "$work/x" ;;
  *) run tar -xzf "$archive" -C "$work/x" ;;
esac
if [ ! -f "$work/x/fvm/$bin" ]; then
  die "Unexpected layout in $asset (no fvm/$bin). Nothing installed."
fi
mkdir -p "$dest"
cp -R "$work/x/fvm/." "$dest/"
chmod +x "$dest/$bin"

installed=$("$dest/$bin" --version 2>/dev/null | tr -d '\r') || installed=''
if [ "$installed" != "$FVM_VERSION" ]; then
  die "$dest/$bin reports version '${installed:-none}', expected $FVM_VERSION."
fi
ok "FVM $FVM_VERSION installed in $dest (current user only)"
print_path_line
