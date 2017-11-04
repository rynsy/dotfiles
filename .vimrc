set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
let path='~/.vim/bundle'
call vundle#begin(path)
Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-fugitive'
" :PluginInstall - to install, append '!' to update
" :PluginClean - removes unused plugins, append '!' to refresh local cache
" :PluginList -list
" :PluginSearch name - search for plugin
call vundle#end()
filetype plugin indent on
set backupdir=~/.vim/backup
set directory=~/.vim/temp
set number
set guifont=Menlo\ Regular:h18
let mapleader=" "
syntax on
colorscheme Tomorrow-Night-Eighties

set nowrap
set tabstop=4
set shiftwidth=2
set expandtab
set smartindent
set autoindent
set hlsearch
set backspace=indent,eol,start
set hidden
set history=100
set showmatch

noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
