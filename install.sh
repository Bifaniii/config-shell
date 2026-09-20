#!/usr/bin/env bash
# install.sh — restaura todo o ambiente de terminal (zsh + vim + gnome-terminal + tema)
# Uso: git clone https://github.com/Bifaniii/config-shell.git && cd config-shell && ./install.sh
#
# Os arquivos de config viram SYMLINKS apontando pra dentro deste repo.
# Editou ~/.zshrc ou ~/.vimrc? O repo já reflete. Só falta `git commit`.
# Config do gnome-terminal/blur não dá pra symlinkar: use ./backup.sh pra re-exportar.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

info() { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*"; }

# ---------- 1. pacotes ----------
if command -v apt-get >/dev/null 2>&1; then
    info "Instalando pacotes (zsh, vim, git, curl, fonte JetBrains Mono, dconf-cli)"
    sudo apt-get update -qq
    sudo apt-get install -y -qq zsh vim git curl fonts-jetbrains-mono dconf-cli
else
    warn "apt-get não encontrado: instale manualmente zsh vim git curl fonts-jetbrains-mono dconf-cli"
fi

# ---------- 2. oh-my-zsh + plugins ----------
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    info "Instalando oh-my-zsh"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
clone_if_missing() {  # clone_if_missing <url> <destino>
    if [[ -d "$2" ]]; then
        info "Já existe: $2"
    else
        info "Clonando $1"
        git clone --depth=1 "$1" "$2"
    fi
}
clone_if_missing https://github.com/zsh-users/zsh-autosuggestions     "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# ---------- 3. temas do vim (pack nativo) ----------
mkdir -p "$HOME/.vim/pack/themes/start" "$HOME/.vim/colors"
clone_if_missing https://github.com/dracula/vim.git            "$HOME/.vim/pack/themes/start/dracula"
clone_if_missing https://github.com/crusoexia/vim-monokai.git  "$HOME/.vim/pack/themes/start/monokai"

# ---------- 4. symlinks ----------
link() {  # link <origem no repo> <destino em ~>
    local src="$REPO/$1" dst="$2"
    if [[ -L "$dst" && "$(readlink -f "$dst")" == "$src" ]]; then
        info "Link ok: $dst"
        return
    fi
    if [[ -e "$dst" || -L "$dst" ]]; then
        warn "Backup: $dst -> $dst.bak-$STAMP"
        mv "$dst" "$dst.bak-$STAMP"
    fi
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    info "Link criado: $dst -> $src"
}
link zsh/.zshrc                 "$HOME/.zshrc"
link vim/.vimrc                 "$HOME/.vimrc"
link vim/colors/pastelterm.vim  "$HOME/.vim/colors/pastelterm.vim"
link git/.gitconfig             "$HOME/.gitconfig"

# ---------- 5. gnome-terminal / blur / tema GTK (só se tiver sessão gráfica GNOME) ----------
if command -v dconf >/dev/null 2>&1 && [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
    info "Carregando perfil do gnome-terminal (cores pastelterm + JetBrains Mono)"
    dconf load /org/gnome/terminal/ < "$REPO/gnome/terminal.dconf"

    info "Carregando config do blur-my-shell"
    dconf load /org/gnome/shell/extensions/blur-my-shell/ < "$REPO/gnome/blur-my-shell.dconf"

    if command -v gnome-shell >/dev/null 2>&1; then
        if [[ ! -d "$HOME/.themes/WhiteSur-Dark" ]]; then
            info "Instalando tema WhiteSur (GTK + ícones)"
            tmp="$(mktemp -d)"
            git clone --depth=1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git  "$tmp/gtk"
            git clone --depth=1 https://github.com/vinceliuice/WhiteSur-icon-theme.git "$tmp/icons"
            "$tmp/gtk/install.sh"   -c Dark -c Light >/dev/null
            "$tmp/icons/install.sh" -t default >/dev/null
            rm -rf "$tmp"
        fi
        info "Aplicando tema GTK/ícones/dark mode"
        dconf load /org/gnome/desktop/interface/ < "$REPO/gnome/interface.dconf"
    fi

    warn "Extensões GNOME precisam ser instaladas pelo site extensions.gnome.org (lista em gnome/shell-extensions.txt):"
    sed 's/^/     - /' "$REPO/gnome/shell-extensions.txt"
else
    warn "Sem sessão GNOME/dconf: pulando gnome-terminal, blur e tema GTK"
fi

# ---------- 6. shell padrão ----------
if [[ "$(basename "${SHELL:-}")" != "zsh" ]] && command -v zsh >/dev/null 2>&1; then
    info "Definindo zsh como shell padrão (pode pedir senha)"
    chsh -s "$(command -v zsh)" || warn "chsh falhou; rode manualmente: chsh -s $(command -v zsh)"
fi

info "Pronto. Abra um terminal novo (ou: exec zsh)."
