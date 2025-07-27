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
                \ '!*.cod',
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
