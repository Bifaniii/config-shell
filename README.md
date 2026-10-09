# config-shell

Minha máquina inteira num repositório: programas, dotfiles, ambiente GNOME e temas.
Numa máquina nova (Debian 13 com GNOME), um `git clone` seguido de `./install.sh` reconstrói tudo.

```bash
git clone https://github.com/Bifaniii/config-shell.git ~/config-shell
cd ~/config-shell
./install.sh
```

> Demora bastante e baixa vários GB (Chrome, VS Code, Docker, MySQL, Steam...).
> Pra só restaurar as configurações, sem instalar programas: `./install.sh --no-apps`.

## Flags do install.sh

| flag | efeito |
|---|---|
| `--no-apps` | pula a instalação de programas; instala só o mínimo e restaura as configs |
| `--no-desktop` | pula o ambiente GNOME (tema, wallpaper, atalhos, extensões) |
| `--no-plasma` | não instala o KDE Plasma |
| `--pastelterm` | usa a paleta pastelterm no gnome-terminal em vez da Dracula |

## Scripts

Cada etapa também roda sozinha:

| script | o que faz |
|---|---|
| `install.sh` | orquestra tudo (chama os de baixo) |
| `install-apps.sh` | apt + repos de terceiros, flatpak, SDKMAN, npm global, extensões do VS Code |
| `install-desktop.sh` | tema WhiteSur, wallpapers, atalhos, dash-to-dock, blur, nautilus, GTK |
| `install-neovim.sh` | Neovim 0.12 (binário oficial em `~/.local`) + kickstart.nvim + LSPs de Java e web |
| `install-kitty.sh` | terminal kitty (binário oficial em `~/.local`), config de `kitty/`, vira o terminal padrão |
| `install-plasma.sh` | KDE Plasma 6 ao lado do GNOME, cursores WhiteSur |
| `plasma/aplicar.sh` | aplica a personalização do Plasma; roda dentro de uma sessão Plasma |
| `gdm/fundo-login.sh` | papel de parede no fundo da tela de login (GDM) e foto da conta |
| `install-dracula.sh` | paleta Dracula do gnome-terminal (`--pastelterm` volta as cores) |
| `backup.sh` | re-exporta pro repo tudo que não é symlink (dconf, listas de pacotes, configs de apps) |
| `install-neovim.ps1` | só o Neovim, no Windows (veja [Neovim no Windows](#neovim-no-windows)) |

## O que está versionado

```
packages/     apt.txt (curado à mão), apt-repos.sh, flatpak.txt, sdkman.txt,
              npm-global.txt, vscode-extensions.txt
gnome/        terminal-dracula.dconf, terminal-pastelterm.dconf, interface, desktop,
              shell, nautilus, gtk, keybindings-*, shell-extensions.txt
zsh/          .zshrc (oh-my-zsh, plugins, SDKMAN, NVM lazy, PATHs, alias vim=nvim, cr)
              .zshenv (tela de boas-vindas do kitty)
vim/          .vimrc + colors/pastelterm.vim
nvim/         kickstart.nvim (init.lua) + ftplugin/java.lua (jdtls) + neo-tree
kitty/        kitty.conf, terminal.sh (Ctrl+Alt+T), copiar_ou_colar.py, boas-vindas.jsonc + imagens
plasma/       aplicar.sh, layout.js (painéis), BreezePreto.colors,
              plasmoids/ (Atividades, Launchpad), aurorae/ (botões macOS), super-gnome/
gdm/          fundo-login.sh
git/          .gitconfig
vscode/       settings.json
flameshot/    flameshot.ini
wallpapers/   papéis de parede
lib/          common.sh (funções compartilhadas pelos scripts)
```

### Dotfiles são symlinks

`~/.zshrc`, `~/.zshenv`, `~/.vimrc`, `~/.vim/colors/pastelterm.vim`, `~/.gitconfig`,
`~/.config/nvim` e `~/.config/kitty`
apontam pra dentro deste repo. Se editar um deles, a mudança já está no repo e só falta o `git commit`.
Arquivos que existiam antes viram `*.bak-<data>`.

Nome e e-mail do git ficam fora do repo, em `~/.gitconfig.local`, que o `.gitconfig` inclui.
Numa máquina nova, crie esse arquivo antes do primeiro commit:

```bash
git config --file ~/.gitconfig.local user.name  "Seu Nome"
git config --file ~/.gitconfig.local user.email "voce@exemplo.com"
```

Não use `git config --global` pra isso: ele grava no `~/.gitconfig`, que é o arquivo do repo.

### O resto vai pelo backup.sh

dconf, listas de pacotes e configs de apps não dão pra symlinkar. Depois de mexer no sistema:

```bash
./backup.sh          # exporta tudo e mostra o diff
git add -A && git commit -m "update" && git push
```

O `packages/apt.txt` é curado à mão. Se instalar algo novo com `apt`, adicione lá.
O `sdkman.txt` lista todas as versões instaladas de cada candidato e marca com `default`
a que fica como padrão.

### Se um repositório falhar

Chaves GPG de terceiros rotacionam e expiram. Quando isso acontece, `apt-repos.sh` avisa
quais repositórios falharam e segue com os demais; depois o `install-apps.sh` tenta os
pacotes um a um, então só o que depende do repositório quebrado fica de fora. Pra consertar,
atualize a URL da chave dentro de `packages/apt-repos.sh` e apague o keyring velho
(`/usr/share/keyrings/<nome>.gpg` ou `/etc/apt/keyrings/<nome>`) antes de rodar de novo.

## Programas instalados

Dev: git, build-essential, openjdk-21, SDKMAN (Java 17.0.20-tem como padrão e 21.0.5-tem,
Maven 3.9.16, Spring Boot CLI 4.1.0), Node 24 (NodeSource) + Angular CLI, lua/luarocks, sassc,
Docker CE + compose, VS Code e IntelliJ IDEA (flatpak).

Bancos: MySQL 8.4 LTS, PostgreSQL, pgAdmin 4, DBeaver (flatpak), sqlitebrowser.

Apps: Chrome, Spotify, Discord (flatpak), AnyDesk, Steam, Wine, Flameshot, Extension Manager.

Terminal: zsh + oh-my-zsh (robbyrussell, autosuggestions, syntax-highlighting), vim, neovim,
bat, ripgrep, fastfetch, xclip/wl-clipboard.

O `.zshrc` tem o alias `springnew`, que roda `spring init` já com Maven e Java 17:
`springnew -g=com.exemplo -a=minha-api -d=web,lombok minha-api`.

## Neovim

A config em `nvim/` é baseada no [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim),
que instala os plugins pelo `vim.pack`, embutido no Neovim 0.12. O neovim do apt é velho demais
pra ela, então o `install-neovim.sh` põe o binário oficial em `~/.local/opt/nvim`, com link em
`~/.local/bin`. Vem com tema Dracula (fundo `#01020B`, igual ao do terminal), telescope,
LSP via Mason, autocomplete (blink.cmp), treesitter e neo-tree. Os ícones usam texto e Unicode que a JetBrains Mono já tem, sem Nerd Font.
`vim` é alias de `nvim`; o vim clássico continua acessível como `\vim`.

Pra Java, o `nvim/ftplugin/java.lua` sobe o jdtls (instalado pelo Mason) com Lombok, usando o JDK
mais novo do SDKMAN, porque o jdtls precisa de Java 21 ou mais. Os projetos compilam com o Java 17
por padrão.

Pra web e Angular, o Mason instala os servidores de TypeScript/JavaScript (`ts_ls`), Angular
(`angularls`), HTML, CSS/SCSS e Emmet. O autocomplete faz o import sozinho ao aceitar a sugestão,
o Emmet expande abreviações como `div.card>ul>li*3` e o nvim-ts-autotag fecha as tags
(`<div>` ganha o `</div>`). O `angularls` usa o `@angular/core` do `node_modules` do projeto,
então rode `npm install` antes de abrir. A indentação segue o `.editorconfig` do projeto
(2 espaços num projeto Angular).

Pra Python, o basedpyright dá o autocomplete com import automático (da biblioteca padrão, das
bibliotecas instaladas e dos arquivos do próprio projeto: aceitar `Path` já escreve
`from pathlib import Path`) e o ruff aponta erros e problemas de estilo. Se o projeto tiver `.venv`
ou `venv`, o basedpyright usa o Python dele e enxerga as bibliotecas instaladas ali.

| tecla | ação |
|---|---|
| `Space sf` / `Space sg` | buscar arquivo / buscar texto no projeto |
| `Space sn` | buscar nos arquivos de config do neovim |
| `Space e` / `\` | árvore de arquivos / árvore no arquivo atual |
| `Enter` | aceitar sugestão do autocomplete (no Java, já faz o import) |
| `grd` / `grr` / `grn` / `gra` | definição / referências / renomear / code actions |
| `K` | documentação |
| `Space jo` | organizar imports (Java) |
| `Space jv` / `Space jc` / `Space jm` | extrair variável / constante / método (Java) |

Na árvore: `a` cria, `d` apaga, `r` renomeia, `?` lista tudo.

### Neovim no Windows

A mesma config roda no Windows 10/11. Num PowerShell comum (não precisa de administrador,
o winget pede permissão quando precisa):

```powershell
irm https://raw.githubusercontent.com/Bifaniii/config-shell/master/install-neovim.ps1 | iex
```

O script clona o repo em `~\config-shell` (ou dá `git pull` se já existir) e instala pelo winget
o que faltar: Git, Neovim 0.12+, ripgrep, Node LTS, JDK 17 e 21 (Temurin) e o Build Tools do
Visual Studio, que é o compilador C dos parsers do treesitter e o passo mais demorado.
Depois liga `%LOCALAPPDATA%\nvim` à pasta `nvim\` do repo com uma junction e instala plugins,
parsers e servidores de linguagem. Pode rodar de novo quando quiser: ele pula o que já existe.

No Windows não tem SDKMAN: o `ftplugin/java.lua` procura os JDKs em
`C:\Program Files\Eclipse Adoptium` e sobe o jdtls direto pelo launcher do Eclipse, sem Python.
Pra atualizar a config depois, é só `git -C ~\config-shell pull`.

## Terminal kitty

O kitty é o terminal padrão (`Ctrl + Alt + T`, dock, "abrir terminal aqui"). A config fica em
`kitty/`: JetBrains Mono 12, fundo preto puro e paleta forte preto/vermelho. `F11` alterna tela cheia.
Com o kitty já aberto, `Ctrl + Alt + T` abre uma aba nova nele em vez de outra janela (`kitty/terminal.sh`,
pelo controle remoto do kitty).
Ao abrir, o `~/.zshenv` mostra uma tela de boas-vindas (fastfetch com o logo do Debian).

| tecla | ação |
|---|---|
| `Alt + V` / `Alt + H` | novo split ao lado / embaixo (na mesma pasta) |
| `Ctrl + Shift + Enter` | novo split no lado com mais espaço |
| `Alt + setas` | pula entre os splits |
| `Ctrl + Shift + R` | redimensiona o split (setas, `Esc` sai) |
| `Ctrl + Shift + Z` | zoom no split atual |
| `Ctrl + Alt + T` / `Ctrl + Shift + T` | nova aba |
| `Ctrl + PgUp` / `Ctrl + PgDn` | aba anterior / próxima |
| `Ctrl + C` | copia, se houver texto selecionado (senão interrompe, como sempre) |
| botão direito | copia a seleção; sem seleção, cola |
| `F11` | tela cheia |

## KDE Plasma

Instalado ao lado do GNOME: na tela de login, a engrenagem escolhe "Plasma (Wayland)" ou "GNOME".
Depois do primeiro login no Plasma, rode `~/config-shell/plasma/aplicar.sh`, que monta tudo:

- Breeze Dark com o esquema "Breeze Preto" (fundos pretos) e destaque vermelho `#e60000`, ícones
  WhiteSur-dark, cursor WhiteSur e botões de janela do macOS à esquerda, com a barra quase preta.
- Barra em cima e dock embaixo, as duas escondidas até o mouse encostar na borda. A barra tem o botão
  Atividades, relógio, CPU/memória e a bandeja com a % da bateria. A dock começa pelo Launchpad.
- Nada abre ao encostar o mouse nos cantos. Área de trabalho sem ícones (os arquivos continuam na pasta).
- Teclado ABNT2 e rolagem natural no touchpad, como no GNOME.

| tecla | ação |
|---|---|
| Super (1 toque) | Visão geral: janelas abertas em miniatura |
| Super (2 toques), `Meta + A`, `Alt + F1` | Launchpad: todos os apps em grade |
| `Ctrl + Space` | busca (KRunner), no centro da tela como o Spotlight |
| `Ctrl + Alt + T` | kitty |
| `Print` | Flameshot |

O Launchpad é o [Launchpad plasma 6](https://store.kde.org/p/2174238) da KDE Store, com dois ajustes
locais (a busca cabia fora da tela em monitores de 768 px e ficava invisível no tema preto). O botão
Atividades e a tecla Super são daqui (`plasma/plasmoids/guilherme.atividades`, `plasma/super-gnome/`).
GNOME e Plasma dividem as configurações GTK; o `plasma/tema-gtk-da-sessao`, chamado no login de cada
sessão, reaplica o tema certo de cada uma. Por isso o `backup.sh` não exporta `interface.dconf` nem
`desktop.dconf` quando roda no Plasma.

## Tela de login

É o GDM com o tema WhiteSur (instalado pelo `install-desktop.sh` com `tweaks.sh -g`). O
`gdm/fundo-login.sh` troca o fundo pelo papel de parede do Debian e põe a foto da conta a partir de
`~/Imagens/itachi.jpg`, que fica fora do repo. Rode de novo se o tema do GDM for reinstalado.

## Paletas do terminal

### Dracula (ativa), em `gnome/terminal-dracula.dconf`

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

### pastelterm, em `gnome/terminal-pastelterm.dconf` + `vim/colors/pastelterm.vim`

Paleta feita à mão, fundo `#12161a`, texto `#acff9d`. Pra trocar: `./install-dracula.sh --pastelterm`.

As duas usam JetBrains Mono 12 e `bold-is-bright`.

## Ambiente GNOME

Tema WhiteSur-Dark (GTK + ícones, clonado do GitHub na instalação), modo escuro, hot corners
desligado, botões da janela à direita, teclado `br`, dash-to-dock embaixo com 90% de altura,
blur-my-shell configurado (hoje desativado), Nautilus em ícones.

Atalhos: `Ctrl+Alt+T` abre o terminal, `Print` abre o Flameshot e `Super+D` mostra a área de trabalho.

As extensões (lista em `gnome/shell-extensions.txt`) não dá pra instalar por script de forma
confiável. Instale pelo extensions.gnome.org ou pelo Extension Manager; a configuração delas
já vem restaurada, então elas nascem do jeito certo.

## O que fica fora do repo (de propósito)

Chaves SSH/GPG (`~/.ssh`, `~/.gnupg`), tokens (`gh`, `~/.npmrc`), nome e e-mail do git
(`~/.gitconfig.local`), históricos de shell, bancos de dados locais, caches e o tema WhiteSur
em si (22 MB, clonado na instalação). O `backup.sh` também deixa de fora os dispositivos
Bluetooth e as localizações do clima e do relógio mundial que o GNOME guarda.
