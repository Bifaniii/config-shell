#!/usr/bin/env bash
# install-dracula.sh — paleta Dracula no gnome-terminal (as mesmas cores do Dracula do VS Code).
# Chamado pelo install.sh; roda sozinho também. O neovim fica no install-neovim.sh.
#
# Voltar pra paleta pastelterm:  ./install-dracula.sh --pastelterm

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REPO/lib/common.sh"

if [[ "${1:-}" == "--pastelterm" ]]; then
    load_palette pastelterm
    info "Pronto. Abra um terminal novo."
    exit 0
fi

# ---------- paleta do terminal ----------
load_palette dracula

info "Pronto. Abra um terminal novo."
