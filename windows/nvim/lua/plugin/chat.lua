local curl = require('plenary.curl')

local function get_llm_completion(model, messages, on_delta, on_complete)
    local completions = curl.post(
        'https://openrouter.ai/api/v1/chat/completions',
        {
            headers = 
            {
                Authorization = 'Bearer ' .. vim.env.OPENROUTER_API_KEY,
            },
            body = vim.fn.json_encode(
                {
                    model = model,
                    messages = messages,
                    stream = true
                }
            ),
            stream = vim.schedule_wrap(
                function(_, data, _)
                    if not data or data == ': OPENROUTER PROCESSING' then
                        return
                    end

                    local json_obj = string.gsub(data, '^data: ', '')
                    if json_obj == '[DONE]' then
                        on_complete()
                    elseif (string.len(data) > 6) then
                        on_delta(vim.fn.json_decode(string.sub(data, 6)))
                    end
                end
            )
        }
    )
end

local function parse_dialogue()
    local ret = {}
    local buffer = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)

    local block = nil
    local patterns = { 
        '^>>%s+(system)$',
        '^>>%s+(user)$',
        '^>>%s+(assistant)$'
    }
    for _, line in ipairs(lines) do
        local role = nil
        for _, pat in ipairs(patterns) do
            role = line:match(pat)
            if role then
                break
            end
        end

        if role then
            if (block) then
                table.insert(ret, block)
            end
            block = {
                role = string.lower(role),
                content = ''
            }
        elseif block then
            block.content = block.content .. line .. '\n'
        end
    end

    if block then
        table.insert(ret, block)
    end

    return ret
end

local function parse_model()
    local ret = nil
    local buffer = vim.api.nvim_get_current_buf()
    local line = vim.api.nvim_buf_get_lines(buffer, 0, 1, false)[1]
    local pattern = '^>>>>%s+(.+)$'

    ret = line:match(pattern)
    if ret then
        ret = string.lower(ret)
    end

    return ret
end

local function send_buffer()
    local messages = parse_dialogue()
    local model = parse_model()

    if not next(messages) then
        print('Buffer has no user/assistant delimiters')
        return
    end

    if not model then
        print('Buffer has no model specifier')
        return
    end

    local buffer = vim.api.nvim_get_current_buf()
    local curline = vim.api.nvim_buf_line_count(buffer)

    vim.api.nvim_buf_set_lines(buffer, curline, curline, false, {
        '',
        '>> assistant',
        'Please wait...'
    })
    curline = vim.api.nvim_buf_line_count(buffer) - 1

    local curline_content = ''

    local on_delta = function(response)
        if response
            and response.choices
            and response.choices[1]
            and response.choices[1].delta
            and response.choices[1].delta.content then

            local delta = response.choices[1].delta.content

            if delta then
                curline_content = curline_content .. delta
            end
        end
    end

    local on_complete = function()
        local new_text = vim.split(curline_content, '\n')

        table.insert(new_text, "")
        table.insert(new_text, ">> user")
        table.insert(new_text, "")

        vim.api.nvim_buf_set_lines(buffer, curline, curline + 1, false, new_text)
    end

    get_llm_completion(model, messages, on_delta, on_complete)
end

local function open_chat_buffer()
    local system_prompt = 
    'You are an assistant tasked with answering any queries.'

    local buffer = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_set_option_value('filetype', 'markdown', {buf = buffer})

    local lines = vim.split(system_prompt, '\n')
    table.insert(lines, 1, '>> system')
    table.insert(lines, 1, '')
    table.insert(lines, 1, '>>>> qwen/qwen3-235b-a22b-thinking-2507')
    table.insert(lines, '')
    table.insert(lines, '>> user')
    table.insert(lines, '')
    vim.api.nvim_buf_set_lines(buffer, 0, -1, true, lines)

    vim.api.nvim_set_current_buf(buffer)
    local new_cursor_pos = vim.api.nvim_buf_line_count(buffer)
    vim.api.nvim_win_set_cursor(0, { new_cursor_pos, 0 })
end

vim.api.nvim_command('command! LLMChatOpen lua require("plugin.chat").LLMChatOpen()')
vim.api.nvim_command('command! LLMChat lua require("plugin.chat").LLMChat()')
vim.api.nvim_command('command! LLMChatToggleWinOpts lua require("plugin.chat").LLMChatToggleWinOpts()')


local M = {}

function M.LLMChatOpen()
    open_chat_buffer()
end

function M.LLMChat()
    send_buffer()
end

function M.LLMChatToggleWinOpts()
    local colorcolumn = vim.api.nvim_get_option_value('colorcolumn', {})
    local linebreak = vim.api.nvim_get_option_value('linebreak', {})
    local breakindent = vim.api.nvim_get_option_value('breakindent', {})

    if colorcolumn == '' then
        vim.api.nvim_set_option_value('colorcolumn', '80', {})
    else
        vim.api.nvim_set_option_value('colorcolumn', '', {})
    end
    vim.api.nvim_set_option_value('linebreak', not linebreak, {})
    vim.api.nvim_set_option_value('breakindent', not breakindent, {})

end

return M
