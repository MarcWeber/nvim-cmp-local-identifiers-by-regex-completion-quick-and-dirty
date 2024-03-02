local M = {}
function M:is_available()
  local f = vim.bo.filetype
  print(f .. " f ")
  return (f == "zsh") or (f == "sh")
end
function M:get_keyword_pattern()
  return [[\k\+]]
end
M.test_doc = [[
  M1=A
  local M2=A
  export M3=A
  M3(){
  }
  alias M4 neovim
]]
M.expected = { }

function M:find_keywords(codeLines)
  local patterns = {
    ["env_assignment"] = "([%w_]+)=",
    ["fun"] = "([%w_]+)%(",
    ["alias"] = "alias ([%w_]+)",
  }
  local result = {}
  local seen = {}
  for i = #codeLines, 1, -1 do
   
    local line = codeLines[i]
    for patternDesc, pattern in pairs(patterns) do
      local dp = patternDesc:match("env_assignment")
      print(dp)
      local addp = function(m)
        table.insert(result, { qdline = i, textEditText = m, cmp = { kind_text = "typescript_local_keyword" .. i }, label = string.sub(m, 1, 999) })
      end
      local add = function (m)
        -- ${ABC:-X} "${ABC}" etc are snippets ?
        -- if dp then
        --   print("ifdp " .. m)
        --   addp("\"$" .. m .. "\"") -- not within strings
        --   addp("${" .. m .. "}")
        --   addp("$" .. m)
        -- end
        addp(m)
      end
      local matches = { line:match(pattern) }
      if #matches > 0 then
        for _, match in ipairs(matches) do
          for m in string.gmatch(match, "[^ ,]+") do
            if not seen[m] then
              seen[m] = true
              add(m)
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
  found = M:find_keywords(lines)
  callback(found)
end

return M
