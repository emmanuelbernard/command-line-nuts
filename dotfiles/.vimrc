" This must be first, because it changes other options as side effect
set nocompatible

call pathogen#infect()
filetype plugin indent on
syntax on
" set number        " set line number gutter
set relativenumber " set relative line number gutter
set showmatch     " set show matching parenthesis
set tabstop=4     " a tab is displayed as four spaces
set smarttab      " insert tabs on the start of a line according to
                  "    shiftwidth, not tabstop
set softtabstop=4 " how many columns to add when hitting tab
set shiftwidth=4  " how many columns text is indented by << and >>
set expandtab     " when hitting tab, produce spaces
set hlsearch      " highlight search terms
set incsearch     " show search matches as you type
set nobackup      " no backup file
set noswapfile    " no swap file
set pastetoggle=<F3>  "When copying large text, use F2 to disable auto-indenting and such
set backspace=indent,eol,start " Let backspace work beyond the current insert session
set mouse=a       " enable mouse support
" make mouse work in tmux
if &term =~ '^screen'
  set ttymouse=xterm2
endif
" set visualbell

" let mapleader = ','  "leader key reset from \

set smartcase    " smart case insensitive http://stackoverflow.com/questions/2287440/how-to-do-case-insensitive-search-in-vim
set history=200  " remembers enough
set wildmode=longest,list  " use autocompetion that stops when decision needs to be made

" Soft wrapping text options
" from http://vimcasts.org/episodes/soft-wrapping-text/
set wrap linebreak nolist

set backupskip=/tmp/*,/private/tmp/* "Crontab fails otherwise

" toggle between relative and absolute numbers
nnoremap <C-n> :call NumberToggle()<cr>

" Toggle nerd tree with \]
nnoremap <leader>] :NERDTreeFocus<cr>
" Make NERDTree show dot files by default; I toggles it
let NERDTreeShowHidden=1

" use absolute number when we lose focus
:au FocusLost * :set number
:au FocusGained * :set relativenumber
" in insert mode use absolute number
autocmd InsertEnter * :set number
autocmd InsertLeave * :set relativenumber

filetype plugin indent on
set spell

if &t_Co >= 256 || has("gui_running")
   " colorscheme mustang-adjusted
   colorscheme whitebackground
endif

if &t_Co > 2 || has("gui_running")
   " switch syntax highlighting on, when the terminal has colors
   " ACTION stopped because it overrides the colorscheme
   " syntax on
   " highlight SpellBad term=undercurl cterm=undercurl ctermfg=Red ctermbg=NONE gui=undercurl guibg=NONE guisp=Red
   " highlight SpellRare term=undercurl cterm=undercurl ctermfg=Magenta ctermbg=NONE gui=undercurl guifg=NONE guibg=NONE guisp=Magenta
   " mutt changes
   highlight link mailSubject Title
endif

" show visually white spaces and tabs
set list
set listchars=tab:>.,trail:.,extends:#,nbsp:.

" Font
set guifont=Monaco:h13

" Shortcuts
map <F2>f :set spelllang=fr<CR>
map <F2>e :set spelllang=en<CR>

" Syntax highlighting
autocmd BufRead,BufNewFile,BufWrite *.asciidoc set filetype=asciidoc
autocmd BufRead,BufNewFile,BufWrite *.adoc set filetype=asciidoc

" Functions
" =========
"
" relative number toggle method
function! NumberToggle()
  if(&relativenumber == 1)
    set number
  else
    set relativenumber
  endif
endfunc

" indent Space
" based on http://tedlogan.com/techblog3.html
function! IndentSpace(length)
  let lng=a:length
  let &softtabstop=lng
  let &shiftwidth=lng
  set expandtab
endfunc

" indent Tab
" based on http://tedlogan.com/techblog3.html
function! IndentTab(length)
  let lng=a:length
  let &tabstop=a:length
  let &softtabstop=lng
  let &shiftwidth=lng
  set noexpandtab
endfunc

