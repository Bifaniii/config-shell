#!/usr/bin/env bash
# Abre o kitty ocupando a metade de baixo do monitor principal (X11).
# Usado pelo Ctrl+Alt+T e pelo ícone do kitty (kitty.desktop). Argumentos extras vão para o kitty.
KITTY="$HOME/.local/kitty.app/bin/kitty"

# No Wayland (Plasma) o kitty não posiciona a própria janela: quem faz isso é a regra
# "kitty na metade de baixo" do KWin (Configurações > Janelas > Regras de janela)
if [[ -n $WAYLAND_DISPLAY ]]; then exec "$KITTY" "$@"; fi

# monitor principal: LARGURAxALTURA+X+Y
geo=$(xrandr --current 2>/dev/null | grep -m1 ' connected primary' | grep -oE '[0-9]+x[0-9]+\+[0-9]+\+[0-9]+')
if [[ -z $geo ]]; then exec "$KITTY" "$@"; fi
IFS='x+' read -r mw mh mx my <<< "$geo"

# topo da área útil (abaixo da barra superior do GNOME)
wa_y=$(xprop -root _NET_WORKAREA 2>/dev/null | grep -oE '[0-9]+' | sed -n 2p)
topo=$(( ${wa_y:-$my} > my ? ${wa_y:-$my} : my ))

altura=$(( (my + mh - topo) / 2 ))
y=$(( my + mh - altura ))

exec "$KITTY" --position "${mx}x${y}" \
    -o initial_window_width="$mw" -o initial_window_height="$altura" "$@"
