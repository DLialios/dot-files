local set = vim.opt

set.number = true
set.relativenumber = true

set.tabstop = 4
set.shiftwidth = 4
set.expandtab = true

-- Packer setup
require('packer').startup(function()
    -- Plugin manager
    use 'wbthomason/packer.nvim'

    -- Syntax highlighting
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

    -- Language server protocol
    use 'neovim/nvim-lspconfig'
    use 'williamboman/nvim-lsp-installer'

    -- Code completion
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'saadparwaiz1/cmp_luasnip'
    use 'L3MON4D3/LuaSnip'

    -- Fuzzy finder (requires fzf and fd)
    use 'ibhagwan/fzf-lua'
end)

-- FZF setup
local fd_opts = '--color=never --type f --hidden --follow ' ..
                '--exclude .git ' ..
                '--exclude compatdata ' ..
                '--exclude wine_prefixes'
require('fzf-lua').setup{winopts={border='single',preview={hidden='hidden'}},files={fd_opts=fd_opts}}
vim.api.nvim_set_keymap('n', '<C-p>', "<cmd>lua require('fzf-lua').files()<CR>", {noremap=true,silent=true})

-- Treesitter setup
require('nvim-treesitter.configs').setup {
    ensure_installed = 'maintained',
    highlight = { enable = true }
}
set.foldmethod = 'expr'
set.foldexpr = 'nvim_treesitter#foldexpr()'
set.fen = false

-- LSP keymap setup
local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local opts = { noremap=true, silent=true }

    buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
    buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
    buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
    buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

-- LSP setup
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
require('nvim-lsp-installer').on_server_ready(function(server)
    local opts = {
        on_attach = on_attach,
        capabilities = capabilities
    }
    server:setup(opts)
end)

-- Autocomplete setup
local luasnip = require('luasnip')
local cmp = require('cmp')
cmp.setup {
    completion = {
        autocomplete = false
    },
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end
    },
    mapping = {
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.close(),
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true
        },
        ['<Tab>'] = function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end,
        ['<S-Tab>'] = function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end
    },
    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' }
    }
}
