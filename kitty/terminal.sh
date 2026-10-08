#!/usr/bin/env bash
# Ctrl+Alt+T: se o kitty já está aberto, abre uma aba nova nele (troca com Ctrl+PgUp/PgDn);
# senão, abre o kitty. Usa o controle remoto do kitty (listen_on em kitty.conf: o kitty
# cria o socket @kitty-$USER-<pid>; aqui pega o do kitty aberto mais recente).
KITTY="$HOME/.local/kitty.app/bin/kitty"

sock=$(ss -xl 2>/dev/null | grep -oE "@kitty-$USER-[0-9]+" | sort -t- -k3 -n | tail -1)
if [[ -n "$sock" ]] && id=$("$KITTY" @ --to "unix:$sock" launch --type=tab --cwd="$HOME" 2>/dev/null); then
    "$KITTY" @ --to "unix:$sock" focus-window --match "id:$id" >/dev/null 2>&1
else
    exec "$KITTY" "$@"
fi
