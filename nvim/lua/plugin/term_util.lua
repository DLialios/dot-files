local term_clear = function()
    vim.fn.feedkeys("", 'n')
    local sb = vim.bo.scrollback
    vim.bo.scrollback = 1
    vim.bo.scrollback = sb
end

vim.api.nvim_create_autocmd("TermOpen", {
    group = vim.api.nvim_create_augroup("TermAutocmdGroup", { clear = true }),
    pattern = "*",
    command = "setlocal number relativenumber",
})


local M = {}

function M.TermClear()
    term_clear()
end

return M
