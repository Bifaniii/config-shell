# install-neovim.ps1 — a mesma config do Neovim (nvim/) no Windows 10/11.
#
# Numa máquina sem nada (nem git), abra o PowerShell e rode:
#   irm https://raw.githubusercontent.com/Bifaniii/config-shell/master/install-neovim.ps1 | iex
# Com o repo já clonado:
#   powershell -ExecutionPolicy Bypass -File $HOME\config-shell\install-neovim.ps1
#
# Instala pelo winget o que faltar: Git, Neovim 0.12+, ripgrep, Node LTS, JDK 17 e 21 (Temurin) e o
# Build Tools do Visual Studio (compilador C que o treesitter usa para os parsers). Depois liga
# %LOCALAPPDATA%\nvim ao nvim\ do repo (junction: editou lá, o repo já reflete) e instala plugins,
# parsers e servidores de linguagem sem abrir o nvim. Pode rodar de novo: pula o que já existe.

$ErrorActionPreference = 'Stop'
$RepoUrl = 'https://github.com/Bifaniii/config-shell.git'
$LSPS = 'jdtls typescript-language-server angular-language-server html-lsp css-lsp emmet-language-server'

function Info($msg) { Write-Host "==> $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "!! $msg" -ForegroundColor Yellow }

function Update-Path {
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path', 'User')
}

function Test-WingetPackage($id) {
    winget list --id $id --exact --accept-source-agreements *> $null
    return $LASTEXITCODE -eq 0
}

function Install-WingetPackage($id, $name, [string[]]$extra = @()) {
    if (Test-WingetPackage $id) { Info "$name já instalado"; return }
    Info "Instalando $name ($id)"
    winget install --id $id --exact --silent --accept-package-agreements --accept-source-agreements @extra
    if ($LASTEXITCODE -ne 0) { Warn "Falhou: $name. Instale manualmente: winget install $id" }
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw 'winget não encontrado. Atualize o "Instalador de Aplicativo" pela Microsoft Store e rode de novo.'
}

# ---------- programas ----------
Install-WingetPackage 'Git.Git' 'Git'
Install-WingetPackage 'Neovim.Neovim' 'Neovim'
Install-WingetPackage 'BurntSushi.ripgrep.MSVC' 'ripgrep (busca do telescope)'
Install-WingetPackage 'OpenJS.NodeJS.LTS' 'Node.js LTS (servidores de TS/Angular/HTML/CSS)'
Install-WingetPackage 'EclipseAdoptium.Temurin.21.JDK' 'JDK 21 (roda o jdtls)'
Install-WingetPackage 'EclipseAdoptium.Temurin.17.JDK' 'JDK 17 (padrão dos projetos Java)'
Install-WingetPackage 'Microsoft.VisualStudio.2022.BuildTools' 'Build Tools do Visual Studio (compilador C, demora)' `
    @('--override', '--quiet --wait --norestart --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended')
Update-Path

# O kickstart atual precisa do Neovim 0.12+ (vim.pack)
$nvimVersion = (nvim --version | Select-Object -First 1) -replace '^NVIM v', ''
if ([version]($nvimVersion -replace '[^0-9.].*$', '') -lt [version]'0.12') {
    Info "Neovim $nvimVersion é antigo; atualizando"
    winget upgrade --id Neovim.Neovim --exact --silent --accept-package-agreements --accept-source-agreements
    Update-Path
}

# ---------- repo ----------
if ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot 'nvim\init.lua'))) {
    $Repo = $PSScriptRoot
} else {
    $Repo = Join-Path $HOME 'config-shell'
    if (Test-Path (Join-Path $Repo '.git')) {
        Info "Atualizando $Repo"
        git -C $Repo pull --ff-only
    } else {
        Info "Clonando $RepoUrl em $Repo"
        git clone $RepoUrl $Repo
    }
}

# ---------- tree-sitter CLI (o nvim-treesitter compila os parsers com ele) ----------
if (Get-Command tree-sitter -ErrorAction SilentlyContinue) {
    Info 'tree-sitter CLI já instalado'
} else {
    Info 'npm install -g tree-sitter-cli'
    npm install -g tree-sitter-cli
    Update-Path
}

# ---------- config (junction %LOCALAPPDATA%\nvim -> repo\nvim) ----------
$Config = Join-Path $env:LOCALAPPDATA 'nvim'
$Target = Join-Path $Repo 'nvim'
$item = Get-Item $Config -ErrorAction SilentlyContinue
if ($item -and $item.LinkType -eq 'Junction' -and $item.Target -contains $Target) {
    Info "Link ok: $Config"
} else {
    if ($item) {
        $backup = "$Config.bak-$(Get-Date -Format yyyyMMdd-HHmmss)"
        Warn "Backup: $Config -> $backup"
        Move-Item $Config $backup
    }
    New-Item -ItemType Junction -Path $Config -Target $Target | Out-Null
    Info "Link criado: $Config -> $Target"
}

# ---------- plugins, parsers e servidores de linguagem sem abrir a UI ----------
Info 'Instalando plugins e parsers do treesitter (uns 2 minutos)'
nvim --headless '+sleep 120' +qa
Info "Instalando os servidores de linguagem pelo Mason: $LSPS"
nvim --headless "+MasonInstall $LSPS" +qa

Info 'Pronto. Abra um terminal novo e rode: nvim'
