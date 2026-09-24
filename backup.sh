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
    # device-list (MAC dos fones Bluetooth) e locations (clima/relógios) são pessoais: ficam de fora
    dconf dump /org/gnome/shell/ \
        | grep -vE '^(app-picker-layout|welcome-dialog|command-history|had-bluetooth|looking-glass|device-list|locations)=' \
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
    { ls "$HOME/.local/share/gnome-shell/extensions" 2>/dev/null || true
      ls /usr/share/gnome-shell/extensions 2>/dev/null || true; } | sort -u > "$REPO/gnome/shell-extensions.txt"
    info "dconf exportado"

    step "Configs de apps"
    if [[ -f "$HOME/.config/flameshot/flameshot.ini" ]]; then
        cp "$HOME/.config/flameshot/flameshot.ini" "$REPO/flameshot/"; info "flameshot.ini"
    fi
    if [[ -f "$HOME/.config/Code/User/settings.json" ]]; then
        cp "$HOME/.config/Code/User/settings.json" "$REPO/vscode/"; info "VS Code settings.json"
    fi
else
    warn "Sem sessão GNOME: pulando dconf"
fi

step "Listas de pacotes"
if command -v flatpak >/dev/null 2>&1; then
    flatpak list --app --columns=application > "$REPO/packages/flatpak.txt"
    info "flatpak.txt ($(wc -l < "$REPO/packages/flatpak.txt") apps)"
fi
if command -v code >/dev/null 2>&1; then
    code --list-extensions > "$REPO/packages/vscode-extensions.txt" 2>/dev/null || true
    info "vscode-extensions.txt ($(wc -l < "$REPO/packages/vscode-extensions.txt") extensões)"
fi
if [[ -d "$HOME/.sdkman/candidates" ]]; then
    {
        echo "# candidato versão [default]  (todas as versões instaladas; 'default' marca a current)"
        for c in "$HOME"/.sdkman/candidates/*/; do
            n="$(basename "$c")"
            cur="$(readlink "$c/current" 2>/dev/null | xargs -r basename)"
            for v in "$c"*/; do
                v="$(basename "$v")"
                [[ "$v" == current ]] && continue
                if [[ "$v" == "$cur" ]]; then echo "$n $v default"; else echo "$n $v"; fi
            done
        done
    } > "$REPO/packages/sdkman.txt"
    info "sdkman.txt"
fi
NPM_ROOT="$HOME/.npm-global/lib/node_modules"
if [[ -d "$NPM_ROOT" ]]; then
    # pacotes com escopo (@angular/cli) ficam um nível mais fundo que os normais
    for d in "$NPM_ROOT"/*/; do
        n="$(basename "$d")"
        case "$n" in
            npm) ;;                                   # o próprio npm não conta
            @*) for sub in "$d"*/; do echo "$n/$(basename "$sub")"; done ;;
            *) echo "$n" ;;
        esac
    done | sort -u > "$REPO/packages/npm-global.txt"
    info "npm-global.txt ($(wc -l < "$REPO/packages/npm-global.txt") pacotes)"
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
