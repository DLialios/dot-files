-- Automatic installation of vim-plug
--------------------------------------------------------------------------------
local url =
'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
local curl_cmd = 'silent !curl --create-dirs -fLo'

local data_dir = vim.fn.stdpath('data')
local script_dir = '/site/autoload/plug.vim'
local full_path = data_dir .. script_dir

local requires_install = vim.fn.empty(vim.fn.glob(full_path)) == 1

if requires_install then
    vim.cmd(string.format('%s %s %s', curl_cmd, full_path, url))
    vim.o.runtimepath = vim.o.runtimepath -- required because of nvim bug
    vim.cmd('autocmd VimEnter * PlugInstall --sync | source $MYVIMRC')
end


-- Aliases
--------------------------------------------------------------------------------
local global = vim.g
local o = vim.opt
local map = function(mode, lhs, rhs)
    vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true })
end


-- Options
--------------------------------------------------------------------------------
o.background = 'dark'
o.termguicolors = true
o.number = true
o.relativenumber = true
o.scrolloff = 4
o.cursorline = true
o.ignorecase = true
o.smartcase = true
o.updatetime = 250
o.timeoutlen = 300
o.splitright = true
o.splitbelow = true
o.list = false
o.listchars = { eol = '$', tab = '>>', space = '_', trail = '·', nbsp = '␣' }
o.fileformats = 'unix,dos'
o.foldmethod = 'expr'
o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
o.foldenable = true
o.foldlevel = 99
o.colorcolumn = '80'
o.signcolumn = 'yes'
o.showmode = false
o.completeopt = { 'menu' }
o.mouse = 'a'
o.undofile = true


-- Misc
--------------------------------------------------------------------------------
global.mapleader = ' '
global.maplocalleader = ' '

vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

vim.cmd [[
aunmenu PopUp.How-to\ disable\ mouse
aunmenu PopUp.-1-
]]


-- Plugins
--------------------------------------------------------------------------------
local Plug = vim.fn['plug#']

vim.call('plug#begin')
Plug('tpope/vim-sleuth')
Plug('nvim-lualine/lualine.nvim')
Plug('ibhagwan/fzf-lua', { ['branch'] = 'main' })
Plug('nvim-tree/nvim-web-devicons')
Plug('folke/tokyonight.nvim')
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })
Plug('neovim/nvim-lspconfig')
vim.call('plug#end')


-- Plugin Config
--------------------------------------------------------------------------------
require('lualine').setup { options = { theme = 'tokyonight-storm', } }
require('fzf-lua').setup { }
require('nvim-web-devicons').setup { }
vim.cmd [[ colorscheme tokyonight-storm ]]
require('nvim-treesitter.configs').setup {
    ensure_installed = {
        'c', 'cpp', 'python', 'lua', 'vim', 'vimdoc', 'query',
        'markdown', 'markdown_inline'
    },
    sync_install = false,
    auto_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    indent = {
        enable = false
    }
}


-- Mappings
--------------------------------------------------------------------------------
map('n', '<Esc>', '<cmd>nohlsearch<CR>')
map('t', '<Esc><Esc>', '<C-\\><C-n>')
map('n', '<Leader>e', '<cmd>e $MYVIMRC<CR>')
map('n', '<Leader>t', '<cmd>tabnew<CR>')
map('n', '<Leader>u', '<cmd>lua vim.diagnostic.enable(not vim.diagnostic.is_enabled())<CR>')
map('n', '<Leader>i', '<cmd>set list!<CR>')
map('n', '<Leader>y', '<cmd>set relativenumber!<CR>')
map('n', '<Leader>o', "<cmd>lua require('fzf-lua').buffers()<CR>")
map('n', '<Leader>p', "<cmd>lua require('fzf-lua').files()<CR>")
map('n', '<Leader>s', "<cmd>lua require('fzf-lua').live_grep()<CR>")
map('n', '<Leader>d', "<cmd>lua require('fzf-lua').tags_live_grep()<CR>")
map('n', '<Leader>*', "<cmd>lua require('fzf-lua').grep_cword()<CR>")
map('n', '<Leader>h', '<cmd>cfirst<CR>')
map('n', '<Leader>j', '<cmd>cn<CR>')
map('n', '<Leader>k', '<cmd>cp<CR>')
map('n', '<Leader>l', '<cmd>clast<CR>')
map('n', '<Leader>g', '<cmd>cclose<CR>')

local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local opts = { noremap = true, silent = true }

    vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
    vim.diagnostic.enable(true, { bufnr = bufnr })

    buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'gf', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', 'gh', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', 'gH', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    buf_set_keymap('n', 'grn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('i', '<C-s>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    buf_set_keymap('n', '<Leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
    buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
    buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
end


-- LSP
--------------------------------------------------------------------------------
vim.lsp.set_log_level('OFF')

-- vim.lsp.enable('clangd')
vim.lsp.config('clangd', {
    cmd = {
        'clangd',
        '--background-index',
    },
    on_attach = on_attach
})
