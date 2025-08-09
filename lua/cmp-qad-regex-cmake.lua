-- lua/cmp-qad-regex-cmake.lua
local M = {}

function M:is_available()
  return vim.bo.filetype == "cmake"
end

function M:get_keyword_pattern()
  return [[\k\+]]
end

M.test_doc = [[
set(MY_VAR "value")
set(PROJECT_NAME "MyProject")
set(SOURCE_FILES main.c utils.c)

if(MY_VAR)
  set(ANOTHER_VAR "test")
endif()
]]

function M:find_keywords(codeLines, word_before_cursor)
  local patterns = {
    ["set"] = "set%(([%w_]+)",  -- set() definitions
    ["variable"] = "%${([%w_]+)}",  -- ${VARIABLE} references
    ["if"] = "if%(([%w_]+)%)",  -- if(VARIABLE)
  }
  
  local result = {}
  local seen = {}
  
  for i = #codeLines, 1, -1 do
    local line = codeLines[i]
    for _, pattern in pairs(patterns) do
      for match in line:gmatch(pattern) do
        for m in match:gmatch("[^ ,]+") do
          if not seen[m] and not (i == #codeLines and m == word_before_cursor) then
            seen[m] = true
            -- Add plain variable first
            table.insert(result, {
              qdline = i,
              textEditText = m,  -- Complete as plain VARIABLE
              cmp = { kind_text = "cmake_variable" },
              label = m
            })
            -- Add ${VARIABLE} second
            table.insert(result, {
              qdline = i,
              textEditText = "${" .. m .. "}",  -- Complete as ${VARIABLE}
              cmp = { kind_text = "cmake_variable" },
              label = "${" .. m .. "}"
            })
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
  local word_before_cursor = before_cursor:match("%w+$") or ""

  local found = M:find_keywords(lines, word_before_cursor)
  callback(found)
end

return M
