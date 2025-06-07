-- Options --
vim.opt.background = 'dark'
vim.opt.termguicolors = true
vim.cmd('highlight Normal guibg=Black guifg=White')

vim.opt.smarttab = true
vim.opt.autoindent = true
vim.opt.smartindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 4

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.colorcolumn = '80'
vim.opt.signcolumn = 'yes'
vim.opt.cursorline = true

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

vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldmethod = 'expr'
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

vim.opt.undofile = true
vim.opt.undolevels = 2000

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.autoread = true
vim.opt.hidden = true
vim.opt.fileformats = 'unix,dos'
vim.opt.incsearch = true

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

vim.cmd [[
filetype on
filetype plugin on
filetype indent on
syntax off
]]


-- Mappings --
local map = function(mode, lhs, rhs)
    vim.keymap.set(mode, lhs, rhs, {
        noremap = true,
        silent = true
    })
end

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

map('n', '<ScrollWheelUp>', '<C-Y>')
map('n', '<ScrollWheelDown>', '<C-E>')

map('n', '<Leader>h', '<cmd>cfirst<CR>')
map('n', '<Leader>j', '<cmd>cn<CR>')
map('n', '<Leader>k', '<cmd>cp<CR>')
map('n', '<Leader>l', '<cmd>clast<CR>')

map('n', '<Esc>', '<cmd>nohlsearch<CR>')
map('n', '<Leader>t', '<cmd>tabnew<CR>')
map('n', '<Leader>q', '<cmd>q<CR>')
map('n', '<Leader>e', '<cmd>e $MYVIMRC<CR>')
map('n', '<Leader>d', '<C-]>')


-- Plugins --
vim.call('plug#begin')

vim.fn['plug#']('tpope/vim-sleuth')

vim.fn['plug#']('nvim-treesitter/nvim-treesitter', {
    ['do'] = ':TSUpdate'
})
vim.fn['plug#']('nvim-treesitter/nvim-treesitter-textobjects')
vim.fn['plug#']('EdenEast/nightfox.nvim')

vim.fn['plug#']('nvim-lua/plenary.nvim')
vim.fn['plug#']('nvim-telescope/telescope.nvim', {
    ['tag'] = '0.1.8'
})
vim.fn['plug#']('nvim-telescope/telescope-fzf-native.nvim', {
    ['do'] = 'make'
})

vim.fn['plug#']('neovim/nvim-lspconfig')

vim.fn['plug#']('eandrju/cellular-automaton.nvim', {
    ['on'] = 'CellularAutomaton'
})

vim.call('plug#end')


-- Plugin Config --
map('n', '<Leader>fml', '<cmd>CellularAutomaton make_it_rain<CR>')

require('telescope').setup()
require('telescope').load_extension('fzf')

vim.cmd('colorscheme carbonfox')
require('nvim-treesitter.configs').setup {
    ensure_installed = {
        'c',
        'lua',
        'vim',
        'vimdoc',
        'query',
        'markdown',
        'markdown_inline'
    },
    sync_install = true,
    auto_install = true,
    ignore_install = { },
    highlight = {
        enable = true,
        disable = { },
        additional_vim_regex_highlighting = false
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                ['af'] = '@function.outer',
                ['if'] = '@function.inner'
            },
            selection_modes = {
                ['@function.outer'] = 'V',
                ['@function.inner'] = 'V'
            },
            include_surrounding_whitespace = true,
        }
    }
}


-- Telescope --
local function buffers_action()
    require('telescope.builtin').buffers()
end

local function tags_action()
    require('telescope.builtin').tags()
end

local function find_files_action()
    require('telescope.builtin').find_files()
end

local function live_grep_action()
    require('telescope.builtin').live_grep()
end

local function grep_string_action()
    require('telescope.builtin').grep_string()
end

local function find_files_hidden_action()
    require('telescope.builtin').find_files({
        hidden = true,
        no_ignore = true,
        no_ignore_parent = true
    })
end

local function live_grep_hidden_action()
    require('telescope.builtin').live_grep({
        additional_args = {
            '--hidden',
            '--no-ignore-vcs'
        }
    })
end

local function grep_string_hidden_action()
    require('telescope.builtin').grep_string({
        additional_args = {
            '--hidden',
            '--no-ignore-vcs'
        }
    })
end

local telescope_mappings = {
    { mode = 'n', key = '<Leader>b', action = buffers_action },
    { mode = 'n', key = '<Leader>a', action = tags_action },
    { mode = 'n', key = '<Leader>p', action = find_files_action },
    { mode = 'n', key = '<Leader>s', action = live_grep_action },
    { mode = 'n', key = '<Leader>f', action = grep_string_action },
    { mode = 'n', key = '<Leader>P', action = find_files_hidden_action },
    { mode = 'n', key = '<Leader>S', action = live_grep_hidden_action },
    { mode = 'n', key = '<Leader>F', action = grep_string_hidden_action }
}

for _, mapping in ipairs(telescope_mappings) do
    map(mapping.mode, mapping.key, mapping.action)
end


-- LSP --
local function stop_lsp()
    vim.lsp.stop_client(vim.lsp.get_clients(), true)
end

map('n', '<Leader>r', stop_lsp)
map('n', '<Leader>?', '<cmd>checkhealth vim.lsp<CR>')

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        vim.lsp.completion.enable(
            true,
            ev.data.client_id,
            ev.buf)
        end
    }
)


-- Servers --
vim.lsp.config('clangd', {
    cmd = {
        'clangd',
        '--background-index',
        '--query-driver=C:\\Users\\dimitri\\.platformio\\packages\\toolchain-xtensa-esp-elf\\bin\\xtensa-esp32s3-elf-*.exe'
    },
})

vim.lsp.config('rust_analyzer', {
    settings = {
        ['rust-analyzer'] = { }
    }
})


-- Enable --
vim.lsp.set_log_level('ERROR')
-- vim.lsp.enable('clangd')
-- vim.lsp.enable('rust_analyzer')

