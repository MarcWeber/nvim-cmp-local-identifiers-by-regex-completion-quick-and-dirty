require'nvim-treesitter.configs'.setup {
  ensure_installed = "all",
  highlight = {
    enable = true,
  },
}

-- Define the Treesitter queries
local query_php_array = [[
  ((array
    descendant_of: (parenthesized_expression
      descendant_of: (assignment_expression
        descendant_of: (expression_statement
          descendant_of: (function_call
            descendant_of: (method_call
              descendant_of: (member_expression
                descendant_of: (array_pair)))))))))
]]

local query_python_dict = [[
  ((dictionary
    descendant_of: (dictionary_literal
      descendant_of: (assignment_expression
        descendant_of: (expression_statement)))))
]]


local ts_query = require'nvim-treesitter.query'

local function is_cursor_in_array_or_dict()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local parsed_query_php_array = ts_query.parse_query('php', query_php_array)
  local parsed_query_python_dict = ts_query.parse_query('python', query_python_dict)

  -- Check if the cursor is in a PHP array
  local match_php_array = ts_query.query(bufnr, parsed_query_php_array, cursor[1] - 1, cursor[2], cursor[1] - 1, cursor[2])
  if match_php_array ~= nil and next(match_php_array) ~= nil then
    return true
  end

  -- Check if the cursor is in a Python dictionary
  local match_python_dict = ts_query.query(bufnr, parsed_query_python_dict, cursor[1] - 1, cursor[2], cursor[1] - 1, cursor[2])
  if match_python_dict ~= nil and next(match_python_dict) ~= nil then
    return true
  end

  return false
end
