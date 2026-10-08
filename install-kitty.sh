#!/usr/bin/env bash
# install-kitty.sh — terminal kitty (binário oficial em ~/.local) com a config de kitty/.
# Chamado pelo install.sh; roda sozinho também.
#
# - fundo preto, paleta preto/vermelho, JetBrains Mono, splits (Alt+V / Alt+H)
# - tela de boas-vindas (fastfetch + logo do Debian) via ~/.zshenv, só dentro do kitty
# - vira o terminal padrão: Ctrl+Alt+T, "abrir terminal aqui" do Nautilus/Dolphin
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REPO/lib/common.sh"

KITTY_DIR="$HOME/.local/kitty.app"
APPS="$HOME/.local/share/applications"

# ---------- kitty ----------
if [[ -x "$KITTY_DIR/bin/kitty" ]]; then
    info "kitty já instalado ($("$KITTY_DIR/bin/kitty" --version))"
else
    info "Instalando o kitty (instalador oficial, sem sudo)"
    curl -fsSL https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n >/dev/null
fi
mkdir -p "$HOME/.local/bin" "$APPS"
ln -sf "$KITTY_DIR/bin/kitty" "$KITTY_DIR/bin/kitten" "$HOME/.local/bin/"

# atalhos de menu apontando para o binário
ICON="$KITTY_DIR/share/icons/hicolor/256x256/apps/kitty.png"
for f in kitty.desktop kitty-open.desktop; do
    sed -e "s|Icon=kitty|Icon=$ICON|g" \
        -e "s|TryExec=kitty|TryExec=$KITTY_DIR/bin/kitty|g" \
        -e "s|Exec=kitty|Exec=$KITTY_DIR/bin/kitty|g" \
        "$KITTY_DIR/share/applications/$f" > "$APPS/$f"
done
update-desktop-database "$APPS" 2>/dev/null || true

# ---------- config ----------
link kitty      "$HOME/.config/kitty"
link zsh/.zshenv "$HOME/.zshenv"

# ---------- terminal padrão (GNOME; no Plasma quem faz é o plasma/aplicar.sh) ----------
echo kitty.desktop > "$HOME/.config/xdg-terminals.list"
if has_gui; then
    gsettings set org.gnome.desktop.default-applications.terminal exec "$KITTY_DIR/bin/kitty"
    gsettings set org.gnome.desktop.default-applications.terminal exec-arg '--'
    info "kitty é o terminal padrão (Ctrl+Alt+T vem do gnome/keybindings-media.dconf)"
fi

info "Pronto. Abra com Ctrl+Alt+T."
