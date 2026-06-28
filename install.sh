#!/bin/sh
# ============================================================================
# AnyCMS SSG — one-line installer for Linux & macOS.
#   curl -fsSL https://anycms.org/install.sh | sh
#
# Downloads the matching prebuilt binary from https://anycms.org/dl/ into
# $ANYCMS_INSTALL_DIR (default ~/.anycms/bin) and prints a PATH hint.
#
# NOTE: macOS has no native build yet — the installer still completes (it
# installs a placeholder `anycms` stub that explains how to build from source
# with Cargo). See the macOS download note on the site.
# ============================================================================
set -eu

VERSION="0.1.0"
BASE_URL="https://anycms.org/dl"
OWNER_REPO="anycms/anycms-ssg"
INSTALL_DIR="${ANYCMS_INSTALL_DIR:-${HOME}/.anycms/bin}"

# Real ESC bytes (POSIX): keeps colours working in heredocs too, not just printf
# format strings.
ESC=$(printf '\033')
RED="${ESC}[31m"; BOLD="${ESC}[1m"; CYAN="${ESC}[36m"; GREEN="${ESC}[32m"; YELLOW="${ESC}[33m"; RESET="${ESC}[0m"
step()  { printf "${CYAN}==>${RESET} %s\n" "$*"; }
warn()  { printf "${YELLOW}%s${RESET}\n" "$*"; }
err()   { printf "${RED}Error:${RESET} %s\n" "$*" >&2; }

# --- detect platform --------------------------------------------------------
uname_s=$(uname -s 2>/dev/null || echo unknown)
uname_m=$(uname -m 2>/dev/null || echo unknown)

case "$uname_s" in
  Linux*)  os=linux ;;
  Darwin*) os=darwin ;;
  *) err "Unsupported OS: $uname_s (use Cargo: cargo install --git https://github.com/$OWNER_REPO anycms-ssg-cli)"; exit 1 ;;
esac
case "$uname_m" in
  x86_64|amd64)  arch=x86_64 ;;
  aarch64|arm64) arch=aarch64 ;;
  *) err "Unsupported architecture: $uname_m"; exit 1 ;;
esac

# Map to the published triple. macOS ships a universal placeholder.
if [ "$os" = "linux" ]; then
  triple="$arch-unknown-linux-musl"
else
  triple="universal-apple-darwin"
fi
archive="anycms-$VERSION-$triple.tar.gz"
url="$BASE_URL/$archive"
staged="anycms-$VERSION-$triple"

if [ "$os" = "darwin" ]; then
  warn "Note: native macOS build is not released for v$VERSION — installing a placeholder stub."
fi

# --- download ---------------------------------------------------------------
tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t anycms)
trap 'rm -rf "$tmpdir"' EXIT

step "Installing AnyCMS v$VERSION ($triple)"
printf "    %s\n" "$url"

if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$url" -o "$tmpdir/$archive"
elif command -v wget >/dev/null 2>&1; then
  wget -qO "$tmpdir/$archive" "$url"
else
  err "Need curl or wget to download."; exit 1
fi

# --- extract + install ------------------------------------------------------
tar -xzf "$tmpdir/$archive" -C "$tmpdir"
if [ ! -f "$tmpdir/$staged/anycms" ]; then
  err "Archive did not contain $staged/anycms."; exit 1
fi

mkdir -p "$INSTALL_DIR"
mv "$tmpdir/$staged/anycms" "$INSTALL_DIR/anycms"
chmod +x "$INSTALL_DIR/anycms"

printf "\n"
step "Installed to $INSTALL_DIR/anycms"

# --- PATH hint --------------------------------------------------------------
in_path=0
case ":$PATH:" in
  *":$INSTALL_DIR:"*) in_path=1 ;;
esac
if [ "$in_path" -eq 0 ]; then
  cat <<EOF

Add AnyCMS to your PATH (add this to your shell profile to make it permanent):

    ${BOLD}export PATH="$INSTALL_DIR:\$PATH"${RESET}

EOF
fi

# Best-effort version check (stub on macOS exits non-zero here).
"$INSTALL_DIR/anycms" --version 2>/dev/null || true

printf "${GREEN}%s${RESET}\n" "Done. Next: anycms init my-site"
