#!/usr/bin/env bash
# Adiciona os repositórios de terceiros usados pelos pacotes de packages/apt.txt.
# Chamado pelo install.sh; pode ser rodado sozinho. Idempotente.
set -euo pipefail

info() { printf '\033[1;32m==>\033[0m %s\n' "$*"; }

KEYRINGS=/etc/apt/keyrings
SOURCES=/etc/apt/sources.list.d
sudo install -d -m 0755 "$KEYRINGS"
ARCH="$(dpkg --print-architecture)"

# key_from <url> <arquivo-destino>  — baixa e desarmoura se preciso
key_from() {
    [[ -f "$2" ]] && return 0
    if [[ "$2" == *.asc ]]; then
        curl -fsSL "$1" | sudo tee "$2" >/dev/null
    else
        curl -fsSL "$1" | sudo gpg --dearmor -o "$2"
    fi
    sudo chmod a+r "$2"
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
    key_from https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg /usr/share/keyrings/spotify.gpg
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
    key_from https://repo.mysql.com/RPM-GPG-KEY-mysql-2023 /usr/share/keyrings/mysql-apt-config.gpg
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

# non-free-firmware / contrib (Steam, drivers)
if ! grep -rq 'contrib' /etc/apt/sources.list /etc/apt/sources.list.d/debian.sources 2>/dev/null; then
    info "Adicionando componentes contrib e non-free-firmware"
    sudo sed -i 's/^Components: main$/Components: main contrib non-free non-free-firmware/' /etc/apt/sources.list.d/debian.sources 2>/dev/null || true
fi

info "Atualizando índices do apt"
sudo apt-get update -qq
