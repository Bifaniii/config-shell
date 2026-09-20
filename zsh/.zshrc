# ---------- Oh My Zsh ----------
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# ---------- History ----------
HISTSIZE=5000
SAVEHIST=5000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE

# ---------- Lazy NVM ----------
export NVM_DIR="$HOME/.nvm"

load-nvm() {
    unset -f node npm npx nvm
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
}

for cmd in node npm npx nvm; do
    eval "$cmd() {
        load-nvm
        command $cmd \"\$@\"
    }"
done

# Local bin
export PATH="$HOME/.local/bin:$PATH"

# npm global (sem sudo)
export PATH="$HOME/.npm-global/bin:$PATH"


# Load Angular CLI autocompletion.
command -v ng >/dev/null 2>&1 && source <(ng completion script)

# vim abre o neovim (config em ~/.config/nvim -> ~/config-shell/nvim)
command -v nvim >/dev/null 2>&1 && alias vim=nvim
