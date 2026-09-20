# config-shell

Meu ambiente de terminal completo: zsh + oh-my-zsh, vim, gnome-terminal com paleta
**pastelterm** (feita à mão), blur-my-shell e tema WhiteSur.

## Restaurar em uma máquina nova

```bash
git clone https://github.com/Bifaniii/config-shell.git ~/config-shell
cd ~/config-shell
./install.sh
```

O `install.sh`:

1. instala `zsh vim git curl fonts-jetbrains-mono dconf-cli` (apt)
2. instala oh-my-zsh + plugins `zsh-autosuggestions` e `zsh-syntax-highlighting`
3. clona os temas dracula e monokai do vim
4. cria **symlinks** `~/.zshrc`, `~/.vimrc`, `~/.vim/colors/pastelterm.vim`, `~/.gitconfig` → este repo
   (arquivos existentes viram `*.bak-<data>`)
5. carrega no dconf: perfil do gnome-terminal, blur-my-shell, tema GTK/ícones (instala WhiteSur se faltar)
6. define zsh como shell padrão

Pode rodar quantas vezes quiser — é idempotente.

## Manter atualizado

- `.zshrc`, `.vimrc`, `pastelterm.vim`, `.gitconfig` são symlinks: edite normalmente e `git commit`.
- Cores/fonte do gnome-terminal, blur e tema GTK vivem no dconf e não dá pra symlinkar:
  depois de mexer, rode `./backup.sh` e faça commit.

## Paleta pastelterm

| | normal | bright |
|---|---|---|
| fundo / texto | `#12161a` / `#acff9d` | |
| black | `#1b1f24` | `#5c6370` |
| red | `#e63939` | `#ff2e2e` |
| green | `#9ece8a` | `#acff9d` |
| yellow | `#e6c384` | `#ffd166` |
| blue | `#4f86f0` | `#6ea0ff` |
| magenta | `#b07be0` | `#c98cf5` |
| cyan | `#86d3d3` | `#9be6e6` |
| white | `#d0d3d9` | `#f2f4f7` |

Cursor `#acff9d`, seleção `#2f3d35`/`#f2f4f7`, fonte JetBrains Mono 12, bold-is-bright.
A mesma paleta está em `vim/colors/pastelterm.vim` (fundo `NONE` pra deixar o blur do terminal aparecer).

## Extensões GNOME (instalar via extensions.gnome.org)

Lista em `gnome/shell-extensions.txt`. As que importam pro visual do terminal: `blur-my-shell`, `user-theme`.
