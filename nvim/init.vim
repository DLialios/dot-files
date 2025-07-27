if !exists('g:vscode')
    call plug#begin()
    Plug 'cocopon/iceberg.vim'
    Plug 'tpope/vim-sleuth'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-repeat'
    Plug 'nvim-lua/plenary.nvim'
    call plug#end()

    let s:config_dir = stdpath('config')
    execute 'source ' . fnameescape(s:config_dir . '/vim/core/options.vim')
    execute 'source ' . fnameescape(s:config_dir . '/vim/core/keymaps.vim')

    lua require('core')
    lua require('plugin')
endif
