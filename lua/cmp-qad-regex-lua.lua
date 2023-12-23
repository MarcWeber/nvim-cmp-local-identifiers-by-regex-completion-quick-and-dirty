local lualocalkeywords = {}
function lualocalkeywords:is_available()
  return vim.bo.filetype == "lua"
end
function lualocalkeywords:get_keyword_pattern()
  return [[\k\+]]
end
local function lua_find_keywords(codeLines)
  -- test file
  -- function n1(n2, n3){
  --    local n4 = "abc"
  -- }
  local patterns = {
    ["function_name_and_args"] = "function%s+([%w_]+)%s*%(([^)]+)%)",
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
          for i in string.gmatch(match, "[^ ,]+") do
            if not seen[i] then
              seen[i] = true
              table.insert(result, { textEditText = i, cmp = { kind_text ="lua_local_keyword" }, label = string.sub(i, 1, 999) })
            end
          end
        end
      end
    end
  end
  return result
end
function lualocalkeywords:complete(params, callback)
  line = params.context.cursor.line
  lines = vim.api.nvim_buf_get_lines(0, 0, line + 1, 0)
  found = lua_find_keywords(lines)
  callback(found)
end
return lualocalkeywords
