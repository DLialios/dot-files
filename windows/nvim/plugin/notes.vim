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

augroup NotesAutocmdGroup
    autocmd!
    autocmd FileType markdown,mkd,md call <SID>setup_markdown_gf()
augroup END
