#!/usr/bin/env bash
# install-plasma.sh — KDE Plasma 6 ao lado do GNOME (o GDM continua sendo a tela de login).
# Chamado pelo install.sh; roda sozinho também.
#
# Instala o Plasma sem os pacotes recomendados (evita dezenas de apps do KDE duplicando os do GNOME),
# só com os componentes que fazem falta (rede, som, Bluetooth, energia, monitores, portal),
# os widgets/efeitos extras e os cursores WhiteSur. A personalização em si é o plasma/aplicar.sh,
# que precisa rodar dentro de uma sessão Plasma: no login, escolha "Plasma (Wayland)" na engrenagem.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REPO/lib/common.sh"

PKGS=(kde-plasma-desktop plasma-nm plasma-pa bluedevil powerdevil kscreen xdg-desktop-portal-kde
      breeze-gtk-theme kde-config-gtk-style polkit-kde-agent-1 kinfocenter plasma-systemmonitor
      kwin-wayland plasma-workspace-wallpapers plasma-widgets-addons kwin-addons plasma-wallpapers-addons)

missing=()
for p in "${PKGS[@]}"; do dpkg -s "$p" >/dev/null 2>&1 || missing+=("$p"); done
if (( ${#missing[@]} )); then
    info "Instalando ${#missing[@]} pacotes do Plasma (sem recomendados; ~400 MB)"
    # mantém o GDM como gerenciador de login
    echo "gdm3 shared/default-x-display-manager select gdm3" | sudo debconf-set-selections
    sudo apt-get update -qq
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -q --no-install-recommends "${missing[@]}"
else
    info "Plasma já instalado"
fi

# cursores do macOS (WhiteSur), usados pelo plasma/aplicar.sh
if [[ -d "$HOME/.local/share/icons/WhiteSur-cursors" ]]; then
    info "Cursores WhiteSur já instalados"
else
    tmp="$(mktemp -d)"
    git clone --depth=1 -q https://github.com/vinceliuice/WhiteSur-cursors.git "$tmp"
    mkdir -p "$HOME/.local/share/icons"
    cp -r "$tmp/dist" "$HOME/.local/share/icons/WhiteSur-cursors"
    rm -rf "$tmp"
    info "Cursores WhiteSur instalados"
fi

# GNOME e Plasma dividem org.gnome.desktop.interface: cada sessão reaplica o próprio tema no login.
# Fica instalado já aqui para o primeiro login no Plasma não bagunçar o GNOME.
mkdir -p "$HOME/.local/bin" "$HOME/.config/autostart"
install -m755 "$REPO/plasma/tema-gtk-da-sessao" "$HOME/.local/bin/tema-gtk-da-sessao"
for s in gnome:GNOME plasma:KDE; do
    cat > "$HOME/.config/autostart/tema-gtk-${s%%:*}.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Tema GTK da sessão (${s%%:*})
Exec=$HOME/.local/bin/tema-gtk-da-sessao ${s%%:*}
OnlyShowIn=${s##*:};
NoDisplay=true
X-GNOME-Autostart-Phase=Initialization
EOF
done

if [[ "${XDG_CURRENT_DESKTOP:-}" == *KDE* ]]; then
    "$REPO/plasma/aplicar.sh"
else
    info "Plasma instalado. Saia, escolha \"Plasma (Wayland)\" na engrenagem do login e rode:"
    info "  ~/config-shell/plasma/aplicar.sh"
fi
