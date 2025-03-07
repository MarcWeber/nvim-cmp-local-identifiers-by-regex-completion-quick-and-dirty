-- lua/cmp-qad-regex-go.lua
local M = {}

function M:is_available()
  return vim.bo.filetype == "go"
end

function M:get_keyword_pattern()
  return [[\k\+]]
end

M.test_doc = [[
package main

var globalVar int

func main() {
    localVar := 42
    anotherVar := "test"
    for i := 0; i < 10; i++ {
        loopVar := i
    }

    if n, err := strconv.ParseInt(size[:len(size)-2], 10, 64); err == nil {
}
]]

function M:find_keywords(codeLines)
  local patterns = {
    ["var"] = "var%s+([%w_]+)",         -- var declarations
    ["short_var"] = "([%w_]+)%s*:=",    -- short variable declarations
    ["func_args"] = "func%s+([%w_]*)%s*%(([^%)]+)%)",  -- function parameters
    ["type"] = "type%s+([%w_]*)",  -- function parameters
    ["if"] = "if%s*([%w_, ])+%s*:=",     -- for loop variables
  }
  
  local result = {}
  local seen = {}
  
  for i = #codeLines, 1, -1 do
    local line = codeLines[i]
    for _, pattern in pairs(patterns) do
      for match in line:gmatch(pattern) do
        for m in match:gmatch("[^ ,]+") do
          if not seen[m] then
            seen[m] = true
            table.insert(result, {
              qdline = i,
              textEditText = m,
              cmp = { kind_text = "go_local_keyword" },
              label = m
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
  local found = M:find_keywords(lines)
  callback(found)
end

return M
