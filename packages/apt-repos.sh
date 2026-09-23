#!/usr/bin/env bash
# Adiciona os repositórios de terceiros usados pelos pacotes de packages/apt.txt.
# Chamado pelo install.sh; pode ser rodado sozinho. Idempotente.
set -euo pipefail

info() { printf '\033[1;32m==>\033[0m %s\n' "$*"; }

# gpg e curl são usados abaixo; numa instalação mínima podem não existir
for dep in gpg curl; do
    if ! command -v "$dep" >/dev/null 2>&1; then
        info "Instalando dependência: $dep"
        sudo apt-get update -qq
        sudo apt-get install -y -qq "$([[ $dep == gpg ]] && echo gnupg || echo curl)"
    fi
done

REPO_KEYS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/keys"
KEYRINGS=/etc/apt/keyrings
SOURCES=/etc/apt/sources.list.d
sudo install -d -m 0755 "$KEYRINGS"
ARCH="$(dpkg --print-architecture)"

# Algumas chaves publicadas pelos fornecedores não passam no validador do apt do
# Debian 13 (sqv). Quando temos uma cópia boa em packages/keys/, ela tem prioridade.
# key_local <nome-em-packages/keys> <arquivo-destino>
key_local() {
    [[ -f "$2" ]] && return 0
    [[ -f "$REPO_KEYS/$1" ]] || return 1
    sudo cp "$REPO_KEYS/$1" "$2"
    sudo chmod a+r "$2"
}

# key_from <url> <arquivo-destino>
# Chaves .asc vão como vieram. Para .gpg, importamos num keyring temporário e
# reexportamos: alguns fornecedores publicam a mesma chave duas vezes (uma versão
# antiga já expirada e a renovada), e o `sqv` do apt valida pela primeira que
# encontra. A importação mescla as duas e mantém a validade estendida.
key_from() {
    [[ -f "$2" ]] && return 0
    local tmp; tmp="$(mktemp -d)"
    if ! curl -fsSL "$1" -o "$tmp/key"; then
        warn "Falhou ao baixar a chave: $1"
        rm -rf "$tmp"; return 1
    fi
    if [[ "$2" == *.asc ]]; then
        sudo cp "$tmp/key" "$2"
    else
        gpg --quiet --no-default-keyring --keyring "$tmp/ring.gpg" --import "$tmp/key" 2>/dev/null
        gpg --quiet --no-default-keyring --keyring "$tmp/ring.gpg" --export > "$tmp/out.gpg"
        sudo cp "$tmp/out.gpg" "$2"
    fi
    sudo chmod a+r "$2"
    rm -rf "$tmp"
}

# Docker
if [[ ! -f $SOURCES/docker.list ]]; then
    info "Repositório: Docker"
    key_from https://download.docker.com/linux/debian/gpg "$KEYRINGS/docker.asc"
    echo "deb [arch=$ARCH signed-by=$KEYRINGS/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
        | sudo tee $SOURCES/docker.list >/dev/null
fi

# VS Code
if [[ ! -f $SOURCES/vscode.sources ]]; then
    info "Repositório: VS Code"
    key_from https://packages.microsoft.com/keys/microsoft.asc /usr/share/keyrings/microsoft.gpg
    sudo tee $SOURCES/vscode.sources >/dev/null <<EOF
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: $ARCH
Signed-By: /usr/share/keyrings/microsoft.gpg
EOF
fi

# Google Chrome
if [[ ! -f $SOURCES/google-chrome.sources ]]; then
    info "Repositório: Google Chrome"
    key_from https://dl.google.com/linux/linux_signing_key.pub /usr/share/keyrings/google-chrome.gpg
    sudo tee $SOURCES/google-chrome.sources >/dev/null <<EOF
X-Repolib-Name: Google Chrome
Types: deb
URIs: https://dl.google.com/linux/chrome-stable/deb/
Suites: stable
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/google-chrome.gpg
EOF
fi

# Node.js 24 (NodeSource)
if [[ ! -f $SOURCES/nodesource.sources ]]; then
    info "Repositório: NodeSource (Node 24)"
    key_from https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key /usr/share/keyrings/nodesource.gpg
    sudo tee $SOURCES/nodesource.sources >/dev/null <<EOF
Types: deb
URIs: https://deb.nodesource.com/node_24.x
Suites: nodistro
Components: main
Architectures: $ARCH
Signed-By: /usr/share/keyrings/nodesource.gpg
EOF
fi

# Spotify
if [[ ! -f $SOURCES/spotify.list ]]; then
    info "Repositório: Spotify"
    key_from https://download.spotify.com/debian/pubkey_5384CE82BA52C83A.gpg /usr/share/keyrings/spotify.gpg
    echo "deb [signed-by=/usr/share/keyrings/spotify.gpg] https://repository.spotify.com stable non-free" \
        | sudo tee $SOURCES/spotify.list >/dev/null
fi

# AnyDesk
if [[ ! -f $SOURCES/anydesk-stable.list ]]; then
    info "Repositório: AnyDesk"
    key_from https://keys.anydesk.com/repos/DEB-GPG-KEY "$KEYRINGS/keys.anydesk.com.asc"
    echo "deb [signed-by=$KEYRINGS/keys.anydesk.com.asc] https://deb.anydesk.com all main" \
        | sudo tee $SOURCES/anydesk-stable.list >/dev/null
fi

# pgAdmin 4
if [[ ! -f $SOURCES/pgadmin4.list ]]; then
    info "Repositório: pgAdmin 4"
    key_from https://www.pgadmin.org/static/packages_pgadmin_org.pub /usr/share/keyrings/packages-pgadmin-org.gpg
    echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(. /etc/os-release && echo "$VERSION_CODENAME") pgadmin4 main" \
        | sudo tee $SOURCES/pgadmin4.list >/dev/null
fi

# MySQL 8.4 LTS
if [[ ! -f $SOURCES/mysql.list ]]; then
    info "Repositório: MySQL 8.4 LTS"
    # a chave publicada pela Oracle é rejeitada pelo sqv (primária marcada como
    # expirada em 2025-10-22); usamos a cópia válida do repo quando existir
    key_local mysql.gpg /usr/share/keyrings/mysql-apt-config.gpg \
        || key_from https://repo.mysql.com/RPM-GPG-KEY-mysql-2023 /usr/share/keyrings/mysql-apt-config.gpg
    sudo tee $SOURCES/mysql.list >/dev/null <<EOF
deb [signed-by=/usr/share/keyrings/mysql-apt-config.gpg] http://repo.mysql.com/apt/debian/ bookworm mysql-apt-config
deb [signed-by=/usr/share/keyrings/mysql-apt-config.gpg] http://repo.mysql.com/apt/debian/ bookworm mysql-8.4-lts
deb [signed-by=/usr/share/keyrings/mysql-apt-config.gpg] http://repo.mysql.com/apt/debian/ bookworm mysql-tools
EOF
fi

# i386 (Steam/Wine)
if ! dpkg --print-foreign-architectures | grep -q i386; then
    info "Habilitando arquitetura i386 (Steam/Wine)"
    sudo dpkg --add-architecture i386
fi

# contrib / non-free / non-free-firmware (Steam, Wine, drivers)
# Debian usa dois formatos: o clássico /etc/apt/sources.list e o deb822 debian.sources.
has_contrib() {
    { cat /etc/apt/sources.list /etc/apt/sources.list.d/debian.sources; } 2>/dev/null | grep -q contrib
}
if has_contrib; then
    info "Componentes contrib/non-free já habilitados"
else
    info "Habilitando componentes contrib, non-free e non-free-firmware"
    if [[ -f /etc/apt/sources.list.d/debian.sources ]]; then
        sudo sed -i -E 's/^(Components:.*)$/\1 contrib non-free non-free-firmware/' /etc/apt/sources.list.d/debian.sources
    elif [[ -f /etc/apt/sources.list ]]; then
        sudo sed -i -E '/^deb(-src)? .*debian/ s/ main( |$)/ main contrib non-free non-free-firmware /' /etc/apt/sources.list
    fi
fi

# Um repositório de terceiros fora do ar (ou com chave rotacionada) não pode
# impedir a instalação: avisa quais falharam e segue com os que funcionam.
info "Atualizando índices do apt"
if ! sudo apt-get update 2>&1 | tee /tmp/apt-update.$$ | grep -qE '^E:'; then
    rm -f /tmp/apt-update.$$
else
    echo
    warn "Alguns repositórios falharam (os demais seguem funcionando):"
    grep -E '^(E|W):' /tmp/apt-update.$$ | sed 's/^/     /' | head -10
    rm -f /tmp/apt-update.$$
    warn "Pacotes desses repositórios podem não instalar. Verifique a chave GPG deles."
fi
