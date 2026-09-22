#!/usr/bin/env bash
# install-desktop.sh — restaura o ambiente GNOME: tema WhiteSur, wallpaper, atalhos,
# dash-to-dock, blur-my-shell, nautilus, GTK. Chamado pelo install.sh; roda sozinho também.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REPO/lib/common.sh"

if ! has_gui; then
    warn "Sem sessão GNOME/dconf: nada a fazer aqui"
    exit 0
fi

step "Tema WhiteSur (GTK + ícones)"
if [[ -d "$HOME/.themes/WhiteSur-Dark" ]]; then
    info "WhiteSur já instalado"
else
    tmp="$(mktemp -d)"
    info "Clonando e instalando WhiteSur (pode demorar)"
    git clone --depth=1 -q https://github.com/vinceliuice/WhiteSur-gtk-theme.git  "$tmp/gtk"
    git clone --depth=1 -q https://github.com/vinceliuice/WhiteSur-icon-theme.git "$tmp/icons"
    "$tmp/gtk/install.sh"   -c Dark -c Light >/dev/null
    "$tmp/icons/install.sh" -t default >/dev/null
    rm -rf "$tmp"
fi

step "Wallpapers"
mkdir -p "$HOME/.local/share/backgrounds"
cp -n "$REPO"/wallpapers/* "$HOME/.local/share/backgrounds/" 2>/dev/null || true
info "Copiados para ~/.local/share/backgrounds"

step "Configurações do GNOME (dconf)"
load_dconf() {  # load_dconf <caminho dconf> <arquivo>
    [[ -f "$REPO/$2" ]] || return 0
    info "$2 -> $1"
    dconf load "$1" < "$REPO/$2"
}
load_dconf /org/gnome/desktop/interface/                    gnome/interface.dconf
load_dconf /org/gnome/settings-daemon/plugins/media-keys/   gnome/keybindings-media.dconf
load_dconf /org/gnome/desktop/wm/keybindings/               gnome/keybindings-wm.dconf
load_dconf /org/gnome/shell/                                gnome/shell.dconf
load_dconf /org/gnome/nautilus/                             gnome/nautilus.dconf

# desktop.dconf junta vários ramos em seções; carrega cada uma no lugar certo
info "gnome/desktop.dconf -> wm/peripherals/input/screensaver/background"
for sec in wm/preferences peripherals input-sources screensaver background; do
    body="$(awk -v s="[${sec}]" '$0==s{f=1;print "[/]";next} /^\[/{f=0} f' "$REPO/gnome/desktop.dconf")"
    [[ -n "$body" ]] && echo "$body" | dconf load "/org/gnome/desktop/${sec}/"
done

# gtk.dconf tem duas seções em caminhos diferentes
if [[ -f "$REPO/gnome/gtk.dconf" ]]; then
    info "gnome/gtk.dconf -> /org/gtk/settings e /org/gtk/gtk4/settings"
    awk '/^\[file-chooser\]/{n++} n==1' "$REPO/gnome/gtk.dconf" | dconf load /org/gtk/settings/ 2>/dev/null || true
fi

step "Extensões do GNOME Shell"
warn "Instale pelo extensions.gnome.org ou pelo Extension Manager (flatpak com.mattjakeman.ExtensionManager):"
while read -r ext; do
    [[ -z "$ext" ]] && continue
    if [[ -d "$HOME/.local/share/gnome-shell/extensions/$ext" || -d "/usr/share/gnome-shell/extensions/$ext" ]]; then
        info "  já instalada: $ext"
    else
        printf '     - %s\n' "$ext"
    fi
done < "$REPO/gnome/shell-extensions.txt"
info "A configuração delas já foi restaurada — ao instalar, nascem configuradas."

step "Configurações de apps"
if [[ -f "$REPO/flameshot/flameshot.ini" ]]; then
    mkdir -p "$HOME/.config/flameshot"
    cp -n "$REPO/flameshot/flameshot.ini" "$HOME/.config/flameshot/" && info "flameshot.ini" || info "flameshot.ini já existe"
fi
if [[ -f "$REPO/vscode/settings.json" ]]; then
    mkdir -p "$HOME/.config/Code/User"
    cp -n "$REPO/vscode/settings.json" "$HOME/.config/Code/User/" && info "VS Code settings.json" || info "VS Code settings.json já existe"
fi

info "Ambiente GNOME restaurado."
