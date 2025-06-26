set nocompatible
set nolangremap

filetype on
filetype plugin on
filetype indent on
syntax on

set termguicolors
set t_Co=256
set background=dark

set smarttab

set autoindent
set smartindent

set ignorecase
set smartcase
set incsearch

set scrolloff=4
set sidescrolloff=4
set sidescroll=1

set number
set relativenumber

set colorcolumn=80
set signcolumn=no

set cursorline
set cursorlineopt=number

set laststatus=2
set ruler

set showmode
set showcmd

set updatetime=250

set timeoutlen=300
set ttimeoutlen=20
set timeout
set ttimeout

set nolist
set listchars=eol:$,tab:>\ ,space:_,trail:.,nbsp:␣

set undofile
set undolevels=2000

set splitright
set splitbelow

set wildmenu
set wildoptions=pum

set encoding=utf-8
set shortmess=I
set autoread
set hidden
set display=truncate
set fileformats=unix,dos
set history=1000
set tabpagemax=50
set mouse=a

set sessionoptions-=options
set viewoptions-=options
set backspace=indent,eol,start
set complete-=i
set nrformats-=octal 
set formatoptions+=j
set viminfo^=!
set runtimepath+=C:\fzf

set grepformat=%f:%l:%c:%m
set grepprg=rg\ --vimgrep\ --smart-case\ --hidden\ --no-ignore-vcs\
			\ -g\ \"!*.html\"\
			\ -g\ \"!*.js\"\
			\ -g\ \"!*.lst\"\
			\ -g\ \"!*.map\"\
			\ -g\ \"!.git\"\
			\ -g\ \"!.svn\"\
			\ -g\ \"!tags\"\
			\ -g\ \"!tags.temp\"


call plug#begin()
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'ludovicchabant/vim-gutentags'
Plug 'dracula/vim', { 'as': 'dracula' }
call plug#end()

colorscheme dracula


function! GrepCurrentWord()
	let l:query = shellescape(fnameescape(expand('<cword>')))
	let l:cmd = 'silent grep! ' . l:query
	execute l:cmd
	copen
	cc
	redraw!
endfunction

function! GrepPrompt()
	let l:pattern = input('Grep:')
	if !empty(l:pattern)
		let l:query = shellescape(fnameescape(l:pattern))
		let l:cmd = 'silent grep! ' . l:query
		call setqflist([])
		cclose
		execute l:cmd
		if !empty(getqflist())
			copen
			cc
			redraw!
		else
			echo 'No results found.'
		endif
	endif
endfunction

function! FzfChangeDir()
	let l:finder_cmd = 'fd --type d --hidden --no-ignore . /'
	let l:fzf_spec = fzf#wrap('', {
				\ 'source': l:finder_cmd,
				\ 'options': '--keep-right',
				\ 'sink': {dir_name -> s:handle_selected_dir(dir_name)}
				\ }, 1)
	call fzf#run(l:fzf_spec)
endfunction

function! FzfDeleteBuffers()
	redir => l:list_output_str
	silent ls
	redir END
	let l:list_output = reverse(split(l:list_output_str, '\n'))
	let l:fzf_spec = fzf#wrap('', {
				\ 'source': l:list_output,
				\ 'options': '--multi --bind=tab:toggle+up,btab:toggle+down',
				\ 'sink': {buf_name -> s:delete_buffer(buf_name)}
				\ }, 1)

	call fzf#run(l:fzf_spec)
endfunction

function s:delete_buffer(ls_line)
	let l:ls_line = trim(a:ls_line)
	if !empty(l:ls_line)
		let l:match = matchlist(l:ls_line, '^\(\d\+\)')
		let l:bufnr = str2nr(l:match[1])
		execute 'bd!' l:bufnr
	endif
endfunction

function s:handle_selected_dir(selected_dir)
	let l:selected_dir = trim(a:selected_dir)
	if !empty(l:selected_dir)
		execute 'lcd' fnameescape(l:selected_dir)
		echo 'pwd: ' . l:selected_dir
	endif
endfunction

function s:build_quickfix_list(lines)
	call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
	copen
	cc
endfunction


let g:mapleader = ' '
let g:maplocalleader = ' '

nnoremap <silent> <ScrollWheelUp> <C-Y>
nnoremap <silent> <ScrollWheelDown> <C-E>

nnoremap <silent> <C-L> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>

nnoremap <silent> <Leader>w :w<CR>
nnoremap <silent> <Leader>q :q<CR>
nnoremap <silent> <Leader>t :tabe<CR>
nnoremap <silent> <Leader>r :term ++curwin<CR>
nnoremap <silent> <Leader>p :verbose pwd<CR>
nnoremap <silent> <Leader>? :e $MYVIMRC<CR>

nnoremap <silent> <M-q> :cclose<CR>
tnoremap <silent> <M-q> <C-\><C-n>
nnoremap <silent> <M-d> g<C-]>
nnoremap <silent> <M-L> :vertical resize +4<CR>
nnoremap <silent> <M-H> :vertical resize -4<CR>
nnoremap <silent> <M-K> :resize +4<CR>
nnoremap <silent> <M-J> :resize -4<CR>
nnoremap <silent> <M-h> :silent cfirst<CR>
nnoremap <silent> <M-j> :silent cn<CR>
nnoremap <silent> <M-k> :silent cp<CR>
nnoremap <silent> <M-l> :silent clast<CR>
nnoremap <silent> <M-f> :call GrepCurrentWord()<CR>
nnoremap <silent> <M-s> :call GrepPrompt()<CR>
nnoremap <silent> <M-o> :call FzfChangeDir()<CR>
nnoremap <silent> <Leader>b :call FzfDeleteBuffers()<CR>

let g:fzf_action = { 'alt-q': function('s:build_quickfix_list'),
			\ 'ctrl-t': 'tab split',
			\ 'ctrl-s': 'split',
			\ 'ctrl-v': 'vsplit'
			\ }
let s:fzf_switches = '--keep-right --bind=tab:toggle+up,btab:toggle+down'
execute 'nnoremap <silent> <M-p> :FZF! ' . s:fzf_switches . '<CR>'
