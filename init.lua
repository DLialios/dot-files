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
Plug('nvim-lua/plenary.nvim')
Plug('nvim-tree/nvim-web-devicons')
Plug('folke/tokyonight.nvim')
Plug('tpope/vim-sleuth')
Plug('nvim-lualine/lualine.nvim')
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })
Plug('nvim-telescope/telescope.nvim', { ['tag'] = '0.1.8' })
Plug('nvim-telescope/telescope-fzf-native.nvim', { ['do'] = 'make' })
-- Plug('neovim/nvim-lspconfig')
vim.call('plug#end')


-- Plugin Config
--------------------------------------------------------------------------------
require('telescope').setup { }
require('telescope').load_extension('fzf')
require('lualine').setup { options = { theme = 'tokyonight-storm', } }
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
map('n', '<Leader>d', '<C-]>')

map('n', '<Leader>h', '<cmd>cfirst<CR>')
map('n', '<Leader>j', '<cmd>cn<CR>')
map('n', '<Leader>k', '<cmd>cp<CR>')
map('n', '<Leader>l', '<cmd>clast<CR>')
map('n', '<Leader>g', '<cmd>cclose<CR>')

map('n', '<Leader>p', "<cmd>lua require('telescope.builtin').find_files()<CR>")
map('n', '<Leader>P',
"<cmd>lua require('telescope.builtin').find_files({ " ..
"hidden = true, no_ignore = true, no_ignore_parent = true })<CR>")

map('n', '<Leader>f', "<cmd>lua require('telescope.builtin').grep_string()<CR>")
map('n', '<Leader>F',
"<cmd>lua require('telescope.builtin').grep_string({ " ..
"additional_args = function() " ..
    "return {'--hidden','--no-ignore-vcs'} end })<CR>"
)

map('n', '<Leader>s', "<cmd>lua require('telescope.builtin').live_grep()<CR>")
map('n', '<Leader>S',
"<cmd>lua require('telescope.builtin').live_grep({ " ..
"additional_args = function() " ..
    "return {'--hidden','--no-ignore-vcs'} end })<CR>"
)

map('n', '<Leader>b', "<cmd>lua require('telescope.builtin').buffers()<CR>")
map('n', '<Leader>a', "<cmd>lua require('telescope.builtin').tags()<CR>")


-- LSP
--------------------------------------------------------------------------------

-- local on_attach = function(client, bufnr)
--     local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
--     local opts = { noremap = true, silent = true }
-- 
--     vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
--     vim.diagnostic.enable(true, { bufnr = bufnr })
-- 
--     buf_set_keymap('n', 'gd', "<cmd>lua require('telescope.builtin').lsp_definitions()<CR>", opts)
--     buf_set_keymap('n', 'gf', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
--     buf_set_keymap('n', 'gh', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
--     buf_set_keymap('n', 'gH', "<cmd>lua require('telescope.builtin').lsp_references()<CR>", opts)
--     buf_set_keymap('n', 'grn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
--     buf_set_keymap('i', '<C-s>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
--     buf_set_keymap('n', '<Leader>e', "<cmd>lua require('telescope.builtin').diagnostics({ bufnr = 0 })<CR>", opts)
--     buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
--     buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
-- end
-- 
-- vim.lsp.set_log_level('OFF')
-- 
-- vim.lsp.enable('clangd')
-- vim.lsp.config('clangd', {
--     cmd = {
--         'clangd',
--         '--background-index',
--     },
--     on_attach = on_attach
-- })
