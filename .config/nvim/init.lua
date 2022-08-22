local set = vim.opt

set.number = true
set.relativenumber = true

set.cc = '80'
vim.api.nvim_exec([[hi ColorColumn ctermbg=234 guibg=234]], false)

set.ffs = 'unix,dos'
set.lcs = 'eol:$,tab:>>,space:_,nbsp:+'

set.softtabstop = 4
set.shiftwidth = 4
set.expandtab = false

set.foldmethod = 'expr'
set.foldexpr = 'nvim_treesitter#foldexpr()'
set.fen = false

----------------------------------------------------------------

require'packer'.startup(function()
    -- Plugin manager
    use 'wbthomason/packer.nvim'

    -- Statusline
    use 'nvim-lualine/lualine.nvim'

    -- Fuzzy finder (requires fzf and fd)
    use 'ibhagwan/fzf-lua'

    -- Syntax highlighting
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

    -- Language server protocol
    use 'williamboman/mason.nvim'
    use 'williamboman/mason-lspconfig.nvim'
    use 'neovim/nvim-lspconfig'

    -- Code completion
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
end)

----------------------------------------------------------------

require'lualine'.setup {
    options = {
	icons_enabled = false,
	theme = 'powerline_dark',
	component_separators = '│',
	section_separators = ''
    }
}

----------------------------------------------------------------

local fd_opts = '--color=never --type f --hidden --follow ' ..
		'--exclude .git ' ..
		'--exclude compatdata ' ..
		'--exclude wine_prefixes'
require'fzf-lua'.setup { 
    winopts = { 
	border = 'single',
	preview = { hidden = 'hidden' }
    },
    files = {
	fd_opts = fd_opts
    }
}
vim.api.nvim_set_keymap('n', '<C-p>', 
    "<cmd>lua require('fzf-lua').files()<CR>", 
    { noremap = true, silent = true})

----------------------------------------------------------------

require'nvim-treesitter.configs'.setup {
    ensure_installed = 'all',
    highlight = { enable = true },
    indent = { enable = true }
}

----------------------------------------------------------------

local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local opts = { noremap = true, silent = true }

    buf_set_keymap('n', '<space>e',  '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
    buf_set_keymap('n', '[d',        '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', ']d',        '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
    buf_set_keymap('n', '<space>q',  '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
    buf_set_keymap('n', 'gD',        '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', 'gd',        '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'K',         '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', 'gi',        '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    buf_set_keymap('n', '<C-k>',     '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    buf_set_keymap('n', '<space>D',  '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    buf_set_keymap('n', 'gr',        '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    buf_set_keymap('n', '<space>f',  '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

require'mason'.setup()
require'mason-lspconfig'.setup {
    automatic_installation = true
}

----------------------------------------------------------------

local cmp = require'cmp'
cmp.setup {
    completion = {
	autocomplete = false
    },
    mapping = {
	['<C-p>']     = cmp.mapping.select_prev_item(),
	['<C-n>']     = cmp.mapping.select_next_item(),
	['<C-d>']     = cmp.mapping.scroll_docs(-4),
	['<C-f>']     = cmp.mapping.scroll_docs(4),
	['<C-Space>'] = cmp.mapping.complete(),
	['<C-e>']     = cmp.mapping.close()
    },
    sources = {
	{ name = 'nvim_lsp' }
    }
}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require'cmp_nvim_lsp'.update_capabilities(capabilities)

----------------------------------------------------------------

require'lspconfig'.clangd.setup {
    on_attach = on_attach,
    capabilities = capabilities
}
