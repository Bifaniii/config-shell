# config-shell

Meu ambiente de terminal completo: zsh + oh-my-zsh, vim, gnome-terminal, blur-my-shell e tema WhiteSur.
Duas paletas de cores disponíveis: **pastelterm** (feita à mão, padrão) e **Tokyo Night** (opcional, com neovim).

## Instalar

### Opção 1 — pastelterm (padrão)

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
5. carrega no dconf: gnome-terminal com paleta **pastelterm**, blur-my-shell, tema GTK/ícones (instala WhiteSur se faltar)
6. define zsh como shell padrão

### Opção 2 — Tokyo Night + neovim

```bash
git clone https://github.com/Bifaniii/config-shell.git ~/config-shell
cd ~/config-shell
./install.sh              # ambiente base (zsh, vim, blur, tema...)
./install-tokyonight.sh   # neovim + tema Tokyo Night + paleta do terminal igual ao tema
```

O `install-tokyonight.sh`:

1. instala `neovim` (apt)
2. symlink `~/.config/nvim` → `nvim/` deste repo (lazy.nvim + `folke/tokyonight.nvim`, estilo `night`, fundo transparente)
3. baixa os plugins em modo headless (não precisa abrir o editor)
4. carrega a paleta **Tokyo Night** no gnome-terminal

### Trocar de paleta depois

```bash
./install-tokyonight.sh --pastelterm                                  # volta pro pastelterm (nvim continua)
dconf load /org/gnome/terminal/ < gnome/terminal-tokyonight.dconf     # ou direto no dconf
dconf load /org/gnome/terminal/ < gnome/terminal-pastelterm.dconf
```

Os dois scripts são idempotentes — pode rodar quantas vezes quiser.

## Manter atualizado

- `.zshrc`, `.vimrc`, `pastelterm.vim`, `.gitconfig`, `nvim/` são symlinks: edite normalmente e `git commit`.
- Cores/fonte do gnome-terminal, blur e tema GTK vivem no dconf e não dá pra symlinkar:
  depois de mexer, rode `./backup.sh` (ele detecta qual paleta está ativa e exporta pro arquivo certo) e faça commit.

## Paletas

### pastelterm — `gnome/terminal-pastelterm.dconf` + `vim/colors/pastelterm.vim`

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

Cursor `#acff9d`, seleção `#2f3d35`/`#f2f4f7`. O `pastelterm.vim` usa fundo `NONE` pra deixar o blur aparecer.

### Tokyo Night (night) — `gnome/terminal-tokyonight.dconf` + `nvim/lua/plugins/tokyonight.lua`

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

Cursor `#c0caf5`, seleção `#283457`/`#c0caf5`. Gerada dos extras oficiais do plugin
(`extras/gnome_terminal/` + tons bright de `extras/kitty/`). Pra trocar o estilo (`storm`/`moon`/`day`),
mude `style` no lua e regere o dconf a partir de `~/.local/share/nvim/lazy/tokyonight.nvim/extras/`.

Ambas: fonte JetBrains Mono 12, `bold-is-bright`.

## Extensões GNOME (instalar via extensions.gnome.org)

Lista em `gnome/shell-extensions.txt`. As que importam pro visual do terminal: `blur-my-shell`, `user-theme`.
