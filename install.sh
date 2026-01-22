#!/bin/bash
# curl -fsSL https://raw.githubusercontent.com/laurensent/bootstrap/main/install.sh | bash
set -e

ARCH=$(uname -m)
BREW_PREFIX=$([[ "$ARCH" = "arm64" ]] && echo "/opt/homebrew" || echo "/usr/local")

# Homebrew
if ! command -v brew &>/dev/null; then
    echo "[0/3] Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$($BREW_PREFIX/bin/brew shellenv)"

# Tools
echo "[1/3] Installing tools"
brew install gh chezmoi &>/dev/null || true

# GitHub auth
gh auth status &>/dev/null || gh auth login -p ssh -h github.com -s admin:ssh_signing_key < /dev/tty
git config --global url."git@github.com:".insteadOf "https://github.com/" 2>/dev/null

# Dotfiles
echo "[2/3] Syncing dotfiles"
if [ -d ~/.local/share/chezmoi ]; then
    git -C ~/.local/share/chezmoi fetch -q && git -C ~/.local/share/chezmoi reset --hard origin/master -q || {
        rm -rf ~/.local/share/chezmoi
        gh repo clone laurensent/dotfiles ~/.local/share/chezmoi &>/dev/null
    }
else
    gh repo clone laurensent/dotfiles ~/.local/share/chezmoi &>/dev/null
fi

echo "[3/3] Configuring"
~/.local/share/chezmoi/install.sh
