local curl = require('plenary.curl')
local M = {}

local function get_llm_completion(messages)
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
					messages = messages
				}
			)
		}
	)

	if (completions) then
		return vim.fn.json_decode(completions.body)
	end

	return nil
end

local function parseMarkdown()
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
	local messages = parseMarkdown()
	local buffer = vim.api.nvim_get_current_buf()
	local curline = vim.api.nvim_buf_line_count(buffer)

	local response = get_llm_completion(messages)

	if (response) then
		vim.fn.json_encode(response)

		local lines_to_add = vim.split(
			response.choices[1].message.content, '\n'
		)
		table.insert(lines_to_add, 1, "# assistant")
		table.insert(lines_to_add, 1, "")
		table.insert(lines_to_add, "")
		table.insert(lines_to_add, "# user")
		table.insert(lines_to_add, "")

		vim.api.nvim_buf_set_lines(
			buffer,
			curline,
			curline,
			false,
			lines_to_add
		)
	end
end

function M.LLMChat()
	send_buffer()
end

vim.api.nvim_command('command! RunLLM lua require("chat").LLMChat()')

return M
