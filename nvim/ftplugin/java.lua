-- LSP do Java (jdtls) via nvim-jdtls. Carregado automaticamente ao abrir um arquivo .java.
vim.pack.add { 'https://github.com/mfussenegger/nvim-jdtls' }

-- Arquivo .java novo (vazio): já preenche com o package e a classe, como o IntelliJ faz.
-- O package vem do caminho depois de src/main/java/ ou src/test/java/.
local function fill_new_file()
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  if #lines > 1 or lines[1] ~= '' then return end

  local path = vim.fs.normalize(vim.api.nvim_buf_get_name(buf)) -- no Windows troca \ por /
  local class = vim.fn.fnamemodify(path, ':t:r')
  if not class:match '^[%a_$][%w_$]*$' then return end

  local dir = vim.fn.fnamemodify(path, ':h') .. '/'
  local pkg = dir:match '/src/main/java/(.*)/$' or dir:match '/src/test/java/(.*)/$'

  local template = {}
  if pkg and pkg ~= '' then vim.list_extend(template, { 'package ' .. pkg:gsub('/', '.') .. ';', '' }) end
  local indent = vim.bo[buf].expandtab and string.rep(' ', vim.fn.shiftwidth()) or '\t'
  vim.list_extend(template, { 'public class ' .. class .. ' {', indent, '}' })

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, template)
  vim.api.nvim_win_set_cursor(0, { #template - 1, #indent })
  vim.cmd 'startinsert!' -- já começa digitando dentro da classe
end
fill_new_file()

local jdtls = require 'jdtls'

local home = vim.env.HOME or vim.uv.os_homedir()
local sdkman_java = home .. '/.sdkman/candidates/java'
local mason_jdtls = vim.fn.stdpath 'data' .. '/mason/packages/jdtls'
local is_win = vim.fn.has 'win32' == 1

-- No Windows o jdtls sobe direto pelo launcher do Eclipse (o script bin/jdtls precisa de Python)
local launcher = vim.fn.glob(mason_jdtls .. '/plugins/org.eclipse.equinox.launcher_*.jar', false, true)[1]
local installed = is_win and launcher ~= nil or vim.fn.executable(mason_jdtls .. '/bin/jdtls') == 1
if not installed then
  vim.notify('jdtls não instalado: rode :MasonInstall jdtls', vim.log.levels.WARN)
  return
end

-- Raiz do projeto: pasta com pom.xml / gradlew / .git
local root_dir = vim.fs.root(0, { 'mvnw', 'gradlew', 'pom.xml', 'build.gradle', 'build.gradle.kts', '.git' })
if not root_dir then return end

-- Cada projeto tem seu próprio workspace do jdtls
local workspace_dir = vim.fn.stdpath 'cache' .. '/jdtls-workspace/' .. vim.fn.fnamemodify(root_dir, ':p:h:t')

-- JDKs instalados pelo SDKMAN, agrupados por versão principal (17, 21, ...)
local jdks = {}
for _, path in ipairs(vim.fn.glob(sdkman_java .. '/*', false, true)) do
  local major = tonumber(vim.fs.basename(path):match '^(%d+)%.')
  if major and not jdks[major] then jdks[major] = path end
end
-- No Windows (sem SDKMAN): JDKs Temurin instalados pelo winget, em "Eclipse Adoptium\jdk-21.0.x-hotspot"
if is_win then
  for _, path in ipairs(vim.fn.glob('C:/Program Files/Eclipse Adoptium/jdk-*', false, true)) do
    local major = tonumber(vim.fs.basename(path):match '^jdk%-(%d+)')
    if major and not jdks[major] then jdks[major] = path end
  end
end

-- O jdtls precisa de Java 21+ para rodar: usa o JDK mais novo disponível
local newest = math.max(0, unpack(vim.tbl_keys(jdks)))
if newest < 21 then
  vim.notify('jdtls precisa de Java 21+ (' .. (is_win and 'winget install EclipseAdoptium.Temurin.21.JDK' or 'sdk install java 21-tem') .. ')', vim.log.levels.WARN)
  return
end

-- JDKs disponíveis para compilar os projetos (o pom.xml escolhe qual usar); o 17 é o padrão
local runtimes = {}
for major, path in pairs(jdks) do
  table.insert(runtimes, { name = 'JavaSE-' .. major, path = path, default = major == 17 or nil })
end

local cmd = {
  mason_jdtls .. '/bin/jdtls',
  '--java-executable', jdks[newest] .. '/bin/java',
  '--jvm-arg=-javaagent:' .. mason_jdtls .. '/lombok.jar',
  '-data', workspace_dir,
}
if is_win then
  cmd = {
    jdks[newest] .. '/bin/java.exe',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Xmx1g',
    '-javaagent:' .. mason_jdtls .. '/lombok.jar',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    '-jar', launcher,
    '-configuration', mason_jdtls .. '/config_win',
    '-data', workspace_dir,
  }
end

jdtls.start_or_attach {
  cmd = cmd,
  root_dir = root_dir,
  settings = {
    java = {
      configuration = { runtimes = runtimes },
      signatureHelp = { enabled = true },
      contentProvider = { preferred = 'fernflower' }, -- permite abrir o código de classes de bibliotecas
      completion = {
        favoriteStaticMembers = {
          'org.junit.jupiter.api.Assertions.*',
          'org.mockito.Mockito.*',
          'org.hamcrest.Matchers.*',
        },
      },
    },
  },
}

-- Atalhos específicos de Java (os genéricos gr*, grn, gra etc. vêm do kickstart)
local map = function(keys, func, desc, mode) vim.keymap.set(mode or 'n', keys, func, { buffer = true, desc = 'Java: ' .. desc }) end
map('<leader>jo', jdtls.organize_imports, '[O]rganizar imports')
map('<leader>jv', jdtls.extract_variable, 'Extrair [V]ariável')
map('<leader>jc', jdtls.extract_constant, 'Extrair [C]onstante')
map('<leader>jm', function() jdtls.extract_method(true) end, 'Extrair [M]étodo', 'v')
