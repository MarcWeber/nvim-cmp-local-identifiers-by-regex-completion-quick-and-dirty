local vimllocalkeywords = {}
function vimllocalkeywords:is_available()
  return vim.bo.filetype == "vim"
end
function vimllocalkeywords:get_keyword_pattern()
  return [[\k\+]]
end
local function viml_find_keywords(codeLines)
  -- let g:abc
  -- let s:abc
  -- fun n1(n2, n3)
  --    let n4 = "abc"
  -- endf
  -- fun n6()
  --    let n4 = "abc"
  -- endf
  local patterns = {
    -- TODO
    ["function_name_and_args"] = "fun%s+([%w_:]+)%s*%(([^)]+)%)",
    ["local_var"] = "let%s+([%w_:]+)%s*=",
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
              table.insert(result, { textEditText = i,  cmp = { kind_text ="viml_local_keyword" }, label = string.sub(i, 1, 999) })
            end
          end
        end
      end
    end
  end
  return result
end
function vimllocalkeywords:complete(params, callback)
  line = params.context.cursor.line
  lines = vim.api.nvim_buf_get_lines(0, 0, line + 1, 0)
  found = viml_find_keywords(lines)
  callback(found)
end
return vimllocalkeywords
