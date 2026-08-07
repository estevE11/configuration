#!/usr/bin/env bash
# New Mac bootstrap: brew plumbing + nvm/uv/rustup + DMG downloads + dotfiles.
# GUI apps are downloaded for click-through install (not brew casks).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
NVM_VERSION="${NVM_VERSION:-v0.40.6}"

log() { printf '\n==> %s\n' "$*"; }

# --- Xcode CLT --------------------------------------------------------------
log "Xcode Command Line Tools"
if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install || true
  echo "Finish the CLT GUI installer, then re-run: ${ROOT}/setup-mac.sh"
  exit 0
fi

# --- Homebrew (plumbing only) -----------------------------------------------
log "Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  eval "$(brew shellenv)"
fi

log "Brewfile (formulae)"
brew bundle --file="${ROOT}/mac/Brewfile"

# --- nvm + Node -------------------------------------------------------------
log "nvm ${NVM_VERSION}"
export NVM_DIR="${HOME}/.nvm"
if [[ ! -s "${NVM_DIR}/nvm.sh" ]]; then
  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
fi
# shellcheck disable=SC1091
[[ -s "${NVM_DIR}/nvm.sh" ]] && . "${NVM_DIR}/nvm.sh"
nvm install --lts
nvm alias default 'lts/*'

# --- uv (Python) ------------------------------------------------------------
log "uv"
if ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi
export PATH="${HOME}/.local/bin:${PATH}"

# --- rustup -----------------------------------------------------------------
log "rustup"
if ! command -v rustup >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
# shellcheck disable=SC1091
[[ -s "${HOME}/.cargo/env" ]] && . "${HOME}/.cargo/env"

# --- Go (official pkg — open download; you click) ---------------------------
log "Go (official pkg)"
GO_PKG="${HOME}/Downloads/mac-setup-apps/go.pkg"
mkdir -p "$(dirname "${GO_PKG}")"
if [[ ! -f "${GO_PKG}" ]]; then
  # Stable evergreen redirect from go.dev
  if curl -fsIL -o /dev/null "https://go.dev/dl/?download=true"; then
    echo "Open https://go.dev/dl/ and download the macOS ARM64 .pkg (saved suggestion folder: $(dirname "${GO_PKG}"))"
    open "https://go.dev/dl/" 2>/dev/null || true
  fi
else
  echo "Found ${GO_PKG} — open it to install"
  open "${GO_PKG}" 2>/dev/null || true
fi

# --- Product CLIs (official / npx — not brew) -------------------------------
log "Product CLIs"
if ! command -v claude >/dev/null 2>&1; then
  echo "Installing Claude Code (official)…"
  curl -fsSL https://claude.ai/install.sh | bash || {
    echo "Claude install script failed — see https://docs.anthropic.com/en/docs/claude-code"
  }
fi

echo "Codex (after nvm): npx @openai/codex   or: npm i -g @openai/codex"
echo "T3 Code: install from the official download (listed in mac/apps.tsv)"
echo "Cursor CLI: installs with the Cursor app, or from Cursor settings"

# --- Dotfiles ---------------------------------------------------------------
log "Dotfiles"
link_dot() {
  local src="$1" dest="$2"
  if [[ -e "${dest}" && ! -L "${dest}" ]]; then
    cp -a "${dest}" "${dest}.bak.$(date +%Y%m%d%H%M%S)"
  fi
  ln -sfn "${src}" "${dest}"
  echo "linked ${dest} → ${src}"
}

link_dot "${ROOT}/.tmux.conf" "${HOME}/.tmux.conf"
link_dot "${ROOT}/.vimrc" "${HOME}/.vimrc"
link_dot "${ROOT}/mac/dotfiles/bash_profile" "${HOME}/.bash_profile"
link_dot "${ROOT}/mac/dotfiles/bashrc" "${HOME}/.bashrc"

if [[ ! -d "${HOME}/.vim/bundle/Vundle.vim" ]]; then
  git clone https://github.com/VundleVim/Vundle.vim.git "${HOME}/.vim/bundle/Vundle.vim"
fi
vim +PluginInstall +qall || true

# --- GUI app downloads ------------------------------------------------------
log "Download GUI installers (you click through)"
bash "${ROOT}/mac/download-apps.sh"

# --- Checklist --------------------------------------------------------------
log "Manual checklist"
cat <<'EOF'
[ ] Open ~/Downloads/mac-setup-apps and install each DMG/PKG/ZIP (incl. ClaudeBar)
[ ] Finish Go .pkg from https://go.dev/dl/ if not done
[ ] Install page-only apps: Cursor, WhatsApp, Spark, Notion Calendar, The Unarchiver, T3 Code, Xcode
[ ] Grant Accessibility / Input Monitoring: Rectangle, LinearMouse, MiddleClick, Instant Space Switcher
[ ] Log in: Slack, Chrome, Docker, Bitwarden, GitHub, Discord, Zoom, Spotify, …
[ ] gh auth login
[ ] SSH keys (generate or restore)
[ ] Claude / Codex / Cursor sign-in

Re-run safely anytime:
  ./setup-mac.sh
  ./mac/download-apps.sh
EOF

log "Done"
