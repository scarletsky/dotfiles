set nocompatible              " be iMproved
filetype off                  " required!

set rtp+=~/.vim/bundle/vundle/
call plug#begin('~/.vim/plugged')

" My bundles here:
" color theme
"" Plug 'NLKNguyen/papercolor-theme'
Plug 'tomasr/molokai'

Plug 'editorconfig/editorconfig-vim'
Plug 'tpope/vim-surround'
Plug 'Lokaltog/vim-powerline'
Plug 'tpope/vim-fugitive'
Plug 'kien/ctrlp.vim'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'vim-scripts/taglist.vim'
Plug 'mattn/emmet-vim'
Plug 'majutsushi/tagbar'
Plug 'easymotion/vim-easymotion'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'tomtom/tlib_vim'
Plug 'Raimondi/delimitMate'
Plug 'terryma/vim-multiple-cursors'
Plug 'scrooloose/syntastic'
Plug 'tpope/vim-commentary'
Plug 'Yggdroot/indentLine'
Plug 'fholgado/minibufexpl.vim'
Plug 'rking/ag.vim'
Plug 'henrik/vim-indexed-search'

call plug#end()
filetype plugin indent on     " required!
"
" Brief help
" :BundleList          - list configured bundles
" :BundleInstall(!)    - install (update) bundles
" :BundleSearch(!) foo - search (or refresh cache first) for foo
" :BundleClean(!)      - confirm (or auto-approve) removal of unused bundles
"
" see :h vundle for more details or wiki for FAQ
" NOTE: comments after Bundle commands are not allowed.

syntax on

filetype plugin on

set encoding=utf-8      " 设置utf-8编码
set number              " 显示行号
set visualbell          " 去掉输入错误的提示音
set guifont=Monaco:h20  " 设置字体大小
set noswapfile          " 不使用swp文件
set nowrap

" 设置缩进
set tabstop=2
set shiftwidth=2
set expandtab           " 将tab键转换为空格
set smartindent         " 智能缩进, 等同 set si
set autoindent          " 自动缩进，等同 set ai

set hlsearch
set magic
set history=100
set autoread
set showcmd
set guioptions-=R
set cursorline          " 行光标
set ignorecase          " 搜索时忽略大小写

let mapleader = "\<Space>"

" 窗口跳转
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-h> <C-w>h
map <C-l> <C-w>l

" Tab和Shift-Tab缩进
nmap <tab> v>
nmap <s-tab> v<
vmap <tab> >gv
vmap <s-tab> <gv

nmap <C-z> :shell<CR>

" nmap <F7> :NERDTreeFind<CR>
nmap <F7> :NERDTreeToggle<CR>
nmap <F8> :TagbarToggle<CR>
nnoremap <silent> <F9> :TlistToggle<CR>

nnoremap <leader>gd :GitDiff<CR>
nnoremap <leader>gs :GitStatus<CR>

map <leader>il :IndentLinesToggle<CR>

" Easymotion plugin Settings
map  <Leader><Leader> <Plug>(easymotion-bd-f)
nmap <Leader><Leader> <Plug>(easymotion-overwin-f)

" CtrlP plugin Settings
let g:ctrlp_custom_ignore = 'node_modules\|build\|\.git$\|\.hg$\|\.svn$'

let g:ctrlp_map = '<c-p>'

" Taglist Settings
let Tlist_Show_One_File=1
let Tlist_Exit_OnlyWindow=1
let Tlist_Use_Right_Window=1

" PowerLine Settings
set nocompatible
set laststatus=2
let g:Powerline_symbols = 'fancy'

" Fix backspace key not work
set backspace=2

" Emmet Settings

" Commentary Setting
autocmd FileType python,shell set commentstring=#\ %s

set runtimepath^=~/.vim/bundle/ctrlp

" Syntasitic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" Color Theme
set laststatus=2
set background=dark
colorscheme molokai