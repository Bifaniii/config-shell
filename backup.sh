#!/usr/bin/env bash
# backup.sh — re-exporta o que NÃO é symlink (config do GNOME via dconf) e mostra o que mudou.
# Rode depois de mexer nas cores/fonte do gnome-terminal, no blur ou no tema GTK. Depois: git commit.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# descobre qual paleta está ativa pelo fundo e exporta pro arquivo certo
case "$(dconf read /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/background-color)" in
    "'#12161a'") palette=pastelterm ;;
    "'#1a1b26'") palette=tokyonight ;;
    *) echo "Fundo do terminal não bate com nenhuma paleta conhecida; exportando pra gnome/terminal-custom.dconf"; palette=custom ;;
esac
echo "Paleta ativa: $palette"
dconf dump /org/gnome/terminal/ > "$REPO/gnome/terminal-$palette.dconf"
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
