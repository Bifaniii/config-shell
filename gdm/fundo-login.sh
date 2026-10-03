#!/usr/bin/env bash
# gdm/fundo-login.sh — põe o papel de parede como fundo da tela de login (GDM) e da tela de bloqueio do GNOME.
#   gdm/fundo-login.sh [imagem]     padrão: o wallpaper do Debian de wallpapers/
#
# O fundo do GDM fica dentro do tema do GNOME Shell (gnome-shell-theme.gresource, hoje o do WhiteSur):
# o script extrai o tema, troca o background.png e recompila. Backup em gnome-shell-theme.gresource.antes-do-fundo.
# Rode de novo depois de reinstalar/atualizar o tema do GDM. Também aplica a foto da conta, se existir
# ~/Imagens/itachi.jpg (fica fora do repo).
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO/lib/common.sh"

IMG="${1:-$(ls "$REPO"/wallpapers/*wallhaven-debian* | head -1)}"
G=/usr/share/gnome-shell/gnome-shell-theme.gresource
[[ -f "$IMG" ]] || { warn "Imagem não encontrada: $IMG"; exit 1; }

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
recursos=$(gresource list "$G")
for r in $recursos; do
    mkdir -p "$tmp$(dirname "$r")"
    gresource extract "$G" "$r" > "$tmp$r"
done
fundo=$(grep -oP 'resource:///\K[^")]+(?="\);?$)' "$tmp/org/gnome/shell/theme/gdm.css" 2>/dev/null | grep -m1 -i background || true)
fundo="${fundo:-org/gnome/shell/theme/background.png}"
cp "$IMG" "$tmp/$fundo"
{
    echo '<?xml version="1.0" encoding="UTF-8"?><gresources><gresource prefix="/">'
    for r in $recursos; do echo "<file>${r#/}</file>"; done
    echo '</gresource></gresources>'
} > "$tmp/tema.xml"
glib-compile-resources --sourcedir="$tmp" --target="$tmp/tema.gresource" "$tmp/tema.xml"

info "Instalando o tema do GDM com o fundo $(basename "$IMG") (pede sudo)"
sudo bash -c "[ -e '$G.antes-do-fundo' ] || cp -a '$G' '$G.antes-do-fundo'; install -m644 '$tmp/tema.gresource' '$G'"

FOTO="$HOME/Imagens/itachi.jpg"
if [[ -f "$FOTO" ]]; then
    sudo install -m644 "$FOTO" "/var/lib/AccountsService/icons/$USER"
    info "Foto da conta: $FOTO"
fi
info "Pronto. Aparece no próximo login."
