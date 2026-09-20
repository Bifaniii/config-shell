# config-shell

Meu ambiente de terminal completo: zsh + oh-my-zsh, neovim com **Tokyo Night**, gnome-terminal
na mesma paleta, vim clássico, blur-my-shell e tema WhiteSur.

## Restaurar em uma máquina nova

```bash
git clone https://github.com/Bifaniii/config-shell.git ~/config-shell
cd ~/config-shell
./install.sh
```

O `install.sh`:

1. instala `zsh vim neovim git curl fonts-jetbrains-mono dconf-cli` (apt)
2. instala oh-my-zsh + plugins `zsh-autosuggestions` e `zsh-syntax-highlighting`
3. clona os temas dracula e monokai do vim
4. cria **symlinks** `~/.zshrc`, `~/.vimrc`, `~/.vim/colors/pastelterm.vim`, `~/.gitconfig`, `~/.config/nvim` → este repo
   (arquivos existentes viram `*.bak-<data>`)
5. baixa lazy.nvim + tokyonight em modo headless (`nvim --headless "+Lazy! sync"`)
6. carrega no dconf: perfil do gnome-terminal, blur-my-shell, tema GTK/ícones (instala WhiteSur se faltar)
7. define zsh como shell padrão

Pode rodar quantas vezes quiser — é idempotente.

## Manter atualizado

- `.zshrc`, `.vimrc`, `pastelterm.vim`, `.gitconfig`, `nvim/` são symlinks: edite normalmente e `git commit`.
- Cores/fonte do gnome-terminal, blur e tema GTK vivem no dconf e não dá pra symlinkar:
  depois de mexer, rode `./backup.sh` e faça commit.

## Neovim

Config em `nvim/` (lazy.nvim). Tema em `nvim/lua/plugins/tokyonight.lua`, estilo `night`, fundo transparente
(deixa o blur do terminal aparecer). Pra trocar o estilo: mude `style` (`night`/`storm`/`moon`/`day`) e
regere a paleta do terminal com o extra oficial do plugin:

```
~/.local/share/nvim/lazy/tokyonight.nvim/extras/gnome_terminal/tokyonight_<estilo>.dconf   # normal
~/.local/share/nvim/lazy/tokyonight.nvim/extras/kitty/tokyonight_<estilo>.conf             # bright + seleção
```

## Paleta Tokyo Night (night) — gnome-terminal

| | normal | bright |
|---|---|---|
| fundo / texto | `#1a1b26` / `#c0caf5` | |
| black | `#15161e` | `#414868` |
| red | `#f7768e` | `#ff899d` |
| green | `#9ece6a` | `#9fe044` |
| yellow | `#e0af68` | `#faba4a` |
| blue | `#7aa2f7` | `#8db0ff` |
| magenta | `#bb9af7` | `#c7a9ff` |
| cyan | `#7dcfff` | `#a4daff` |
| white | `#a9b1d6` | `#c0caf5` |

Cursor `#c0caf5`, seleção `#283457`/`#c0caf5`, fonte JetBrains Mono 12, bold-is-bright.

A paleta anterior (**pastelterm**, feita à mão) está preservada em `gnome/terminal-pastelterm.dconf`
e em `vim/colors/pastelterm.vim` (ainda usada pelo vim clássico). Pra voltar:
`dconf load /org/gnome/terminal/ < gnome/terminal-pastelterm.dconf`.

## Extensões GNOME (instalar via extensions.gnome.org)

Lista em `gnome/shell-extensions.txt`. As que importam pro visual do terminal: `blur-my-shell`, `user-theme`.
