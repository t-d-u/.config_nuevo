" todo sobre vim plug {{{
let mapleader = " "
if ! filereadable(system('echo -n "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/autoload/plug.vim"'))
  echo "Downloading junegunn/vim-plug to manage plugins..."
  silent !mkdir -p ${XDG_CONFIG_HOME:-$HOME/.config}/nvim/autoload/
  silent !curl "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" > ${XDG_CONFIG_HOME:-$HOME/.config}/nvim/autoload/plug.vim
  autocmd VimEnter * PlugInstall
endif

" vim plug es un package manager esencialmente
call plug#begin('~/.vim/plugged')
Plug 'plasticboy/vim-markdown' " markdown
Plug 'chrisbra/csv.vim' " comandos para el csv
Plug 'rafi/awesome-vim-colorschemes' " colorscheme
Plug 'vim-airline/vim-airline' " airline
Plug 'vim-airline/vim-airline-themes' " themes para airline
Plug 'ferrine/md-img-paste.vim'
"Plug 'preservim/nerdtree'
Plug 'vim-python/python-syntax' " syntax python
"Plug 'tmhedberg/SimpylFold' " foldea python bien
Plug 'scrooloose/nerdcommenter' " plugin para comentar
Plug 'Raimondi/delimitMate' " auto-paréntesis
Plug 'godlygeek/tabular' " plugin para pandoc y csv no lo uso nunca
Plug 'tpope/vim-surround' " surround no lo uso nunca
Plug 'sirver/ultisnips' " better snippets (suscribe Tab)
Plug 'lervag/vimtex' "vimtex
"Plug 'aserebryakov/vim-todo-lists', {'for':['todo.md','todo.wiki']}
Plug 'lervag/lists.vim'
Plug 'dhruvasagar/vim-table-mode'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'ncm2/ncm2'
Plug 'roxma/nvim-yarp'
Plug 'ncm2/ncm2-path'
Plug 'ncm2/ncm2-jedi' " para python
"Plug 'ncm2/ncm2-bufword' " la verdad es que no lo uso
Plug 'dense-analysis/ale'
Plug 'easymotion/vim-easymotion'
Plug 'jpalardy/vim-slime', { 'for': 'python' }
Plug 'hanschen/vim-ipython-cell', { 'for': 'python' }
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
"Plug 'hkupty/iron.nvim'
Plug 'szw/vim-maximizer'
"Plug 'vimwiki/vimwiki'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'lervag/wiki.vim'
Plug 'lervag/wiki-ft.vim'
"Plug 'tmhedberg/SimplyFold'
Plug 'dyng/ctrlsf.vim' " para usar con ripgrep en wiki.vim
Plug 'jbyuki/venn.nvim'
Plug 'rbgrouleff/bclose.vim'
Plug 'junegunn/goyo.vim'
call plug#end()

"}}}

" basic config {{{
	set foldmethod=marker
	colorscheme nord
	set termguicolors " No tener colores chotos
	set bg=dark
	set nocompatible
	filetype plugin on
	filetype plugin indent on
	syntax on
	set encoding=utf-8
	set number relativenumber
	set foldlevel=0
	"set nohlsearch
	set path +=**
	set mouse=a
	set tabstop=4
	set shiftwidth=4
	set gdefault
	set inccommand=nosplit
	let g:netrw_dirhistmax = 0
	set splitbelow splitright
	set linebreak
	set pumblend=40
	set cursorline
	set clipboard+=unnamedplus
	se go=a
	set wrap
	set shell=/usr/bin/zsh
	"set shell=/usr/bin/bash

" }}}

" Relevant config {{{
" Return to last edit position when opening files
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" set n lines to the cursor n=7
  set so=7

" Ignore compiled files
  set wildignore=*.o,*~,*.pyc

" Smartcase
  set ignorecase
  set smartcase

" Automatically deletes all trailing whitespace on save.
  autocmd BufWritePre * %s/\s\+$//e

  " Set undodir persist
  if !isdirectory("/tmp/undo-dir")
    call mkdir("/tmp/undo-dir", "", 0700)
  endif
  set undodir=/tmp/.vim-undo-dir
  set undofile

"cada vez que guardo con vim se actualiza el soruceo de X
autocmd BufWritePost *Xresources,*Xdefaults !xrdb %


"}}}

"  general mappings{{{

vmap Y "+y<CR>
nmap <leader>v :so $MYVIMRC<CR>
" buffers {{{
nmap ,l :bnext<cr>
nmap ,h :bprevious<cr>
nmap ,b :ls<CR>:b<Space>
" del plugin bclose.vim
nmap ,d <leader>bd
" }}}

nmap <leader>a :above split<cr><c-j>

nmap n n :noh<CR>

"inoremap <S-Tab> search('\%#[]>)}]', 'n') ? '<Right>' : '<Tab>'

" listar qué tiene cada register
nnoremap <silent> "" :registers "0123456789abcdefghijklmnopqrstuvwxyz*+.<CR>

autocmd FileType wiki nmap gw f]F[lyt\|:!google-chrome '<C-R>"'\|st sw & <CR><CR>

autocmd filetype wiki nmap <leader>td :e todo.wiki<CR>

vmap <c-tab> <esc>0<c-v> \>

" }}}

" CtrlSF usado con wiki.vim xa buscar texto dentro de file {{{
"nmap <leader>fs :CtrlSF<space>
nmap <leader>fs <Plug>CtrlSFPrompt
function! g:CtrlSFAfterMainWindowInit()
    setl wrap
endfunction
nmap <leader>ff :CtrlSFToggle<CR>
""}}}

"ultisnips{{{
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsSnippetDirectories=[$HOME.'/.vim/my-snippets/UltiSnips']
let g:UltiSnipsListSnippets="<c-tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"
"}}}

" Ale linting con flake8{{{
let g:ale_sign_column_always=1
let g:ale_lint_on_enter=1
let g:ale_lint_on_text_changed='always'
let g:ale_echo_msg_error_str='E'
let g:ale_echo_msg_warning_str='W'
let g:ale_echo_msg_format='[%linter%] %s [%severity%]: [%...code...%]'
let g:ale_linters={'python': ['flake8'], 'r': ['lintr']}
let g:ale_fixers={'python': ['black']}
"}}}

" gitgutter{{{
let g:gitgutter_async=0"
set updatetime=100

" para evitar el overriding de ale/flake8 vs gitgutter
let g:ale_sign_priority=8
let g:gitgutter_sign_priority=9
" }}}

" no uso el default e para end of word así que lo mapeo a easymotion -s{{{
nmap <leader>s <Plug>(easymotion-s)
" }}}

" ncm2{{{
autocmd BufEnter * call ncm2#enable_for_buffer()      " enable ncm2 for all buffers
set completeopt=noinsert,menuone,noselect             " IMPORTANT: :help Ncm2PopupOpen for more information
let g:python3_host_prog='/usr/bin/python3'            " ncm2-jedi

" para no tener que escribir 3 caracteres antes de que aparezca el autocomplete. esto a su vez renders useless la utilizacion de wiki.vim del omnicomplete.
let g:ncm2#complete_length=[[1,1],[7,2]]
" }}}

" navegación y resizing windows y terminal{{{
"la i es para llegar a la terminal y estar en insert mode
nnoremap <C-h> <C-w>h
"el normal: ir para el split de abajo y automaticamente ponerlo en tamano normal en vez de minimizado
nnoremap <C-j> <C-w>j <c-w>=
"para python:
autocmd FIleType py nnoremap <C-j> <C-j>i

nnoremap <C-k> <C-w>k

"nnoremap <C-l> <C-w>l <c-w>=
nnoremap <C-l> <C-w>l
"autocmd FIleType py nnoremap <C-l> <C-w>l
tmap <C-h> <esc><C-h>
inoremap <C-j> <esc><C-j>
tmap <C-k> <esc><C-k>

" resizing gradual
noremap <silent> <leader>- :resize -3<CR>
noremap <silent> <leader>+ :resize +3<CR>

" Change 2 split windows from vert to horiz or horiz to vert
map <Leader>h <C-w>t<C-w>H
map <Leader>k <C-w>t<C-w>K


" }}}

autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" csv{{{

autocmd FileType csv nmap <buffer> <Leader><Leader> :Tabularize /,<CR>
"}}}

"markdown {{{
autocmd FileType markdown nmap <buffer> <Leader><Leader><CR> :! pandoc % -o %:r.pdf; zathura --fork %:r.pdf<CR><CR>
autocmd FileType markdown nmap <buffer> <Leader><CR> :w<CR>
autocmd FileType markdown,wiki nmap <buffer><silent> <Leader>p :call mdip#MarkdownClipboardImage()<CR>


" comento esto para que se me genere un pdf a partir de un .md solo si hago o de arroba y no simpre que guardo un .md
"aug MD2PDF
    "au!
    "au BufWritePost *.md silent !pandoc % -o %:r.pdf
"aug END
"}}}

" python + terminal {{{

" terminal en general {{{

"salir de insert mode en terminal de neovim
tnoremap <esc> <c-\><c-n>

nmap <c-w><c-l> :set scrollback=1 \| sleep 100m \| set scrollback=10000<CR>
tmap <c-w><c-l> <c-\><c-n><c-w><c-l>i<c-l>


" maximizar o poner mitad-mitad
"map <C-m> <C-w>_
"map <C-n> <C-w>=
map <Leader>m :MaximizerToggle<CR>
map <Leader><Leader>m <C-w>=<esc>
"tmap <C-m> :MaximizerToggle<CR>

" no poner line numbers
autocmd TermOpen * setlocal nonumber norelativenumber
" }}}

autocmd FileType python setlocal textwidth=79 colorcolumn=80

"nueva terminal de python
map <Leader>p :new term://zsh<CR>iipython --matplotlib<CR><C-\><C-n><C-w>k"<CR>

" lead-enter {{{
autocmd Filetype python nmap <buffer> <Leader><CR> :update<bar>!python3 %<CR>

"dato: esto de aca arriba genera el mismo resultado que esto:
"nmap <Leader><CR> :w<CR>:!python3 %<CR>
" }}}

" lead-lead-enter {{{
"autocmd FileType python nmap <buffer> <Leader><Leader><CR> :update<bar>vs<Space>\|<Space>terminal ipython -i -c "\%run %"<CR>i

autocmd FileType python nmap <buffer> <Leader><Leader><CR> :update<bar>vs<Space>\|<Space>terminal ipython -i -c "\%run %"<CR>\|:let t:term_id = b:terminal_job_id<CR>\|:execute 'let b:slime_config = {"jobid": "'.t:term_id . '"}'<CR>i
" }}}

"slime {{{
let g:slime_target = 'neovim'

"con solo esa linea slime anda bien con binds default.
" let g:slime_dont_ask_default = 1 si agrego esto tira error

let g:slime_no_mappings = 1
nmap <c-c>v     <Plug>SlimeConfig
xmap <Leader>s <Plug>SlimeRegionSend<CR>
" }}}

" cell {{{
"el segundo CR es para hacer enter luego de que me pregunte por el job id
nmap <Leader><Leader>r <esc><C-k> :IPythonCellRun<CR><CR>

nmap <Leader>r :IPythonCellExecuteCell<CR><CR>

"let g:ipython_cell_tag = ['{{{','}}}']
"let g:ipython_cell_tag = ['# %%']
let g:ipython_cell_tag = ['##']
let g:ipython_cell_send_cell_headers = 1
" }}}

" }}}

" vimwiki "{{{

"let g:vimwiki_list = [{'path': '~/vimwiki/',
                      "\ 'syntax': 'markdown', 'ext': '.md'}]

" en vez de list and select available wikis:
"nmap <Leader>wl <Plug>VimwikiSplitLink

"nmap <Leader><Leader>wl <Plug>VimwikiTabnewLink
"}}}

" wiki.vim {{{
"let g:wiki_root = '~/zettelkasten' "esto no sirve de nada si no tengo un zettelkasten
" si no agrego md no puedo abrir fotos en .md apretando enter
let g:wiki_filetypes = ['wiki', 'md']
let g:wiki_link_extension = '.wiki'
let g:wiki_link_target_type = 'wiki'
autocmd filetype wiki setlocal wrap

" si usara tags...
"let g:wiki_tag_list = {'output' : 'echo'}
"nmap <leader>wft <plug>(wiki-fzf-tags)

" ya no me sirven de nada xq los nombres de las pages son fecha-clase.
"nmap <leader>wfp <plug>(wiki-fzf-pages)

" ya no sirve desde leader-z
"let g:wiki_viewer = {'pdf': 'okular'}

" para abrir un split con el index
"autocmd FileType wiki nmap <leader>wsw :split<cr><leader>ww

" mappings {{{
autocmd filetype wiki nmap <s-tab> <plug>(wiki-link-prev)

autocmd FileType wiki imap <S-tab> <esc>Ea<space>

autocmd FileType wiki vmap <leader>¿ di¿<tab><esc>p3<right>

"autocmd filetype wiki nmap <leader>z f]F$yt\|:!okular <C-R>"\|st sw & <CR><CR>
autocmd filetype wiki nmap <leader>z f]F[lyt\|:!okular <C-R>"\|st sw & <CR><CR>

" yank filename al register f
noremap <silent> yf :let @f=expand("%:t")<CR>

" yank number of line
noremap <silent> yn :let @n=line(".")<CR>
" go to number of line
noremap <silent> gn :<C-R>n<CR>

" yank header de archivo .md o .wiki e ir a buscarlo en el TOC
autocmd filetype wiki nmap yh $F#y$gg/<C-R>"<CR>

" yankeo el filepath completo
noremap yp :let @p = expand('%:p')<CR>:<esc>

" yank link al register l sin incluir [[]]
" "cambié el ] final por el |
autocmd filetype wiki nmap yl T["lyt\|<esc>



" para anki:
" me paro en el header y hago lo indicado con yh; lo yankeo entero con yl once i found el header correcto (por si está repetido).
" después me queda juntar los registers p y l en +:
noremap +f :let @+ = @p.@l<CR>:<esc>


"CONCLUSION PARA PEGAR UNA SECCIÓN EN UNA SOURCE DE ANKI:
" yh --> elijo el header --> yl yp +f, lo cual resumo en:

nmap yk ylyp+f

"entonces, lo que hago es pararme en el header yl yk. listo.


" abrir pág del split de arriba en la misma línea en el split de abajo.
nmap <leader>ej ynyf<C-j>:e +:<C-R>n<C-R>f<CR>


" VBox {{{
autocmd FileType wiki vmap b :VBox<cr>
autocmd FileType wiki nmap Bb :set ve=all<cr>
"nnoremap <silent> <leader>o :<C-u>call append(line("."),   repeat([""], v:count1))<CR>
" }}}
" }}}

" create page{{{
let g:wiki_map_create_page = 'MyFunction'

function MyFunction(name) abort
  let l:name = wiki#get_root() . '/' . a:name

  " If the file is new, then append the current date
  return filereadable(l:name)
        \ ? a:name
        "\ : a:name . '_' . strftime('%Y%m%d%H%M%S')
        \ : strftime('%Y%m%d%H%M%S') . '_' . a:name
endfunction
" }}}

"{{{text to link
" esto viene de una modicicación que le hice a este comment de lervag: https://github.com/lervag/wiki.vim/issues/240#issuecomment-1195354202
let g:wiki_map_text_to_link = 'MyTextToLink'

function MyTextToLink(text) abort
  return [strftime('%Y%m%d%H%M%S') . '_' . a:text, a:text]
endfunction
" }}}


" templates {{{

" esto es una lista de diccionarios; cada diccionario tiene info de un template: "todos tienen que tener a matcher and a source". el único que tengo es template.wiki. el criterio que tiene que tener un filename para que se le aplique el template es no tener un whitespace. osea... todos.
"let g:wiki_templates = [
	  "\ { 'match_re': '\S',
	  "\   'source_filename': '/home/tdu/zettelkasten/template.wiki'}
	  "\]
" lo comento xq no lo uso y xq no sé cómo hacer para que funcione solo con archivos .wiki; ahora hago cualquier .md anywhere y me pone el template.
"}}}

" para pdfs, lo de netrw me lo paso agus. desde el <leader>z ya no lo uso{{{
"let g:wiki_file_handler = 'WikiFileHandler'
"function! WikiFileHandler(...) abort dict
  "if self.path =~# 'pdf$'
    "silent execute '!okular' fnameescape(self.path) '&'
    "return 1
  "endif

  "return 0
"endfunction
"""""""""""""""""""""""
"let g:netrw_browsex_viewer="-"
"" functions for file extension '.mp3'.
"function! NFH_mp3(f)
	""execute '!sw vlc a:f \| st sw &'
	"normal "ayi]
	"execute '!vlc <C-R>a\|st sw & <CR> <CR>'
"endfunction

"let g:wiki_fzf_pages_opts = '--preview "cat {1}"'

" }}}

" omnicomplete {{{
"esto es copiado de wiki.vim. es para usar omnicomplete de links luego de [[. lo que tiene es que te hace omnicomplete desde el working dir hacia abajo, pero no viceversa hasta el index.wiki. entonces la unica ventjaa que tiene respecto de ncm2-path es lo primero que hace, dado que ncm2 solo se fija en el wd.
augroup my_cm_setup
autocmd!
autocmd BufEnter * call ncm2#enable_for_buffer()
autocmd User WikiBufferInitialized call ncm2#register_source({
		\ 'name': 'wiki',
		\ 'priority': 9,
		\ 'scope': ['wiki'],
		\ 'word_pattern': '\w+',
		\ 'complete_pattern': '\[\[',
		\ 'on_complete': ['ncm2#on_complete#delay', 200,
		\                 'ncm2#on_complete#omni',
		\                 'wiki#complete#omnicomplete'],
		\})
augroup END
" }}}
" }}}

" Vimtex{{{
" let g:vimtex_compiler_latexmk_engines = {'pdflatex': '-pdf'}
let g:vimtex_compiler_latexmk_engines = {'latexmk': '-pdf'}
let g:tex_flavor = "latex"
let g:vimtex_view_method='zathura'
let g:vimtex_quickfix_mode=1

" Visible code only when hover
set conceallevel=1
let g:tex_conceal='abdmg'
hi clear Conceal


augroup vimtex_config
    au!
    au User VimtexEventQuit call vimtex#compiler#clean(0)
augroup END
" autocmd FileType tex nmap <buffer> <Leader><CR> :w<CR>
autocmd FileType tex nmap <buffer> <Leader><Leader><CR> :update<bar>:VimtexCompile<CR>


"}}}

" simplyfold {{{
" tengo todo default. la idea es usar esto para foldear python, definir las cells con ## (osea si yo quiero definir una cell no voy al mismo tiempo a foldearla, sino que el fold es automatico)
" }}}

" todo lists {{{

" a cont copy paste del readme, reemplazando la s por la coma: toggleo con la coma. ademas, con <leader>ol, toggleo que al abrir nueva linea sea algo para TODO en vez de un renglon normal.
"let g:VimTodoListsCustomKeyMapper = 'VimTodoListsCustomMappings'

"function! VimTodoListsCustomMappings()
  "nnoremap <buffer> <leader>l :VimTodoListsToggleItem<CR>
  """nnoremap <buffer> <Space> :VimTodoListsToggleItem<CR>
  "noremap <buffer> <leader>ol :silent call VimTodoListsSetItemMode()<CR>
"endfunction

"let g:lists_todos = ['TODO', 'CURRENTLY', 'STANDBY', 'DEJO EN', 'DONE']

let g:lists_todos = [strftime('(%d/%m/%y) ') . 'TODO', strftime('(%d/%m/%y) ') . 'CURRENTLY', strftime('(%d/%m/%y) ') . 'STANDBY', strftime('(%d/%m/%y) ') . 'DEJO EN', strftime('(%d/%m/%y) ') . 'DONE']

autocmd FileType wiki ListsEnable
let g:lists_maps_default_override = {
      \ 'i_<plug>(lists-new-element)': '<c-a>',
      \ '<plug>(lists-toggle)': '<leader>l',
      \}

" }}}

" vim-markdown para latex
" lo de tex no se paque sirve
let g:tex_conceal = ""
let g:vim_markdown_math = 1

"algo que le gusta a lervag
let g:vim_markdown_conceal = 2

"set wrap

let g:goyo_height = 125

set wrap

" highlights todo keywords {{{
highlight MyGroupTODO ctermbg=LightRed guibg=LightRed ctermfg=black guifg=black
autocmd VimEnter * autocmd WinEnter * let m1 = matchadd("MyGroupTODO", "TODO")
let m1 = matchadd("MyGroupTODO", "TODO")

highlight MyGroupDEJOEN ctermbg=lightcyan guibg=lightcyan ctermfg=black guifg=black
autocmd VimEnter * autocmd WinEnter * let m6 = matchadd("MyGroupDEJOEN", "DEJO EN")
let m6 = matchadd("MyGroupDEJOEN", "DEJO EN")
"let m6 = matchadd("MyGroupDEJOEN", strftime('%d%m%y') . "DEJO EN")

highlight MyGroupCURR ctermbg=cyan guibg=cyan ctermfg=black guifg=black
autocmd VimEnter * autocmd WinEnter * let m2 = matchadd("MyGroupCURR", "CURR")
let m2 = matchadd("MyGroupCURR", "CURRENTLY")

highlight MyGroupSBY ctermbg=magenta guibg=magenta ctermfg=black guifg=black
autocmd VimEnter * autocmd WinEnter * let m3 = matchadd("MyGroupSBY", "STANDBY")
let m3 = matchadd("MyGroupSBY", "STANDBY")

highlight MyGroupPREG ctermbg=red guibg=red ctermfg=white guifg=white
autocmd VimEnter * autocmd WinEnter * let m4 = matchadd("MyGroupPREG", "PREGUNTA")
let m4 = matchadd("MyGroupPREG", "PREGUNTA")

highlight MyGroupDONE ctermbg=LightGreen guibg=LightGreen ctermfg=black guifg=black
autocmd VimEnter * autocmd WinEnter * let m5 = matchadd("MyGroupDONE", "DONE")
let m5 = matchadd("MyGroupDONE", "DONE")


" }}}



