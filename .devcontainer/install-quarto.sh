#!/usr/bin/env bash
# Idempotent Quarto installer.
# Safe to run on every container attach: it exits immediately when the pinned
# version is already present, and only downloads/installs when Quarto is
# missing or a different version. This guarantees the Quarto extension can
# always find the binary, regardless of how the container was created.
set -euo pipefail

QUARTO_VERSION="1.10.19"
QUARTO_BIN="/opt/quarto/bin/quarto"

# Already at the pinned version? Nothing to do.
if [ -x "$QUARTO_BIN" ]; then
  INSTALLED=$("$QUARTO_BIN" --version 2>/dev/null | tr -d '[:space:]' || true)
  if [ "$INSTALLED" = "$QUARTO_VERSION" ]; then
    echo "Quarto ${QUARTO_VERSION} already installed."
    exit 0
  fi
  echo "Quarto ${INSTALLED:-unknown} found, upgrading to ${QUARTO_VERSION}..."
fi

ARCH=$(dpkg --print-architecture)
if [ "$ARCH" = "arm64" ]; then
    QUARTO_FILE="quarto-${QUARTO_VERSION}-linux-arm64.deb"
    QUARTO_SHA256="35bb613052da98bef92ec3b7de77c3405a8e546363c7d2aa3abe15a39efa5045"
elif [ "$ARCH" = "amd64" ]; then
    QUARTO_FILE="quarto-${QUARTO_VERSION}-linux-amd64.deb"
    QUARTO_SHA256="7f0c4769e7f0e55f50d922f44b18db5118fb388d2b8fd27291fe1f8beafb43eb"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

QUARTO_URL="https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/${QUARTO_FILE}"
QUARTO_DEB="/tmp/${QUARTO_FILE}"
trap 'rm -f "$QUARTO_DEB"' EXIT

echo "Downloading ${QUARTO_FILE}..."
curl --fail --location --retry 3 --output "$QUARTO_DEB" "$QUARTO_URL"
echo "${QUARTO_SHA256}  ${QUARTO_DEB}" | sha256sum --check

sudo apt-get update
sudo apt-get install -y --no-install-recommends "$QUARTO_DEB" perl
sudo rm -rf /var/lib/apt/lists/*

echo "Quarto installed: $("$QUARTO_BIN" --version)"