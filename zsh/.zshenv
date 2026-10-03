# ~/.zshenv (symlink -> config-shell/zsh/.zshenv)
# Boas-vindas do kitty (fastfetch): só em shell interativo dentro do kitty.
# Config da tela em kitty/boas-vindas.jsonc.
if [[ -o interactive && -n $KITTY_WINDOW_ID && -z $KITTY_BOAS_VINDAS ]] && command -v fastfetch >/dev/null; then
    export KITTY_BOAS_VINDAS=1
    fastfetch -c ~/.config/kitty/boas-vindas.jsonc
fi
