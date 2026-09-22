#!/usr/bin/env bash
# install.sh — restaura a máquina inteira: programas, dotfiles, ambiente GNOME e tema.
#
#   git clone https://github.com/Bifaniii/config-shell.git ~/config-shell
#   cd ~/config-shell && ./install.sh
#
# Etapas (cada uma também roda sozinha):
#   ./install-apps.sh      programas: apt, flatpak, SDKMAN, npm, extensões do VS Code
#   ./install-desktop.sh   GNOME: tema WhiteSur, wallpaper, atalhos, dash-to-dock, blur
#   ./install-dracula.sh   neovim + tema Dracula + paleta do terminal
#
# Flags:
#   --no-apps       pula a instalação de programas (só configs)
#   --no-desktop    pula o ambiente GNOME
#   --pastelterm    usa a paleta pastelterm em vez da Dracula
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REPO/lib/common.sh"

DO_APPS=1; DO_DESKTOP=1; PALETTE=dracula
for arg in "$@"; do
    case "$arg" in
        --no-apps)    DO_APPS=0 ;;
        --no-desktop) DO_DESKTOP=0 ;;
        --pastelterm) PALETTE=pastelterm ;;
        -h|--help)    sed -n '2,20p' "$0"; exit 0 ;;
        *) warn "Opção desconhecida: $arg"; exit 1 ;;
    esac
done

# ---------- 1. programas ----------
if (( DO_APPS )); then
    "$REPO/install-apps.sh"
else
    step "Pacotes mínimos (--no-apps)"
    PKGS=(zsh vim git curl fonts-jetbrains-mono dconf-cli)
    if command -v apt-get >/dev/null 2>&1; then
        missing=()
        for p in "${PKGS[@]}"; do dpkg -s "$p" >/dev/null 2>&1 || missing+=("$p"); done
        if (( ${#missing[@]} )); then
            info "Instalando: ${missing[*]}"
            sudo apt-get update -qq && sudo apt-get install -y -qq "${missing[@]}"
        else
            info "Já instalados: ${PKGS[*]}"
        fi
    else
        warn "apt-get não encontrado: instale manualmente: ${PKGS[*]}"
    fi
fi

# ---------- 2. zsh: oh-my-zsh e plugins ----------
step "Oh My Zsh e plugins"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    info "Instalando oh-my-zsh"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
clone_if_missing https://github.com/zsh-users/zsh-autosuggestions     "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# ---------- 3. temas do vim ----------
step "Temas do vim"
mkdir -p "$HOME/.vim/pack/themes/start" "$HOME/.vim/colors"
clone_if_missing https://github.com/dracula/vim.git           "$HOME/.vim/pack/themes/start/dracula"
clone_if_missing https://github.com/crusoexia/vim-monokai.git "$HOME/.vim/pack/themes/start/monokai"

# ---------- 4. dotfiles (symlinks) ----------
step "Dotfiles"
link zsh/.zshrc                 "$HOME/.zshrc"
link vim/.vimrc                 "$HOME/.vimrc"
link vim/colors/pastelterm.vim  "$HOME/.vim/colors/pastelterm.vim"
link git/.gitconfig             "$HOME/.gitconfig"

# ---------- 5. ambiente GNOME ----------
if (( DO_DESKTOP )); then
    "$REPO/install-desktop.sh"
fi

# ---------- 6. neovim + paleta do terminal ----------
if [[ "$PALETTE" == "dracula" ]]; then
    "$REPO/install-dracula.sh"
else
    load_palette pastelterm
fi

# ---------- 7. zsh como shell padrão ----------
step "Shell padrão"
if [[ "$(basename "${SHELL:-}")" != "zsh" ]] && command -v zsh >/dev/null 2>&1; then
    info "Definindo zsh como shell padrão (pode pedir senha)"
    chsh -s "$(command -v zsh)" || warn "chsh falhou; rode: chsh -s $(command -v zsh)"
else
    info "zsh já é o shell padrão"
fi

step "Pronto"
info "Abra um terminal novo. Se entrou no grupo docker ou trocou de shell, deslogue e logue de novo."
info "Extensões do GNOME: instale pelo extensions.gnome.org (lista acima) — a config delas já está aplicada."
