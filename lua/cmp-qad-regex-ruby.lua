local M = {}
function M:is_available()
  return vim.bo.filetype == "ruby"
end
function M:get_keyword_pattern()
  return [[\k\+]]
end

M.test_doc = [[
  $N9 = 7
  N10 = 7
  N8 = 20 # duplicate !
  abc[:N8] = 7
  x = N13
  def name(N3, N4)
  end
  max_recursion = options.fetch(:max_recursion, 5)
  class N12
    def
      @N5 = 
      @@N6 = 
    end
  end
  lambda{|N1,N2, N11| .. }
]]

M.expected = 
{ { "N1", "N1" },
 { "N2", "N2" },
 { "N11", "N11" },
 { "@@N6", "@N6" },
 { "@N5", "N5" },
 { "N12", "N12" },
 { "max_recursion", "max_recursion" },
 { ":max_recursion", ":max_recursion" },
 { "name", "name" },
 { "N3", "N3" },
 { "N4", "N4" },
 { "x", "x" },
 { ":N8", ":N8" },
 { "N8", "N8" },
 { "N10", "N10" },
 { "N9", "N9" } 
}

function M:find_keywords(codeLines)
  local patterns = {
    -- [%w@:]+
    ["assignment"] = "([%w_@:]+)%s*=", -- .* for cases like $abc['foo'][] = 8;
    ["assignment2"] = "([%w_@:]+)%s*||=", -- .* for cases like $abc['foo'][] = 8;
    ["def_class"] = "class%s*([%w_]+)", -- .* for cases like $abc['foo'][] = 8;
    ["def_arg"] = "def%s*([%w_]+)%s*([^%)]*)", -- .* for cases like $abc['foo'][] = 8;
    ["key_in_array"] = "(:[%w_]+)", -- .* for cases like $abc['foo'][] = 8;
    ["lambda_args"] = "%|([^%|]+)%|", -- .* for cases like $abc['foo'][] = 8;
  }
  local result = {}
  local seen = {}
  local function add(m, label, i)
    if not seen[m] then
      seen[m] = true
      table.insert(result, { qdline = i, insertText = m, textEditText = m,  kind="ruby_local_keyword " .. i, label = label })
    end
  end
  for i = #codeLines, 1, -1 do
    -- for i = 1, #codeLines1, 1 do
    local line = codeLines[i]
    for patternDesc, pattern in pairs(patterns) do
      local matches = { line:match(pattern) }
      if #matches > 0 then
        for _, match in ipairs(matches) do
          for m in string.gmatch(match, "[^ ,]+") do
            m = string.gsub(m, "[({})]", "")
            if not seen[m] and not (m == "=>" ) and not (m == "as") and not (m == "*") then
              local i_no_colon = m:gsub("^:", "")
              i_no_colon = m:gsub("^$", "")
              i_no_colon = m:gsub("^@", "")
              i_no_colon = m:gsub("^@", "")
              add(m, i_no_colon, i)
              add(m, m, i)
            end
          end
        end
      end
    end
  end
  -- print(vim.inspect(result))
  return result
end
function M:complete(params, callback)
  line = params.context.cursor.line
  lines = vim.api.nvim_buf_get_lines(0, 0, line + 1, 0)
  found = M:find_keywords(lines)
  callback(found)
end
return M
