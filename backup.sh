#!/usr/bin/env bash
# backup.sh — re-exporta o que NÃO é symlink (config do GNOME via dconf) e mostra o que mudou.
# Rode depois de mexer nas cores/fonte do gnome-terminal, no blur ou no tema GTK. Depois: git commit.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

dconf dump /org/gnome/terminal/ > "$REPO/gnome/terminal.dconf"
dconf dump /org/gnome/shell/extensions/blur-my-shell/ > "$REPO/gnome/blur-my-shell.dconf"
dconf dump /org/gnome/desktop/interface/ | grep -E '^\[|gtk-theme|icon-theme|color-scheme|font' > "$REPO/gnome/interface.dconf"
gsettings get org.gnome.shell enabled-extensions | tr -d "[]' " | tr ',' '\n' > "$REPO/gnome/shell-extensions.txt"

cd "$REPO"
if git diff --quiet; then
    echo "Nada mudou desde o último commit."
else
    git --no-pager diff --stat
    echo
    echo "Pra salvar:  cd $REPO && git commit -am 'update' && git push"
fi
