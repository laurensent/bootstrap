#!/bin/bash
# curl -fsSL https://raw.githubusercontent.com/laurensent/bootstrap/main/uninstall.sh | bash
set -e

echo "[1/2] Checking"
echo "      This will remove all chezmoi managed files and directories."
read -p "      Continue? [y/N] " -n 1 -r < /dev/tty
echo ""
[[ $REPLY =~ ^[Yy]$ ]] || exit 0

if [ -d ~/.local/share/chezmoi/.git ]; then
    cd ~/.local/share/chezmoi
    if [ -n "$(git status --porcelain)" ]; then
        echo "      Warning: uncommitted changes detected"
        read -p "      Continue anyway? [y/N] " -n 1 -r < /dev/tty
        echo ""
        [[ $REPLY =~ ^[Yy]$ ]] || exit 0
    fi
fi

echo "[2/2] Removing files"
if command -v chezmoi &>/dev/null && [ -d ~/.local/share/chezmoi ]; then
    chezmoi managed --path-style=absolute 2>/dev/null | while read -r f; do
        [[ "$f" == *"/.ssh"* ]] && continue
        [ -f "$f" ] && rm -f "$f"
    done
    chezmoi managed --path-style=absolute 2>/dev/null | sort -r | while read -r f; do
        [[ "$f" == *"/.ssh"* ]] && continue
        d=$(dirname "$f"); [ -d "$d" ] && rmdir "$d" 2>/dev/null || true
    done
fi

rm -rf ~/.local/share/chezmoi ~/.config/chezmoi ~/.oh-my-zsh
echo "      Done."
