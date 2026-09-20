" pastelterm — mesma paleta do gnome-terminal
" fundo #12161a | texto #acff9d
" normal:  red #e63939 green #9ece8a yellow #e6c384 blue #4f86f0 magenta #b07be0 cyan #86d3d3 white #d0d3d9
" bright:  red #ff2e2e green #acff9d yellow #ffd166 blue #6ea0ff magenta #c98cf5 cyan #9be6e6 white #f2f4f7

set background=dark
hi clear
if exists('syntax_on') | syntax reset | endif
let g:colors_name = 'pastelterm'

" fundo NONE = deixa a transparência/blur do terminal aparecer
hi Normal        guifg=#acff9d guibg=NONE    ctermfg=10 ctermbg=NONE
hi NonText       guifg=#5c6370 guibg=NONE    ctermfg=8  ctermbg=NONE
hi EndOfBuffer   guifg=#1b1f24 guibg=NONE    ctermfg=0  ctermbg=NONE

" --- interface ---
hi LineNr        guifg=#5c6370 guibg=NONE    ctermfg=8  ctermbg=NONE
hi CursorLineNr  guifg=#ffd166 guibg=NONE    ctermfg=11 gui=bold cterm=bold
hi CursorLine    guibg=#1b1f24 ctermbg=0     gui=NONE cterm=NONE
hi CursorColumn  guibg=#1b1f24 ctermbg=0
hi ColorColumn   guibg=#1b1f24 ctermbg=0
hi SignColumn    guibg=NONE    ctermbg=NONE
hi VertSplit     guifg=#5c6370 guibg=NONE    ctermfg=8  ctermbg=NONE
hi StatusLine    guifg=#12161a guibg=#9ece8a ctermfg=0  ctermbg=2  gui=bold cterm=bold
hi StatusLineNC  guifg=#d0d3d9 guibg=#1b1f24 ctermfg=7  ctermbg=0  gui=NONE cterm=NONE
hi TabLine       guifg=#d0d3d9 guibg=#1b1f24 ctermfg=7  ctermbg=0  gui=NONE cterm=NONE
hi TabLineFill   guibg=#1b1f24 ctermbg=0
hi TabLineSel    guifg=#12161a guibg=#9ece8a ctermfg=0  ctermbg=2  gui=bold cterm=bold
hi Pmenu         guifg=#d0d3d9 guibg=#1b1f24 ctermfg=7  ctermbg=0
hi PmenuSel      guifg=#12161a guibg=#9ece8a ctermfg=0  ctermbg=2
hi PmenuSbar     guibg=#1b1f24 ctermbg=0
hi PmenuThumb    guibg=#5c6370 ctermbg=8
hi WildMenu      guifg=#12161a guibg=#ffd166 ctermfg=0  ctermbg=11
hi Visual        guifg=#f2f4f7 guibg=#2f3d35 ctermfg=15 ctermbg=8
hi Search        guifg=#12161a guibg=#ffd166 ctermfg=0  ctermbg=11
hi IncSearch     guifg=#12161a guibg=#ff2e2e ctermfg=0  ctermbg=9
hi CurSearch     guifg=#12161a guibg=#ff2e2e ctermfg=0  ctermbg=9
hi MatchParen    guifg=#ffd166 guibg=#2f3d35 ctermfg=11 ctermbg=8  gui=bold cterm=bold
hi Folded        guifg=#86d3d3 guibg=#1b1f24 ctermfg=6  ctermbg=0
hi FoldColumn    guifg=#5c6370 guibg=NONE    ctermfg=8  ctermbg=NONE
hi Directory     guifg=#4f86f0 ctermfg=4
hi Title         guifg=#c98cf5 ctermfg=13 gui=bold cterm=bold
hi Question      guifg=#9ece8a ctermfg=2
hi MoreMsg       guifg=#9ece8a ctermfg=2
hi ModeMsg       guifg=#ffd166 ctermfg=11 gui=bold cterm=bold
hi ErrorMsg      guifg=#f2f4f7 guibg=#e63939 ctermfg=15 ctermbg=1
hi WarningMsg    guifg=#ffd166 ctermfg=11
hi SpecialKey    guifg=#5c6370 ctermfg=8
hi Whitespace    guifg=#5c6370 ctermfg=8
hi Conceal       guifg=#5c6370 ctermfg=8

" --- diff ---
hi DiffAdd       guibg=#1e3a28 ctermbg=2  ctermfg=0
hi DiffDelete    guifg=#e63939 guibg=#3a1e1e ctermfg=1 ctermbg=0
hi DiffChange    guibg=#1e2a3a ctermbg=4  ctermfg=0
hi DiffText      guifg=#12161a guibg=#6ea0ff ctermfg=0 ctermbg=12 gui=bold cterm=bold

" --- spell ---
hi SpellBad      guisp=#e63939 gui=undercurl cterm=underline ctermfg=1
hi SpellCap      guisp=#4f86f0 gui=undercurl cterm=underline ctermfg=4
hi SpellRare     guisp=#b07be0 gui=undercurl cterm=underline ctermfg=5
hi SpellLocal    guisp=#86d3d3 gui=undercurl cterm=underline ctermfg=6

" --- sintaxe ---
hi Comment       guifg=#5c6370 ctermfg=8  gui=italic cterm=italic
hi Constant      guifg=#e6c384 ctermfg=3
hi String        guifg=#e6c384 ctermfg=3
hi Character     guifg=#e6c384 ctermfg=3
hi Number        guifg=#ffd166 ctermfg=11
hi Boolean       guifg=#ffd166 ctermfg=11
hi Float         guifg=#ffd166 ctermfg=11
hi Identifier    guifg=#d0d3d9 ctermfg=7  gui=NONE cterm=NONE
hi Function      guifg=#6ea0ff ctermfg=12
hi Statement     guifg=#b07be0 ctermfg=5  gui=NONE cterm=NONE
hi Conditional   guifg=#b07be0 ctermfg=5
hi Repeat        guifg=#b07be0 ctermfg=5
hi Label         guifg=#b07be0 ctermfg=5
hi Operator      guifg=#86d3d3 ctermfg=6
hi Keyword       guifg=#b07be0 ctermfg=5
hi Exception     guifg=#e63939 ctermfg=1
hi PreProc       guifg=#c98cf5 ctermfg=13
hi Include       guifg=#c98cf5 ctermfg=13
hi Define        guifg=#c98cf5 ctermfg=13
hi Macro         guifg=#c98cf5 ctermfg=13
hi PreCondit     guifg=#c98cf5 ctermfg=13
hi Type          guifg=#4f86f0 ctermfg=4  gui=NONE cterm=NONE
hi StorageClass  guifg=#4f86f0 ctermfg=4
hi Structure     guifg=#4f86f0 ctermfg=4
hi Typedef       guifg=#4f86f0 ctermfg=4
hi Special       guifg=#9be6e6 ctermfg=14
hi SpecialChar   guifg=#9be6e6 ctermfg=14
hi Tag           guifg=#6ea0ff ctermfg=12
hi Delimiter     guifg=#d0d3d9 ctermfg=7
hi SpecialComment guifg=#86d3d3 ctermfg=6
hi Debug         guifg=#e63939 ctermfg=1
hi Underlined    guifg=#6ea0ff ctermfg=12 gui=underline cterm=underline
hi Ignore        guifg=#5c6370 ctermfg=8
hi Error         guifg=#f2f4f7 guibg=#e63939 ctermfg=15 ctermbg=1
hi Todo          guifg=#12161a guibg=#ffd166 ctermfg=0  ctermbg=11 gui=bold cterm=bold
