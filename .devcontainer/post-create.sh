#!/usr/bin/env bash
set -euo pipefail

QUARTO_VERSION="1.10.19"
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

# Install analysis libraries for the image's /usr/local Python, not Debian's Python.
python -m pip install --user --disable-pip-version-check --no-cache-dir \
  --requirement .devcontainer/requirements.txt

# Add user-local Python commands to this process and future shells.
export PATH="$HOME/.local/bin:$PATH"
for rc in "$HOME/.bashrc" "$HOME/.profile"; do
  touch "$rc"
  grep -qF '.local/bin' "$rc" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
done

# Install TinyTeX in the persisted user home for PDF rendering.
quarto install tinytex --no-prompt

# Expose TinyTeX to terminals and LaTeX Workshop on either supported architecture.
TEX_MANAGERS=("$HOME"/.TinyTeX/bin/*/tlmgr)
if [ "${#TEX_MANAGERS[@]}" -ne 1 ] || [ ! -x "${TEX_MANAGERS[0]}" ]; then
  echo "Expected one TinyTeX installation under $HOME/.TinyTeX/bin"
  exit 1
fi
TEX_BIN="$(dirname "${TEX_MANAGERS[0]}")"
mkdir -p "$HOME/.local"
ln -sfn "$TEX_BIN" "$HOME/.local/tinytex-bin"
export PATH="$HOME/.local/tinytex-bin:$PATH"
for rc in "$HOME/.bashrc" "$HOME/.profile"; do
  grep -qF '.local/tinytex-bin' "$rc" || echo 'export PATH="$HOME/.local/tinytex-bin:$PATH"' >> "$rc"
done
# Update TeX Live infrastructure before installing packages from the repository.
tlmgr update --self
tlmgr install latexmk
latexmk -v

# Install shared skills for the selected agent tools.
npx --yes skills@1.7.0 add mattpocock/skills/skills/engineering -g \
  -a codex -a antigravity -a antigravity-cli -a claude-code --yes
npx --yes skills@1.7.0 add vercel-labs/skills@find-skills -g \
  -a codex -a antigravity -a antigravity-cli -a claude-code --yes
echo "Research writing environment is ready."
