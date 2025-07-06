local curl = require('plenary.curl')
local M = {}

local function get_llm_completion(messages, on_delta, on_complete)
    local completions = curl.post(
        'https://openrouter.ai/api/v1/chat/completions',
        {
            headers = 
            {
                Authorization = 'Bearer ' .. vim.env.OPENROUTER_API_KEY,
            },
            body = vim.fn.json_encode(
                {
                    model = 'google/gemini-2.5-flash',
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

local function parse_markdown()
    local ret = {}
    local buffer = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)

    local block = nil
    for _, line in ipairs(lines) do
        if line:match("^#%s+(.*)$") then
            local role = line:match("^#%s+(.*)$")
            if (block) then
                table.insert(ret, block)
            end
            block = {
                role = string.lower(role),
                content = ""
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


local function send_buffer()
    local messages = parse_markdown()

    if not next(messages) then
        print('Buffer has no user/assistant markdown headers')
        return
    end

    local buffer = vim.api.nvim_get_current_buf()
    local curline = vim.api.nvim_buf_line_count(buffer)

    vim.api.nvim_buf_set_lines(buffer, curline, curline, false, {
        '',
        '# assistant',
        'Connecting to OpenRouter...'
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
        table.insert(new_text, "# user")
        table.insert(new_text, "")

        vim.api.nvim_buf_set_lines(buffer, curline, curline + 1, false, new_text)
    end

    get_llm_completion(messages, on_delta, on_complete)
end

function M.LLMChat()
    send_buffer()
end

vim.api.nvim_command('command! LLMChat lua require("chat").LLMChat()')

return M
