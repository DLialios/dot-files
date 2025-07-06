set tabstop=4
set shiftwidth=4
set expandtab
set smartindent
set smartcase
set ignorecase
set scrolloff=2
set sidescrolloff=2
set number
set relativenumber
set colorcolumn=80
set cursorline
set cursorlineopt=number
set updatetime=250
set timeoutlen=300
set ttimeoutlen=20
set mousemodel=extend
set splitright
set splitbelow
if has('win32')
    set runtimepath+=C:\fzf
endif
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#begin()
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'ludovicchabant/vim-gutentags'
Plug 'cocopon/iceberg.vim'
Plug 'nvim-lua/plenary.nvim'
call plug#end()

colorscheme iceberg
lua require('chat')
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! GrepCurrentWord()
    let l:query = expand('<cword>')
    call s:perform_grep(l:query)
endfunction

function! GrepPrompt()
    let l:query = input('Grep:')
    if !empty(l:query)
        call s:perform_grep(l:query)
    endif
endfunction

function! s:perform_grep(query)
    let l:rg_base = [
                \ 'rg',
                \ '--vimgrep',
                \ '-uu',
                \ '--smart-case',
                \ ]
    let l:rg_globs = [
                \ '!*.lst',
                \ '!*.map',
                \ '!.git',
                \ '!.svn',
                \ '!tags',
                \ '!tags.temp',
                \ ]

    let l:cmd_parts = l:rg_base
    for l:glob in l:rg_globs
        call add(l:cmd_parts, '-g')
        call add(l:cmd_parts, shellescape(l:glob))
    endfor
    call add(l:cmd_parts, shellescape(a:query))
    let l:full_cmd = join(l:cmd_parts, ' ')

    call setqflist([])
    silent cclose
    try
        let l:rg_output = system(l:full_cmd)
        call setqflist([], 'a', {'lines': split(l:rg_output, '\n')})
        redraw!
        if !empty(getqflist())
            silent copen
            silent cc
        else
            echo 'No results found.'
        endif
    catch
        echomsg 'rg error: ' . v:exception
    endtry
endfunction

function! FzfChangeDir()
    if has('win32')
        let l:root_dir = 'C:\'
    else
        let l:root_dir = '/'
    endif
    let l:finder_cmd = printf('fd --type d --hidden --no-ignore . %s', l:root_dir)
    let l:fzf_spec = fzf#wrap('', {
                \ 'source': l:finder_cmd,
                \ 'options': '--keep-right',
                \ 'sink': {dir_name -> s:handle_selected_dir(dir_name)}
                \ }, 1)
    call fzf#run(l:fzf_spec)
endfunction

function! s:handle_selected_dir(selected_dir)
    let l:selected_dir = trim(a:selected_dir)
    if !empty(l:selected_dir)
        execute 'lcd' fnameescape(l:selected_dir)
        echo 'pwd: ' . l:selected_dir
    endif
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

function! s:delete_buffer(ls_line)
    let l:ls_line = trim(a:ls_line)
    if !empty(l:ls_line)
        let l:match = matchlist(l:ls_line, '^\(\d\+\)')
        let l:bufnr = str2nr(l:match[1])
        execute 'bd!' l:bufnr
    endif
endfunction

function! s:build_quickfix_list(lines)
    call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
    silent copen
    silent cc
endfunction

function! GoToMarkdownFile()
    let l:line = getline('.')
    let l:col = col('.')

    let l:matches = []
    let l:pat = '\(\[\[\)\@<!\(\[\[[^]]*\]\]\)'
    let l:start = 0

    while l:start < len(l:line)
        let l:match_start = match(l:line, l:pat, l:start)
        let l:match_end = matchend(l:line, l:pat, l:start)

        if l:match_start == -1
            break
        endif

        let l:full_match = strpart(l:line, l:match_start, l:match_end - l:match_start)
        let l:inner_text = strpart(l:full_match, 2, len(l:full_match) - 4)

        call add(l:matches, {
                    \ 'start': l:match_start + 1,
                    \ 'end': l:match_end,
                    \ 'text': l:inner_text
                    \ })

        let l:start = l:match_end
    endwhile

    let l:target_name = ''
    for l:m in l:matches
        if l:col >= l:m.start && l:col <= l:m.end
            let l:target_name = l:m.text
            break
        endif
    endfor

    if !empty(l:target_name)
        let l:file_name = l:target_name . '.md'

        let l:existing_file = findfile(l:file_name)
        if !empty(l:existing_file)
            execute 'edit' l:existing_file
        else
            let l:choice = confirm('Create "' . l:file_name . '"?',
                        \ "&Yes\n&No", 2)
            if l:choice == 1
                let l:file_path = expand('%:p:h') . '/' . l:file_name
                execute 'edit' l:file_path
            endif
        endif
    else
        echo 'No markdown link at cursor'
    endif

endfunction

function! s:setup_markdown_gf()
    nnoremap <silent> <buffer> gf :call GoToMarkdownFile()<CR>
endfunction
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:mapleader = ' '
let g:maplocalleader = ' '
let g:fzf_action = { 'ctrl-q': function('s:build_quickfix_list'),
            \ 'ctrl-t': 'tab split',
            \ 'ctrl-s': 'split',
            \ 'ctrl-v': 'vsplit'
            \ }
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
augroup AutocmdGroup1
    autocmd!
    autocmd TermOpen * setlocal number relativenumber
    autocmd FileType markdown,mkd,md call <SID>setup_markdown_gf()
augroup END
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <silent> <Leader>t :tabnew<CR>
nnoremap <silent> <Leader>r :term<CR>
nnoremap <silent> <Leader>q :q<CR>
nnoremap <silent> <Leader>Q :q!<CR>
nnoremap <silent> <Leader>e :LLMChatOpen<CR>
nnoremap <silent> <Leader>a :LLMChat<CR>
nnoremap <silent> <M-q> :cclose<CR>
tnoremap <silent> <M-q> <C-\><C-n>
nnoremap <silent> <Leader>w :w<CR>
nnoremap <silent> <M-d> g<C-]>
nnoremap <silent> <C-L> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
nnoremap <silent> <Leader>p :verbose pwd<CR>
nnoremap <silent> <Leader>? :e $MYVIMRC<CR>
nnoremap <silent> <M-L> :vertical resize +4<CR>
nnoremap <silent> <M-H> :vertical resize -4<CR>
nnoremap <silent> <M-K> :resize +4<CR>
nnoremap <silent> <M-J> :resize -4<CR>
nnoremap <silent> <M-h> :silent cfirst<CR>
nnoremap <silent> <M-j> :silent! cn<CR>
nnoremap <silent> <M-k> :silent! cp<CR>
nnoremap <silent> <M-l> :silent clast<CR>
nnoremap <silent> <M-f> :call GrepCurrentWord()<CR>
nnoremap <silent> <M-s> :call GrepPrompt()<CR>
nnoremap <silent> <M-o> :call FzfChangeDir()<CR>
nnoremap <silent> <Leader>b :call FzfDeleteBuffers()<CR>
nnoremap <silent> <M-p> :FZF!
            \ --keep-right
            \ --bind=tab:toggle+up,btab:toggle+down<CR>

