#!/usr/bin/env bash
set -euo pipefail

# Install Quarto (idempotent; also re-checked on every attach via postAttachCommand).
bash "$(dirname "$0")/install-quarto.sh"

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
(
  temp_dir="$(mktemp -d)"
  trap 'rm -rf "$temp_dir"' EXIT
  TMPDIR="$temp_dir" \
    PATH="/opt/quarto/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    quarto install tinytex --no-prompt
)

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
npx --yes skills@1.7.4 add mattpocock/skills/skills/engineering -g \
  -a codex -a antigravity -a antigravity-cli -a claude-code --yes
npx --yes skills@1.7.4 add vercel-labs/skills@find-skills -g \
  -a codex -a antigravity -a antigravity-cli -a claude-code --yes

# Link shared skills into Gemini's config, replacing any stale links.
echo "Linking shared skills into ~/.gemini/config/skills..."
mkdir -p ~/.gemini/config/skills
ln -sfn ~/.agents/skills/* ~/.gemini/config/skills/

echo "Research writing environment is ready."
