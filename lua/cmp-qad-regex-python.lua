local M = {}
function M:is_available()
  return vim.bo.filetype == "python"
end
function M:get_keyword_pattern()
  return [[\k\+]]
end
M.test_doc = [[
  def foobar():
  abc = "abc"
  ccc, ddd = zooor
  for aaa, bbb in zoo:
]]
M.expected = { }

function M:find_keywords(codeLines)
  local patterns = {
    ["for_x_in"] = "for%s+([%w_,%s]+)%s+in", -- .* for cases like $abc['foo'][] = 8;
    ["assignment"] = "([%w_,%s]+)=%s*",
    ["def"] = "def%s+([%w_]+)%(",
  }
  local result = {}
  local seen = {}
  for i = #codeLines, 1, -1 do
    -- for i = 1, #codeLines1, 1 do
    local line = codeLines[i]
    for patternDesc, pattern in pairs(patterns) do
      local matches = { line:match(pattern) }
      if #matches > 0 then
        for _, match in ipairs(matches) do
          for m in string.gmatch(match, "[^ ,]+") do
            if not seen[m] then
              seen[m] = true
              table.insert(result, { textEditText = m,  cmp = { kind_text ="python_local_keyword " .. i }, label = string.sub(m, 1, 999) })
            end
          end
        end
      end
    end
  end
  return result
end
function M:complete(params, callback)
  line = params.context.cursor.line
  lines = vim.api.nvim_buf_get_lines(0, 0, line + 1, 0)
  found = find_keywords(lines)
  callback(found)
end
return M
