#!/usr/bin/env bash
# install-tokyonight.sh — OPCIONAL. Instala o neovim com o tema Tokyo Night e troca a paleta
# do gnome-terminal pra mesma do tema. Rode depois do ./install.sh (ou sozinho, se só quiser o nvim).
#
# Voltar pra paleta pastelterm:  ./install-tokyonight.sh --pastelterm
# (só troca as cores do terminal; o neovim continua instalado)

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

info() { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*"; }

load_palette() {  # load_palette <pastelterm|tokyonight>
    if command -v dconf >/dev/null 2>&1 && [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
        info "Carregando paleta $1 no gnome-terminal"
        dconf load /org/gnome/terminal/ < "$REPO/gnome/terminal-$1.dconf"
    else
        warn "Sem sessão GNOME/dconf: pulando paleta do gnome-terminal"
    fi
}

if [[ "${1:-}" == "--pastelterm" ]]; then
    load_palette pastelterm
    info "Pronto. Abra um terminal novo."
    exit 0
fi

# ---------- 1. neovim ----------
if ! command -v nvim >/dev/null 2>&1; then
    if command -v apt-get >/dev/null 2>&1; then
        info "Instalando neovim"
        sudo apt-get update -qq
        sudo apt-get install -y -qq neovim
    else
        warn "apt-get não encontrado: instale o neovim manualmente"; exit 1
    fi
fi

# ---------- 2. config (symlink ~/.config/nvim -> repo) ----------
dst="$HOME/.config/nvim"
if [[ -L "$dst" && "$(readlink -f "$dst")" == "$REPO/nvim" ]]; then
    info "Link ok: $dst"
else
    if [[ -e "$dst" || -L "$dst" ]]; then
        warn "Backup: $dst -> $dst.bak-$STAMP"
        mv "$dst" "$dst.bak-$STAMP"
    fi
    mkdir -p "$HOME/.config"
    ln -s "$REPO/nvim" "$dst"
    info "Link criado: $dst -> $REPO/nvim"
fi

# ---------- 3. plugins (lazy.nvim + tokyonight) sem abrir a UI ----------
info "Sincronizando plugins do neovim"
nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1 || warn "Lazy sync falhou; abra o nvim e rode :Lazy sync"

# ---------- 4. paleta do terminal ----------
load_palette tokyonight

info "Pronto. Abra um terminal novo e rode: nvim"
