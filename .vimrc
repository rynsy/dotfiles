set nocompatible
filetype off

set rtp+=%HOMEPATH%/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-fugitive'
" :PluginInstall - to install, append '!' to update
" :PluginClean - removes unused plugins, append '!' to refresh local cache
" :PluginList -list
" :PluginSearch name - search for plugin
call vundle#end()
filetype plugin indent on
set backupdir=c:\Users\rmli223.AD\.vim\backup\
set directory=c:\Users\rmli223.AD\.vim\temp\
set number
set guifont=Menlo\ Regular:h18
let mapleader=" "
syntax on
colorscheme Tomorrow-Night-Eighties

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

noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l

vmap <Tab> >>
vmap <S-Tab> <<
