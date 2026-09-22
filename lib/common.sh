#!/usr/bin/env bash
# Funções compartilhadas pelos scripts de instalação.

REPO="${REPO:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
STAMP="${STAMP:-$(date +%Y%m%d-%H%M%S)}"

info() { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*"; }
step() { printf '\n\033[1;36m### %s\033[0m\n' "$*"; }

has_gui() { command -v dconf >/dev/null 2>&1 && [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; }

# link <origem relativa ao repo> <destino>
link() {
    local src="$REPO/$1" dst="$2"
    if [[ -L "$dst" && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
        info "Link ok: $dst"; return
    fi
    if [[ -e "$dst" || -L "$dst" ]]; then
        warn "Backup: $dst -> $dst.bak-$STAMP"
        mv "$dst" "$dst.bak-$STAMP"
    fi
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    info "Link criado: $dst -> $src"
}

# clone_if_missing <url> <destino>
clone_if_missing() {
    if [[ -d "$2" ]]; then info "Já existe: $(basename "$2")"
    else info "Clonando $(basename "$2")"; git clone --depth=1 -q "$1" "$2"; fi
}

# load_palette <pastelterm|dracula>
load_palette() {
    if has_gui; then
        info "Carregando paleta $1 no gnome-terminal"
        dconf load /org/gnome/terminal/ < "$REPO/gnome/terminal-$1.dconf"
    else
        warn "Sem sessão GNOME/dconf: pulando paleta do gnome-terminal"
    fi
}
