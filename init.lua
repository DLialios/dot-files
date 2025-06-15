vim.call('plug#begin')
vim.fn['plug#']('NMAC427/guess-indent.nvim')
vim.fn['plug#']('tomasiser/vim-code-dark')
vim.call('plug#end')
require('guess-indent').setup {}

vim.opt.background = 'dark'
vim.opt.termguicolors = true
vim.cmd('colorscheme codedark')

vim.opt.smarttab = true
vim.opt.smartindent = true
vim.opt.smartcase = true

vim.opt.autoindent = true
vim.opt.ignorecase = true

vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 4

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.colorcolumn = '80'
vim.opt.signcolumn = 'no'
vim.opt.cursorline = true
vim.opt.cursorlineopt = 'number'

vim.opt.laststatus = 2
vim.opt.ruler = true
vim.opt.showmode = true
vim.opt.showcmd = true

vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.timeout = true
vim.opt.ttimeoutlen = 20
vim.opt.ttimeout = true

vim.opt.list = false
vim.opt.listchars = {
    eol = '$',
    tab = '>>',
    space = '_',
    trail = '·',
    nbsp = '␣'
}

vim.opt.undofile = true
vim.opt.undolevels = 2000

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.shortmess = 'I'
vim.opt.autoread = true
vim.opt.hidden = true
vim.opt.fileformats = 'unix,dos'
vim.opt.incsearch = true

vim.cmd [[
filetype on
filetype plugin on
filetype indent on
syntax on
]]

vim.opt.mouse = 'a'
vim.cmd [[
aunmenu PopUp.-1-
aunmenu PopUp.-2-
aunmenu PopUp.How-to\ disable\ mouse
]]

vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank()
    end
})

local map = function(mode, lhs, rhs)
    vim.keymap.set(mode, lhs, rhs, {
        noremap = true,
        silent = true
    })
end

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

map('n', '<Leader>e', '<cmd>e $MYVIMRC<CR>')
map('n', '<Leader>t', '<cmd>tabnew<CR>')
map('n', '<Leader>b', '<cmd>ls<CR>')
map('n', '<Leader>q', '<cmd>q<CR>')
map('n', '<Leader>w', '<cmd>w<CR>')
map('n', '<Leader>d', '<C-]>')

map('n', '<M-q>', '<cmd>cclose<CR>')
map('n', '<M-h>', '<cmd>cfirst<CR>')
map('n', '<M-j>', '<cmd>cn<CR>')
map('n', '<M-k>', '<cmd>cp<CR>')
map('n', '<M-l>', '<cmd>clast<CR>')

map('n', '<M-L>', '<cmd>vertical resize +4<CR>')
map('n', '<M-H>', '<cmd>vertical resize -4<CR>')
map('n', '<M-K>', '<cmd>resize +4<CR>')
map('n', '<M-J>', '<cmd>resize -4<CR>')

map('n', '<ScrollWheelUp>', '<C-Y>')
map('n', '<ScrollWheelDown>', '<C-E>')

-- ripgrep
vim.opt.grepprg = 'rg ' ..
'--vimgrep ' ..
'--smart-case ' ..
'--hidden ' ..
'--no-ignore-vcs ' ..
'-g "!.git" ' ..
'-g "!.svn" ' ..
'-g "!tags"'

map('n', '<M-f>', function()
    vim.cmd[[
    silent grep <cword>
    copen
    cc
    ]]
end)

map('n', '<M-s>', function()
    vim.ui.input({ prompt = 'Grep for pattern: ' }, function(pattern)
        if pattern and pattern ~= '' then
            local cmd = 'silent grep ' .. vim.fn.escape(pattern, ' \\"')
            vim.fn.setqflist({})
            vim.cmd('cclose')
            vim.cmd(cmd)
            if #vim.fn.getqflist() > 0 then
                vim.cmd('copen')
            else
                print('No results found.')
            end
        end
    end)
end)

-- fzf
local fzf_switches = '--keep-right --bind=tab:toggle+up,btab:toggle+down'
map('n', '<M-p>', '<cmd>FZF ' .. fzf_switches .. '<CR>')

vim.cmd([[

function! s:build_quickfix_list(lines)
    call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
    copen
    cc
endfunction

let g:fzf_action = {
    \ 'alt-q': function('s:build_quickfix_list'),
    \ 'ctrl-t': 'tab split',
    \ 'ctrl-s': 'split',
    \ 'ctrl-v': 'vsplit'
    \ }

]])
