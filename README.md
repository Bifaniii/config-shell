# config-shell

Meu ambiente de terminal completo: zsh + oh-my-zsh, vim, gnome-terminal, blur-my-shell e tema WhiteSur.
Duas paletas de cores disponíveis: **pastelterm** (feita à mão, padrão) e **Dracula** (opcional, com neovim — mesmas cores do Dracula do VS Code).

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

### Opção 2 — Dracula + neovim

```bash
git clone https://github.com/Bifaniii/config-shell.git ~/config-shell
cd ~/config-shell
./install.sh              # ambiente base (zsh, vim, blur, tema...)
./install-dracula.sh      # neovim + tema Dracula + paleta do terminal igual ao tema
```

O `install-dracula.sh`:

1. instala `neovim`, `ripgrep` e `gcc` (apt)
2. symlink `~/.config/nvim` → `nvim/` deste repo (lazy.nvim + dracula.nvim + treesitter + nvim-tree + telescope)
3. baixa os plugins e compila os parsers do treesitter em modo headless (não precisa abrir o editor)
4. carrega a paleta **Dracula** no gnome-terminal

> Sem o treesitter o neovim usa o realce antigo do vim (regex) e o tema fica quase monocromático.
> Abriu um tipo de arquivo novo? O parser é baixado sozinho (`auto_install`).

#### Atalhos do neovim (`<Space>` é o leader)

| tecla | ação |
|---|---|
| `nvim .` | abre o projeto na pasta atual |
| `Space e` | abre/fecha a árvore de arquivos |
| `Space E` | árvore posicionada no arquivo atual |
| `Space ff` | buscar arquivo por nome |
| `Space fg` | buscar texto no projeto (ripgrep) |
| `Space fb` | buffers abertos |
| `Space fr` | arquivos recentes |
| `Space w` / `Space q` | salvar / fechar |
| `Ctrl h/j/k/l` | pular entre janelas (árvore ↔ editor) |
| `Esc` | limpa o destaque da busca |

Na árvore: `Enter` abre, `a` cria, `d` apaga, `r` renomeia, `H` mostra ocultos, `g?` lista tudo.

### Trocar de paleta depois

```bash
./install-dracula.sh --pastelterm                                     # volta pro pastelterm (nvim continua)
dconf load /org/gnome/terminal/ < gnome/terminal-dracula.dconf        # ou direto no dconf
dconf load /org/gnome/terminal/ < gnome/terminal-pastelterm.dconf
```

Os dois scripts são idempotentes — pode rodar quantas vezes quiser.

## Manter atualizado

- `vim` é alias de `nvim` (no `.zshrc`); o vim clássico continua acessível como `\vim`.
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

### Dracula — `gnome/terminal-dracula.dconf` + `nvim/lua/plugins/dracula.lua` + `.vimrc`

| | normal | bright |
|---|---|---|
| fundo / texto | `#282a36` / `#f8f8f2` | |
| black | `#21222c` | `#6272a4` |
| red | `#ff5555` | `#ff6e6e` |
| green | `#50fa7b` | `#69ff94` |
| yellow | `#f1fa8c` | `#ffffa5` |
| blue | `#bd93f9` | `#d6acff` |
| magenta | `#ff79c6` | `#ff92df` |
| cyan | `#8be9fd` | `#a4ffff` |
| white | `#f8f8f2` | `#ffffff` |

Cursor `#f8f8f2`, seleção `#44475a`/`#f8f8f2`. Paleta oficial do [dracula/gnome-terminal](https://github.com/dracula/gnome-terminal).
No neovim: `Mofiqul/dracula.nvim`; no vim clássico: `dracula/vim` (`g:dracula_colorterm = 0` = fundo transparente).

Ambas: fonte JetBrains Mono 12, `bold-is-bright`.

## Extensões GNOME (instalar via extensions.gnome.org)

Lista em `gnome/shell-extensions.txt`. As que importam pro visual do terminal: `blur-my-shell`, `user-theme`.
