#!/usr/bin/env bash
# install-apps.sh — instala os PROGRAMAS (apt, flatpak, SDKMAN, npm global, extensões do VS Code).
# Chamado pelo install.sh; pode ser rodado sozinho. Idempotente, mas demorado (vários GB).
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REPO/lib/common.sh"

step "Repositórios de terceiros"
"$REPO/packages/apt-repos.sh"

step "Pacotes apt"
mapfile -t PKGS < <(grep -vE '^\s*#|^\s*$' "$REPO/packages/apt.txt")
missing=()
for p in "${PKGS[@]}"; do dpkg -s "$p" >/dev/null 2>&1 || missing+=("$p"); done
if (( ${#missing[@]} )); then
    info "Instalando ${#missing[@]} pacotes: ${missing[*]}"
    sudo apt-get install -y "${missing[@]}"
else
    info "Todos os ${#PKGS[@]} pacotes já instalados"
fi

step "Docker sem sudo"
if getent group docker >/dev/null && ! id -nG "$USER" | grep -qw docker; then
    sudo usermod -aG docker "$USER"
    warn "Você foi adicionado ao grupo docker — precisa deslogar e logar de novo"
fi

step "Flatpak"
if command -v flatpak >/dev/null 2>&1; then
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    while read -r app; do
        [[ -z "$app" || "$app" == \#* ]] && continue
        if flatpak info "$app" >/dev/null 2>&1; then info "Flatpak já instalado: $app"
        else info "Instalando flatpak: $app"; flatpak install -y --noninteractive flathub "$app"; fi
    done < "$REPO/packages/flatpak.txt"
fi

step "SDKMAN (Java, Maven)"
if [[ ! -d "$HOME/.sdkman" ]]; then
    info "Instalando SDKMAN"
    curl -s "https://get.sdkman.io?rcupdate=false" | bash
fi
set +u; source "$HOME/.sdkman/bin/sdkman-init.sh"; set -u
while read -r cand ver; do
    [[ -z "${cand:-}" || "$cand" == \#* ]] && continue
    if [[ -d "$HOME/.sdkman/candidates/$cand/$ver" ]]; then info "SDKMAN: $cand $ver já instalado"
    else info "SDKMAN: instalando $cand $ver"; sdk install "$cand" "$ver" </dev/null || warn "Falhou: $cand $ver"; fi
done < "$REPO/packages/sdkman.txt"

step "Pacotes npm globais"
if command -v npm >/dev/null 2>&1; then
    npm config set prefix "$HOME/.npm-global"
    export PATH="$HOME/.npm-global/bin:$PATH"
    while read -r pkg; do
        [[ -z "$pkg" || "$pkg" == \#* ]] && continue
        if [[ -d "$HOME/.npm-global/lib/node_modules/$pkg" ]]; then info "npm já instalado: $pkg"
        else info "npm install -g $pkg"; npm install -g "$pkg"; fi
    done < "$REPO/packages/npm-global.txt"
fi

step "Extensões do VS Code"
if command -v code >/dev/null 2>&1; then
    installed="$(code --list-extensions 2>/dev/null || true)"
    while read -r ext; do
        [[ -z "$ext" || "$ext" == \#* ]] && continue
        if grep -qix "$ext" <<<"$installed"; then info "VS Code: $ext já instalada"
        else info "VS Code: instalando $ext"; code --install-extension "$ext" --force >/dev/null; fi
    done < "$REPO/packages/vscode-extensions.txt"
fi

info "Programas instalados."
