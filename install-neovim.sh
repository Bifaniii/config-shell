#!/usr/bin/env bash
# install-neovim.sh — Neovim 0.12 + config kickstart.nvim (nvim/) com LSP de Java (jdtls) e web/Angular.
# Chamado pelo install.sh; roda sozinho também.
#
# O neovim do apt (Debian 13) é velho demais para o kickstart atual (usa vim.pack, 0.12+),
# então o binário oficial vai para ~/.local/opt/nvim com link em ~/.local/bin/nvim.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REPO/lib/common.sh"

NVIM_VERSION="0.12.5"
NVIM_DIR="$HOME/.local/opt/nvim"
NVIM="$HOME/.local/bin/nvim"

# ---------- dependências: ripgrep (telescope), gcc/make (fzf-native, parsers), unzip (Mason) ----------
PKGS=(git curl ripgrep gcc make unzip)
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

# ---------- neovim oficial ----------
if [[ -x "$NVIM_DIR/bin/nvim" ]] && "$NVIM_DIR/bin/nvim" --version | head -1 | grep -q "v$NVIM_VERSION"; then
    info "Neovim $NVIM_VERSION já instalado"
else
    info "Baixando Neovim $NVIM_VERSION"
    tmp="$(mktemp -d)"
    curl -fsSL "https://github.com/neovim/neovim/releases/download/v$NVIM_VERSION/nvim-linux-x86_64.tar.gz" \
        | tar -xz -C "$tmp"
    rm -rf "$NVIM_DIR"
    mkdir -p "$(dirname "$NVIM_DIR")"
    mv "$tmp/nvim-linux-x86_64" "$NVIM_DIR"
    rm -rf "$tmp"
fi
mkdir -p "$(dirname "$NVIM")"
ln -sf "$NVIM_DIR/bin/nvim" "$NVIM"

# ---------- tree-sitter CLI (o nvim-treesitter novo compila os parsers com ele) ----------
export PATH="$HOME/.npm-global/bin:$PATH"
if command -v tree-sitter >/dev/null 2>&1; then
    info "tree-sitter CLI já instalado"
elif command -v npm >/dev/null 2>&1; then
    info "npm install -g tree-sitter-cli"
    npm install -g tree-sitter-cli
else
    warn "npm não encontrado: sem tree-sitter CLI os parsers não compilam (npm install -g tree-sitter-cli)"
fi

# ---------- config (symlink ~/.config/nvim -> repo) ----------
link nvim "$HOME/.config/nvim"

# ---------- plugins, parsers e servidores de linguagem sem abrir a UI ----------
# Na primeira abertura o vim.pack baixa os plugins e o nvim-treesitter compila os parsers
# (assíncrono, por isso o sleep). Depois o Mason instala os servidores de linguagem.
info "Instalando plugins e parsers do treesitter"
timeout 600 "$NVIM" --headless "+sleep 90" +qa </dev/null >/dev/null 2>&1 \
    || warn "Instalação de plugins falhou; abra o nvim e confira as mensagens"

# Servidores de linguagem: Java (jdtls) e web/Angular (TS, Angular, HTML, CSS, Emmet)
LSPS="jdtls typescript-language-server angular-language-server html-lsp css-lsp emmet-language-server"
info "Instalando os servidores de linguagem pelo Mason: $LSPS"
timeout 900 "$NVIM" --headless "+MasonInstall $LSPS" +qa </dev/null >/dev/null 2>&1 \
    || warn "Mason falhou; abra o nvim e rode :MasonInstall $LSPS"

info "Pronto. Abra um terminal novo e rode: nvim"
