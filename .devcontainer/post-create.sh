#!/usr/bin/env bash
set -euo pipefail

# Install pandoc (Quarto uses it for document conversion).
sudo apt-get update
sudo apt-get install -y --no-install-recommends pandoc
sudo rm -rf /var/lib/apt/lists/*

# Install the Quarto CLI (official installer; non-root installs to ~/.local/bin).
curl -fsSL https://quarto.org/setup/install.sh | bash

# Install Node.js (provides node, npm, and npx) via the nvm baked into the image.
# The container PATH points at $NVM_DIR/current/bin, so the "current" symlink must be
# (re)created on every container creation — otherwise npx breaks again after a rebuild.
export NVM_DIR="${NVM_DIR:-/usr/local/share/nvm}"
export NVM_SYMLINK_CURRENT=true
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  # nvm is not present in this image — install it first.
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi
# shellcheck disable=SC1091
. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm alias default lts/*

# Make user-local tools (quarto, pip scripts) available in future shells.
for rc in "$HOME/.bashrc" "$HOME/.profile"; do
  touch "$rc"
  grep -qF '.local/bin' "$rc" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
done

# Install the Python analysis stack (user-local, persisted in the home volume).
python -m pip install --user --no-cache-dir numpy pandas matplotlib scipy

echo
echo "Research writing environment is ready."
echo "Verify with: quarto --version && python --version"
