# config-shell

Minha máquina inteira num repositório: programas, dotfiles, ambiente GNOME e temas.
Numa máquina nova (Debian 13 / GNOME), um `git clone` + `./install.sh` reconstrói tudo.

```bash
git clone https://github.com/Bifaniii/config-shell.git ~/config-shell
cd ~/config-shell
./install.sh
```

> Demora bastante e baixa vários GB (Chrome, VS Code, Docker, MySQL, Android Studio, Steam...).
> Pra só restaurar as configurações, sem instalar programas: `./install.sh --no-apps`.

## Flags do install.sh

| flag | efeito |
|---|---|
| `--no-apps` | pula a instalação de programas; instala só o mínimo e restaura as configs |
| `--no-desktop` | pula o ambiente GNOME (tema, wallpaper, atalhos, extensões) |
| `--pastelterm` | usa a paleta **pastelterm** no terminal em vez da **Dracula** |

## Scripts

Cada etapa também roda sozinha:

| script | o que faz |
|---|---|
| `install.sh` | orquestra tudo (chama os quatro abaixo) |
| `install-apps.sh` | apt + repos de terceiros, flatpak, SDKMAN, npm global, extensões do VS Code |
| `install-desktop.sh` | tema WhiteSur, wallpapers, atalhos, dash-to-dock, blur, nautilus, GTK |
| `install-neovim.sh` | Neovim 0.12 (binário oficial em `~/.local`) + kickstart.nvim + jdtls |
| `install-dracula.sh` | paleta Dracula do terminal (`--pastelterm` volta as cores) |
| `backup.sh` | re-exporta pro repo tudo que não é symlink (dconf, listas de pacotes, configs de apps) |

## O que está versionado

```
packages/     apt.txt (curado à mão), apt-repos.sh, flatpak.txt, sdkman.txt,
              npm-global.txt, vscode-extensions.txt
gnome/        terminal-dracula.dconf, terminal-pastelterm.dconf, interface, desktop,
              shell, nautilus, gtk, keybindings-*, shell-extensions.txt
zsh/          .zshrc (oh-my-zsh, plugins, SDKMAN, NVM lazy, PATHs, alias vim=nvim)
vim/          .vimrc + colors/pastelterm.vim
nvim/         kickstart.nvim (init.lua) + ftplugin/java.lua (jdtls) + neo-tree
git/          .gitconfig
vscode/       settings.json
flameshot/    flameshot.ini
wallpapers/   papéis de parede
lib/          common.sh (funções compartilhadas pelos scripts)
```

### Dotfiles são symlinks

`~/.zshrc`, `~/.vimrc`, `~/.vim/colors/pastelterm.vim`, `~/.gitconfig` e `~/.config/nvim`
apontam pra dentro deste repo. Editou? O repo já reflete — só `git commit`.
Arquivos que existiam antes viram `*.bak-<data>`.

### O resto vai pelo backup.sh

dconf, listas de pacotes e configs de apps não dão pra symlinkar. Depois de mexer no sistema:

```bash
./backup.sh          # exporta tudo e mostra o diff
git add -A && git commit -m "update" && git push
```

`packages/apt.txt` é curado à mão — instalou algo novo com `apt`? Adicione lá.

### Se um repositório falhar

Chaves GPG de terceiros rotacionam e expiram. Quando isso acontece, `apt-repos.sh` avisa
quais repositórios falharam e segue com os demais; depois o `install-apps.sh` tenta os
pacotes um a um, então só o que depende do repositório quebrado fica de fora. Pra consertar,
atualize a URL da chave dentro de `packages/apt-repos.sh` e apague o keyring velho
(`/usr/share/keyrings/<nome>.gpg` ou `/etc/apt/keyrings/<nome>`) antes de rodar de novo.

## Programas instalados

**Dev:** git, build-essential, openjdk-21 + Maven (via SDKMAN: Java 21.0.5-tem, Maven 3.9.16),
Node 24 (NodeSource) + Angular CLI, lua/luarocks, sassc, Docker CE + compose, VS Code, IntelliJ IDEA
e Android Studio (flatpak).
**Bancos:** MySQL 8.4 LTS, PostgreSQL, pgAdmin 4, DBeaver (flatpak), sqlitebrowser.
**Apps:** Chrome, Spotify, Discord (flatpak), AnyDesk, Steam, Wine, Flameshot, Extension Manager.
**Terminal:** zsh + oh-my-zsh (robbyrussell, autosuggestions, syntax-highlighting), vim, neovim,
bat, ripgrep, fastfetch, xclip/wl-clipboard.

## Neovim

Config em `nvim/`, baseada no [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
(plugins pelo `vim.pack`, embutido no Neovim 0.12). O neovim do apt é velho demais para ela,
então o `install-neovim.sh` põe o binário oficial em `~/.local/opt/nvim` (link em `~/.local/bin`).
Tema Tokyo Night, telescope, LSP via Mason, autocomplete (blink.cmp), treesitter e neo-tree.
Sem Nerd Font: os ícones foram trocados por texto/Unicode que a JetBrains Mono tem.
`vim` é alias de `nvim`; o vim clássico continua acessível como `\vim`.

**Java:** `nvim/ftplugin/java.lua` sobe o jdtls (instalado pelo Mason) com o JDK mais novo do
SDKMAN (precisa de 21+) e Lombok; os projetos compilam com o Java 17 por padrão.

| tecla | ação |
|---|---|
| `Space sf` / `Space sg` | buscar arquivo / buscar texto no projeto |
| `Space sn` | buscar nos arquivos de config do neovim |
| `Space e` / `\` | árvore de arquivos / árvore no arquivo atual |
| `Ctrl y` | aceitar sugestão do autocomplete |
| `grd` / `grr` / `grn` / `gra` | definição / referências / renomear / code actions |
| `K` | documentação |
| `Space jo` | organizar imports (Java) |
| `Space jv` / `Space jc` / `Space jm` | extrair variável / constante / método (Java) |

Na árvore: `a` cria, `d` apaga, `r` renomeia, `?` lista tudo.

## Paletas do terminal

### Dracula (ativa) — `gnome/terminal-dracula.dconf`

| | normal | bright |
|---|---|---|
| fundo / texto | `#01020b` / `#f8f8f2` | |
| black | `#21222c` | `#6272a4` |
| red | `#ff5555` | `#ff6e6e` |
| green | `#50fa7b` | `#69ff94` |
| yellow | `#f1fa8c` | `#ffffa5` |
| blue | `#bd93f9` | `#d6acff` |
| magenta | `#ff79c6` | `#ff92df` |
| cyan | `#8be9fd` | `#a4ffff` |
| white | `#f8f8f2` | `#ffffff` |

Paleta oficial do [dracula/gnome-terminal](https://github.com/dracula/gnome-terminal), com o fundo
escurecido à mão (`#01020b`) e `bold-color-same-as-fg`. Seleção `#44475a`, cursor `#f8f8f2`.

### pastelterm — `gnome/terminal-pastelterm.dconf` + `vim/colors/pastelterm.vim`

Paleta feita à mão, fundo `#12161a`, texto `#acff9d`. Trocar: `./install-dracula.sh --pastelterm`.

Ambas: JetBrains Mono 12, `bold-is-bright`.

## Ambiente GNOME

Tema **WhiteSur-Dark** (GTK + ícones, clonado do GitHub na instalação), modo escuro, hot corners
desligado, botões da janela à direita, teclado `br`, dash-to-dock embaixo com 90% de altura,
blur-my-shell configurado (hoje desativado), Nautilus em ícones.

**Atalhos:** `Ctrl+Alt+T` terminal · `Print` Flameshot · `Super+D` mostrar área de trabalho.

**Extensões** (lista em `gnome/shell-extensions.txt`) não dá pra instalar por script de forma
confiável — instale pelo extensions.gnome.org ou pelo Extension Manager. A configuração delas
já vem restaurada, então nascem do jeito certo.

## O que NÃO está no repo (de propósito)

Chaves SSH/GPG (`~/.ssh`, `~/.gnupg`), tokens (`gh`, `~/.npmrc`), históricos de shell,
bancos de dados locais, caches e o tema WhiteSur em si (22 MB — é clonado na instalação).
