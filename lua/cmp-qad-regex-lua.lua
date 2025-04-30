local M = {}
function M:is_available()
  return vim.bo.filetype == "lua"
end
function M:get_keyword_pattern()
  return [[\k\+]]
end

M.test_doc = [[
  test file
  function n1(n2, n3){
     local n4 = "abc"
  }
]]

function M:find_keywords(codeLines, word_before_cursor)
  local patterns = {
    ["function_name_and_args"] = "function%s+([%w_.:]+)%s*%(([^)]+)%)",
    ["local_var"] = "local%s+([%w_]+)%s*=",
    ["for_assign"] = "for%s*([%w_]+),%s*([%w_]+)%s*in"
  }
  local result = {}
  local seen = {}
  for i = #codeLines, 1, -1 do
    -- for i = 1, #codeLines, 1 do
    local line = codeLines[i]
    for patternDesc, pattern in pairs(patterns) do
      local matches = { line:match(pattern) }
      if #matches > 0 then
        for _, match in ipairs(matches) do
          for m in string.gmatch(match, "[^ ,]+") do
            if not seen[m] and not (i == #codeLines and m == word_before_cursor) then
              seen[m] = true
              table.insert(result, { qdline = i, textEditText = m, cmp = { kind_text ="lua_local_keyword " .. i }, label = string.sub(m, 1, 999), priority = i })
            end
          end
        end
      end
    end
  end
  return result
end
function M:complete(params, callback)
  local line = params.context.cursor.line
  local lines = vim.api.nvim_buf_get_lines(0, 0, line + 1, 0)

  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1
  local col = cursor[2]
  local before_cursor = string.sub(lines[#lines], 1, col)
  local word_before_cursor = before_cursor:match("%w+$")

  local found = M:find_keywords(lines, word_before_cursor)
  callback(found)
end
return M
