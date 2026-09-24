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

# ---------- SDKMAN (Java, Maven) ----------
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# ---------- NVM (lazy: só carrega no primeiro node/npm/npx/nvm) ----------
# O node do dia a dia vem do apt (NodeSource). O nvm só entra se estiver instalado.
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    load-nvm() {
        unset -f node npm npx nvm
        source "$NVM_DIR/nvm.sh"
    }
    for cmd in node npm npx nvm; do
        eval "$cmd() {
            load-nvm
            command $cmd \"\$@\"
        }"
    done
fi

# Local bin
export PATH="$HOME/.local/bin:$PATH"

# npm global (sem sudo)
export PATH="$HOME/.npm-global/bin:$PATH"


# Load Angular CLI autocompletion.
command -v ng >/dev/null 2>&1 && source <(ng completion script)

# vim abre o neovim (config em ~/.config/nvim -> ~/config-shell/nvim)
command -v nvim >/dev/null 2>&1 && alias vim=nvim

# Spring Boot: novo projeto Maven com Java 17
alias springnew='spring init --build=maven --java-version=17'
