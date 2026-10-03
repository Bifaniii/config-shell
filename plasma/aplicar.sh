#!/usr/bin/env bash
# plasma/aplicar.sh — aplica a personalização do KDE Plasma 6 (Wayland). Rode DENTRO de uma sessão Plasma.
# Pode rodar de novo quando quiser: refaz tudo do zero (painéis inclusive).
#
# Visual:  Breeze Dark + esquema "Breeze Preto" (fundos pretos) com destaque #e60000, ícones WhiteSur-dark,
#          cursor WhiteSur, decoração de janela WhiteSur-dark (botões do macOS à esquerda, barra quase preta).
# Painéis: barra em cima que se esconde (Atividades, relógio, CPU/memória, bandeja com % da bateria)
#          + dock flutuante que se esconde (Launchpad + favoritos). Sem ícones na área de trabalho.
# Teclas:  Super 1x = Visão geral; 2x / Meta+A / Alt+F1 = Launchpad; Ctrl+Space = busca (KRunner);
#          Ctrl+Alt+T = kitty (abre na metade de baixo); Print = Flameshot.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO/lib/common.sh"
P="$REPO/plasma"

if [[ "${XDG_CURRENT_DESKTOP:-}" != *KDE* ]] || ! pgrep -x plasmashell >/dev/null; then
    warn "Isto precisa rodar dentro de uma sessão Plasma (entre em \"Plasma (Wayland)\" no login)."
    exit 1
fi

# invoca o serviço de atalhos globais (kglobalaccel). Flag 6 = SetPresent|NoAutoloading:
# sem o "present" o atalho fica registrado mas inativo.
atalho() {  # atalho <componente> <ação> <nome legível> <teclas Qt separadas por vírgula, ou vazio>
    local id="[\"$1\",\"$2\",\"$3\",\"$3\"]" teclas="@ai []"
    [[ -n "${4:-}" ]] && teclas="[$4]"
    gdbus call --session --dest org.kde.kglobalaccel --object-path /kglobalaccel \
        --method org.kde.KGlobalAccel.doRegister "$id" >/dev/null
    gdbus call --session --dest org.kde.kglobalaccel --object-path /kglobalaccel \
        --method org.kde.KGlobalAccel.setShortcut "$id" "$teclas" 6 >/dev/null
}
# códigos de tecla do Qt
META=$((0x10000000)); CTRL=$((0x04000000)); ALT=$((0x08000000))
K_META=16777250; K_PRINT=16777225; K_SPACE=32; K_A=65; K_T=84; K_F1=16777264

# ---------- arquivos ----------
step "Arquivos (temas, widgets, scripts)"
mkdir -p ~/.local/share/{color-schemes,plasma/plasmoids,aurorae/themes,super-gnome,applications} \
         ~/.local/bin ~/.config/systemd/user ~/.config/autostart
cp "$P/BreezePreto.colors" ~/.local/share/color-schemes/
for w in "$P"/plasmoids/*/; do rm -rf ~/.local/share/plasma/plasmoids/"$(basename "$w")"; cp -r "$w" ~/.local/share/plasma/plasmoids/; done
rm -rf ~/.local/share/aurorae/themes/WhiteSur-dark; cp -r "$P/aurorae/WhiteSur-dark" ~/.local/share/aurorae/themes/
install -m755 "$P/super-gnome/super-gnome" ~/.local/bin/super-gnome
cp "$P/super-gnome/toque.js" ~/.local/share/super-gnome/toque.js
cp "$P/super-gnome/super-gnome.service" ~/.config/systemd/user/
cat > ~/.local/share/applications/super-gnome.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Super estilo GNOME
Comment=1 toque: visão geral; 2 toques: Launchpad
Exec=$HOME/.local/bin/super-gnome
NoDisplay=true
StartupNotify=false
EOF
systemctl --user daemon-reload
install -m755 "$P/tema-gtk-da-sessao" ~/.local/bin/tema-gtk-da-sessao
for s in gnome:GNOME plasma:KDE; do
    cat > ~/.config/autostart/tema-gtk-${s%%:*}.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Tema GTK da sessão (${s%%:*})
Exec=$HOME/.local/bin/tema-gtk-da-sessao ${s%%:*}
OnlyShowIn=${s##*:};
NoDisplay=true
X-GNOME-Autostart-Phase=Initialization
EOF
done
cp "$P/kwinrulesrc" ~/.config/kwinrulesrc   # regra: kitty abre na metade de baixo
kbuildsycoca6 >/dev/null 2>&1 || true

# ---------- aparência ----------
step "Aparência"
plasma-apply-lookandfeel -a org.kde.breezedark.desktop >/dev/null 2>&1 || true
plasma-apply-colorscheme BreezePreto >/dev/null
plasma-apply-colorscheme --accent-color '#e60000' >/dev/null
[[ -d ~/.local/share/icons/WhiteSur-dark ]] && /usr/lib/x86_64-linux-gnu/libexec/plasma-changeicons WhiteSur-dark >/dev/null 2>&1
if [[ -d ~/.local/share/icons/WhiteSur-cursors ]]; then
    mkdir -p ~/.icons && ln -sfn ~/.local/share/icons/WhiteSur-cursors ~/.icons/WhiteSur-cursors
    plasma-apply-cursortheme WhiteSur-cursors >/dev/null
fi
WALL="$(ls "$HOME"/.local/share/backgrounds/*wallhaven-debian* 2>/dev/null | head -1 || true)"
if [[ -n "$WALL" ]]; then
    plasma-apply-wallpaperimage "$WALL" >/dev/null
    for k in Image PreviewImage; do
        kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key $k "file://$WALL"
    done
fi
# tela de bloqueio sem os controles de mídia (mostravam o que está tocando, ex. a aba do Chrome)
kwriteconfig6 --file kscreenlockerrc --group Greeter --group LnF --group General --key showMediaControls false
kwriteconfig6 --file kdeglobals --group General --key fixed "JetBrains Mono,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
kwriteconfig6 --file kdeglobals --group General --key TerminalApplication kitty
kwriteconfig6 --file kdeglobals --group General --key TerminalService kitty.desktop
kwriteconfig6 --file kdeglobals --group "KFileDialog Settings" --key "Show hidden files" true
mkdir -p ~/.local/share/dolphin/view_properties/global
printf '[Settings]\nHiddenFilesShown=true\n' > ~/.local/share/dolphin/view_properties/global/.directory
"$HOME/.local/bin/tema-gtk-da-sessao" plasma

# ---------- teclado e touchpad ----------
step "Teclado ABNT2 e touchpad"
kwriteconfig6 --file kxkbrc --group Layout --key LayoutList br
kwriteconfig6 --file kxkbrc --group Layout --key Use true
kwriteconfig6 --file kxkbrc --group Layout --key Model abnt2
dbus-send --session --type=signal --dest=org.kde.keyboard /Layouts org.kde.keyboard.reloadConfig
# rolagem natural no touchpad, como no GNOME
for dev in $(qdbus6 org.kde.KWin | grep -E '^/org/kde/KWin/InputDevice/event'); do
    tp=$(gdbus call --session --dest org.kde.KWin --object-path "$dev" --method org.freedesktop.DBus.Properties.Get \
         org.kde.KWin.InputDevice touchpad 2>/dev/null | tr -d '(<>),' || true)
    [[ "$tp" == true ]] && gdbus call --session --dest org.kde.KWin --object-path "$dev" \
        --method org.freedesktop.DBus.Properties.Set org.kde.KWin.InputDevice naturalScroll "<true>" >/dev/null || true
done

# ---------- KWin ----------
step "Janelas (KWin)"
kwriteconfig6 --file kwinrc --group Plugins --key magiclampEnabled true
kwriteconfig6 --file kwinrc --group Plugins --key squashEnabled false
# nada abre ao encostar o mouse nos cantos
kwriteconfig6 --file kwinrc --group Effect-overview --key BorderActivate 9
kwriteconfig6 --file kwinrc --group Effect-overview --key GridBorderActivate 9
for b in Top TopRight Right BottomRight Bottom BottomLeft Left TopLeft; do
    kwriteconfig6 --file kwinrc --group ElectricBorders --key $b None
done
# botões do macOS (fechar, minimizar, maximizar) à esquerda
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key library org.kde.kwin.aurorae
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme __aurorae__svg__WhiteSur-dark
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnLeft XIA
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight ""
# o Super sozinho é tratado pelo super-gnome (atalho abaixo), não pelo KWin
kwriteconfig6 --file kwinrc --group ModifierOnlyShortcuts --key Meta ""
qdbus6 org.kde.KWin /KWin org.kde.KWin.reconfigure
qdbus6 org.kde.KWin /Effects org.kde.kwin.Effects.unloadEffect overview >/dev/null 2>&1 || true
qdbus6 org.kde.KWin /Effects org.kde.kwin.Effects.loadEffect overview >/dev/null 2>&1 || true

# ---------- atalhos ----------
step "Atalhos"
kwriteconfig6 --file krunnerrc --group General --key FreeFloating true   # busca no centro, estilo Spotlight
kwriteconfig6 --file krunnerrc --group General --key ActivateWhenTypingOnDesktop true
qdbus6 org.kde.krunner /MainApplication quit >/dev/null 2>&1 || true
atalho kitty.desktop _launch kitty                        "$((CTRL|ALT|K_T))"
atalho org.flameshot.Flameshot.desktop Capture Flameshot  "$K_PRINT"
atalho org.kde.krunner.desktop _launch KRunner            "$((CTRL|K_SPACE)), $((ALT|K_SPACE))"
atalho super-gnome.desktop _launch "Super estilo GNOME"   "$K_META"
atalho plasmashell "activate application launcher" "Ativar o lançador de aplicativos" "$((META|K_A)), $((ALT|K_F1))"
atalho plasmashell "next activity" "Percorrer as atividades" ""

# ---------- painéis e área de trabalho ----------
step "Painéis"
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat "$P/layout.js")" >/dev/null
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '
desktops().forEach(function (d) {   // sem ícones na área de trabalho (os arquivos continuam na pasta)
    d.currentConfigGroup = ["General"];
    d.writeConfig("filterMode", 2);
    d.writeConfig("filterPattern", "*");
    d.reloadConfig();
});' >/dev/null
sleep 2
# % da bateria e painéis opacos: só dá editando com o plasmashell parado
F=~/.config/plasma-org.kde.plasma.desktop-appletsrc
systemctl --user stop plasma-plasmashell.service; sleep 2
st=$(grep -oP '^SystrayContainmentId=\K[0-9]+' "$F" | tail -1)
bat=$(awk -v s="$st" '/^\[Containments\]\[[0-9]+\]\[Applets\]\[[0-9]+\]$/{sec=$0} /^plugin=org.kde.plasma.battery$/{print sec}' "$F" \
      | grep -oP "^\[Containments\]\[$st\]\[Applets\]\[\K[0-9]+" | tail -1)
[[ -n "$bat" ]] && kwriteconfig6 --file "$F" --group Containments --group "$st" --group Applets --group "$bat" \
    --group Configuration --group General --key showPercentage true
for g in $(grep -oP '^\[PlasmaViews\]\[Panel \K[0-9]+(?=\]$)' ~/.config/plasmashellrc); do
    kwriteconfig6 --file plasmashellrc --group PlasmaViews --group "Panel $g" --key panelOpacity 1
done
rm -rf ~/.cache/plasmashell
systemctl --user start plasma-plasmashell.service

info "Pronto. Algumas coisas (teclado, tema GTK) só ficam 100% depois de sair e entrar de novo."
