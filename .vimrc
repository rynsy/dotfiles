set nocompatible
filetype off

set rtp+=$HOME/.vim/bundle/Vundle.vim/
call vundle#begin('$HOME/.vim/bundle/')
Plugin 'VundleVim/Vundle.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-sensible'
Plugin 'kien/ctrlp.vim'
" Plugin 'altercation/vim-colors-solarized'
" Plugin 'pangloss/vim-javascript'
" Plugin 'plasticboy/vim-markdown'
" Plugin 'xuhdev/vim-latex-live-preview'
" :PluginInstall - to install, append '!' to update
" :PluginClean - removes unused plugins, append '!' to refresh local cache
" :PluginList -list
" :PluginSearch name - search for plugin
call vundle#end()
filetype plugin indent on
set backupdir=~/.vim/backup
set directory=~/.vim/temp
set tags=tags;
set number
" set guifont=Menlo\ Regular:h18
colorscheme peachpuff
let mapleader=" "
syntax on

set nowrap
set tabstop=4
set shiftwidth=4
set expandtab
set smartindent
set autoindent
set hlsearch
set backspace=indent,eol,start
set hidden
set history=1000
set showmatch
set ls=2

noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
inoremap jk <esc>
nnoremap ; :
noremap gf <C-^> 
vmap <Tab> >>
vmap <S-Tab> <<

" Set key for opening NerdTree
function! OpenNerdTree()
if &modifiable && strlen(expand('%')) > 0 && !&diff
 NERDTreeFind
else
 NERDTreeToggle
endif
endfunction
nnoremap <silent> <C-\> :call OpenNerdTree()<CR>
