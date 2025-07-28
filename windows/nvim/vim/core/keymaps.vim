let g:mapleader = ' '
let g:maplocalleader = ' '

nnoremap <silent> <Leader>q :q<CR>
nnoremap <silent> <Leader>Q :q!<CR>
nnoremap <silent> <Leader>w :w<CR>
nnoremap <silent> <Leader>t :tabnew<CR>
nnoremap <silent> <Leader>p :verbose pwd<CR>
nnoremap <silent> <Leader>? :e $MYVIMRC<CR>

nnoremap <silent> <M-q> :cclose<CR>
nnoremap <silent> <M-d> g<C-]>

nnoremap <silent> <C-L> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>

nnoremap <silent> <Leader>r :term<CR>
lua vim.keymap.set('t', '<C-l>', require('plugin.term_util').TermClear, {silent = true})
tnoremap <silent> <M-q> <C-\><C-n>

nnoremap <silent> <M-L> :vertical resize +4<CR>
nnoremap <silent> <M-H> :vertical resize -4<CR>
nnoremap <silent> <M-K> :resize +4<CR>
nnoremap <silent> <M-J> :resize -4<CR>

nnoremap <silent> <M-h> :silent cfirst<CR>
nnoremap <silent> <M-j> :silent! cn<CR>
nnoremap <silent> <M-k> :silent! cp<CR>
nnoremap <silent> <M-l> :silent clast<CR>

nnoremap <silent> <Leader>e :LLMChatOpen<CR>
nnoremap <silent> <Leader>a :LLMChat<CR>
nnoremap <silent> <M-a> :LLMChatToggleWinOpts<CR>

nnoremap <silent> <M-f> :call GrepCurrentWord()<CR>
nnoremap <silent> <M-s> :call GrepPrompt()<CR>

nnoremap <silent> <M-o> :call FzfChangeDir(v:false)<CR>
nnoremap <silent> <M-O> :call FzfChangeDir(v:true)<CR>
nnoremap <silent> <Leader>b :call FzfDeleteBuffers()<CR>
nnoremap <silent> <M-p> :FZF! --keep-right --bind=tab:toggle+up,btab:toggle+down<CR>
