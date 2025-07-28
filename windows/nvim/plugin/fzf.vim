function! FzfChangeDir(search_root)
    if has('win32')
        if !a:search_root
            let l:search_dir = 'C:\Users\dimitri\Desktop'
        else
            let l:search_dir = 'C:\'
        endif
    else
        if !a:search_root
            let l:search_dir = '/home/dimitri'
        else
            let l:search_dir = '/'
        endif
    endif
    let l:finder_cmd = printf('fd --type d --hidden --no-ignore . %s', l:search_dir)
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

let g:fzf_action = { 'ctrl-q': function('s:build_quickfix_list'),
            \ 'ctrl-t': 'tab split',
            \ 'ctrl-s': 'split',
            \ 'ctrl-v': 'vsplit'
            \ }

