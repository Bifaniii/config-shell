#!/usr/bin/env bash
# backup.sh — re-exporta pro repo tudo que NÃO é symlink: dconf do GNOME, listas de
# pacotes, extensões do VS Code e configs de apps. Rode depois de mexer no sistema
# e faça commit. Os dotfiles (.zshrc, .vimrc, nvim/...) são symlinks e já estão no repo.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REPO/lib/common.sh"

if has_gui; then
    step "GNOME (dconf)"
    case "$(dconf read /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/background-color)" in
        "'#12161a'") palette=pastelterm ;;
        "'#01020b'"|"'#282a36'") palette=dracula ;;
        *) warn "Fundo do terminal não bate com nenhuma paleta conhecida; salvando em terminal-custom.dconf"; palette=custom ;;
    esac
    info "Paleta ativa: $palette"
    dconf dump /org/gnome/terminal/ > "$REPO/gnome/terminal-$palette.dconf"

    dconf dump /org/gnome/desktop/interface/                  > "$REPO/gnome/interface.dconf"
    dconf dump /org/gnome/settings-daemon/plugins/media-keys/ > "$REPO/gnome/keybindings-media.dconf"
    dconf dump /org/gnome/desktop/wm/keybindings/             > "$REPO/gnome/keybindings-wm.dconf"
    dconf dump /org/gnome/nautilus/                           > "$REPO/gnome/nautilus.dconf"
    dconf dump /org/gnome/shell/ \
        | grep -vE '^(app-picker-layout|welcome-dialog|command-history|had-bluetooth|looking-glass)' \
        > "$REPO/gnome/shell.dconf"
    {
        for sec in wm/preferences peripherals input-sources screensaver background; do
            echo "[${sec}]"
            dconf dump "/org/gnome/desktop/${sec}/" | tail -n +2
        done
    } > "$REPO/gnome/desktop.dconf"
    {
        dconf dump /org/gtk/settings/ | grep -vE 'window-position|window-size|custom-colors|selected-color'
        dconf dump /org/gtk/gtk4/settings/
    } > "$REPO/gnome/gtk.dconf"
    # todas as instaladas (ativas ou não); quais ficam ativas vem do shell.dconf
    { ls "$HOME/.local/share/gnome-shell/extensions" 2>/dev/null
      ls /usr/share/gnome-shell/extensions 2>/dev/null; } | sort -u > "$REPO/gnome/shell-extensions.txt"
    info "dconf exportado"

    step "Configs de apps"
    [[ -f "$HOME/.config/flameshot/flameshot.ini" ]] && cp "$HOME/.config/flameshot/flameshot.ini" "$REPO/flameshot/"
    [[ -f "$HOME/.config/Code/User/settings.json" ]] && cp "$HOME/.config/Code/User/settings.json" "$REPO/vscode/"
    info "flameshot e VS Code"
else
    warn "Sem sessão GNOME: pulando dconf"
fi

step "Listas de pacotes"
if command -v flatpak >/dev/null 2>&1; then
    flatpak list --app --columns=application > "$REPO/packages/flatpak.txt"
    info "flatpak.txt ($(wc -l < "$REPO/packages/flatpak.txt") apps)"
fi
if command -v code >/dev/null 2>&1; then
    code --list-extensions > "$REPO/packages/vscode-extensions.txt" 2>/dev/null
    info "vscode-extensions.txt ($(wc -l < "$REPO/packages/vscode-extensions.txt") extensões)"
fi
if [[ -d "$HOME/.sdkman/candidates" ]]; then
    {
        echo "# candidato versão"
        for c in "$HOME"/.sdkman/candidates/*/; do
            n="$(basename "$c")"
            v="$(readlink "$c/current" 2>/dev/null | xargs -r basename)"
            [[ -n "$v" ]] && echo "$n $v"
        done
    } > "$REPO/packages/sdkman.txt"
    info "sdkman.txt"
fi
if [[ -d "$HOME/.npm-global/lib/node_modules" ]]; then
    find "$HOME/.npm-global/lib/node_modules" -maxdepth 2 -name package.json -not -path '*/node_modules/*/node_modules/*' \
        -exec sh -c 'grep -m1 "\"name\"" "$1" | sed "s/.*: *\"//;s/\".*//"' _ {} \; 2>/dev/null \
        | sort -u > "$REPO/packages/npm-global.txt"
    info "npm-global.txt"
fi

warn "packages/apt.txt é curado à mão (não sobrescrito). Instalou algo novo com apt? Adicione lá."
echo
cd "$REPO"
if git diff --quiet && [[ -z "$(git status --porcelain)" ]]; then
    info "Nada mudou desde o último commit."
else
    git --no-pager diff --stat
    git status --porcelain
    echo
    info "Pra salvar:  cd $REPO && git add -A && git commit -m 'update' && git push"
fi
