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

info "Instalando parsers do treesitter que faltarem (compila com gcc)"
# TSInstallSync trava pedindo confirmação se o parser já existe, então instalamos
# só os que faltam; se não faltar nenhum, sai na hora.
timeout 900 nvim --headless -c 'lua
require("lazy").load({plugins={"nvim-treesitter"}})
local want = {"typescript","tsx","javascript","html","css","scss","json","yaml",
              "java","python","bash","lua","vim","vimdoc","markdown","markdown_inline",
              "regex","dockerfile","sql"}
local have = require("nvim-treesitter.info").installed_parsers()
local missing = {}
for _, p in ipairs(want) do
  if not vim.tbl_contains(have, p) then missing[#missing+1] = p end
end
if #missing > 0 then
  print("Compilando: " .. table.concat(missing, " "))
  vim.cmd("TSInstallSync " .. table.concat(missing, " "))
else
  print("Todos os parsers já instalados")
end
os.exit(0)' </dev/null || warn "Parsers falharam; abra o nvim e rode :TSUpdate"

# ---------- paleta do terminal ----------
load_palette dracula

info "Pronto. Abra um terminal novo e rode: nvim"
