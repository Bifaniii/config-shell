" --- Interface e Cores ---
syntax on                       " Ativa o realce de sintaxe em cores
set termguicolors               " Melhora a fidelidade de cores no terminal (True Color)
let g:dracula_colorterm = 0      " fundo transparente (blur do terminal)
colorscheme dracula             " ~/.vim/pack/themes/start/dracula (pastelterm.vim continua disponível)
set number                      " Mostra o número das linhas na lateral

" --- Indentação e Comportamento ---
filetype plugin indent on       " Identifica arquivos automaticamente e aplica regras de indentação
set tabstop=4                   " Define que o caractere Tab equivale a 4 espaços
set shiftwidth=4                " Define que a indentação automática usará 4 espaços
set expandtab                   " Transforma o caractere Tab em espaços reais ao digitar
set smarttab                    " Torna o uso do Tab mais inteligente no início de linhas

" --- Melhorias de Produtividade (Recomendado) ---
set showmatch                   " Destaca parênteses/chaves correspondentes ao fechar
set incsearch                   " Destaca os resultados de busca enquanto você digita
set hlsearch                    " Mantém os resultados da busca destacados
set showcmd                     " Destaca os comandos incompletos no canto inferior direito
