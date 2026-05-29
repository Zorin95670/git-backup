#!/usr/bin/env bash

set -euo pipefail

REPO="Zorin95670/git-backup"
BINARY_NAME="git-backup"
INSTALL_PATH="/usr/local/bin/git-backup"

echo "[INFO] Installing git-backup..."

########################################
# Detect OS / ARCH
########################################

OS="$(uname -s)"
ARCH="$(uname -m)"

if [[ "$OS" != "Linux" ]]; then
    echo "[ERROR] This installer only supports Linux."
    exit 1
fi

case "$ARCH" in
    x86_64)
        PLATFORM="linux-amd64"
        ;;
    aarch64 | arm64)
        PLATFORM="linux-arm64"
        ;;
    armv7l | armv7)
        PLATFORM="linux-armv7"
        ;;
    *)
        echo "[ERROR] Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

########################################
# Dependency installer
########################################

install_dependencies() {
    echo "[INFO] Installing dependencies..."

    if command -v apt-get >/dev/null 2>&1; then
        apt-get update -q
        apt-get install -y git zstd

    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y git zstd

    elif command -v pacman >/dev/null 2>&1; then
        pacman -Sy --noconfirm git zstd

    else
        echo "[WARN] No supported package manager found."
        echo "Please install manually: git zstd"
        return 0
    fi

    echo "[INFO] Dependencies installed (git, zstd)"
}

########################################
# Download
########################################

URL="https://github.com/${REPO}/releases/latest/download/${BINARY_NAME}-${PLATFORM}"

echo "[INFO] Detected platform: $PLATFORM"
echo "[INFO] Downloading: $URL"

TMP_FILE="$(mktemp)"
trap 'rm -f "$TMP_FILE"' EXIT

curl -fsSL "$URL" -o "$TMP_FILE"

########################################
# Install binary
########################################

install -m 755 "$TMP_FILE" "$INSTALL_PATH"

echo "[INFO] Installed to $INSTALL_PATH"

########################################
# Install dependencies
########################################

install_dependencies

########################################
# Verify
########################################

if command -v git-backup >/dev/null 2>&1; then
    echo "[OK] Installation successful"
    git-backup 2>/dev/null || true
else
    echo "[ERROR] Installation failed"
    exit 1
fi
