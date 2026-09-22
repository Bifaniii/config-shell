#!/usr/bin/env bash
# install-dracula.sh — neovim com o tema Dracula + paleta do gnome-terminal na mesma cor
# (as mesmas do Dracula do VS Code). Chamado pelo install.sh; roda sozinho também.
#
# Voltar pra paleta pastelterm:  ./install-dracula.sh --pastelterm
# (só troca as cores do terminal; o neovim continua instalado)

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REPO/lib/common.sh"





if [[ "${1:-}" == "--pastelterm" ]]; then
    load_palette pastelterm
    info "Pronto. Abra um terminal novo."
    exit 0
fi

# ---------- neovim + ripgrep (telescope) + gcc (compila parsers do treesitter) ----------
PKGS=(neovim ripgrep gcc)
if command -v apt-get >/dev/null 2>&1; then
    missing=()
    for p in "${PKGS[@]}"; do dpkg -s "$p" >/dev/null 2>&1 || missing+=("$p"); done
    if (( ${#missing[@]} )); then
        info "Instalando pacotes: ${missing[*]}"
        sudo apt-get update -qq
        sudo apt-get install -y -qq "${missing[@]}"
    else
        info "Pacotes já instalados: ${PKGS[*]}"
    fi
else
    warn "apt-get não encontrado: instale manualmente: ${PKGS[*]}"
fi

# ---------- config (symlink ~/.config/nvim -> repo) ----------
link nvim "$HOME/.config/nvim"

# ---------- plugins (lazy.nvim + dracula) sem abrir a UI ----------
info "Sincronizando plugins do neovim"
nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1 || warn "Lazy sync falhou; abra o nvim e rode :Lazy sync"

info "Compilando parsers do treesitter (pode levar alguns minutos)"
# TSInstallSync fica preso num prompt ao final; o timeout só mata o processo depois de tudo compilado
timeout 900 nvim --headless \
    -c 'lua require("lazy").load({plugins={"nvim-treesitter"}})' \
    -c 'TSInstallSync typescript tsx javascript html css scss json yaml java python bash lua vim vimdoc markdown markdown_inline regex dockerfile sql' \
    -c qa >/dev/null 2>&1 || true

# ---------- paleta do terminal ----------
load_palette dracula

info "Pronto. Abra um terminal novo e rode: nvim"
