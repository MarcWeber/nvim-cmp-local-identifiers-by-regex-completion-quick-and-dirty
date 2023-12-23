local typescriptlocalkeywords = {}
function typescriptlocalkeywords:is_available()
  return vim.bo.filetype == "typescript"
end
function typescriptlocalkeywords:get_keyword_pattern()
  return [[\k\+]]
end
local function typescript_find_keywords(codeLines)
  -- const N1 = 7
  -- const [N3, N2] = [1,2]
  -- const {N4, N5} = 7
  -- let N6 = 7
  -- var N7 = 7
  -- const N8 = 7
  -- (N9) => ..
  -- (N10: Array<Number>) => ..
  -- function(N17: Array<Number>) => ..
  -- for (let N11 of [2])
  -- for (let N12 in {"a": 20})
  -- import {N15,N16} from ..
  -- import * as N13 from ..
  -- import * as N14 from ..
  local patterns = {
    ["assignment_keyword_const"] = "const%s+([%w_]+)%s+=", -- .* for cases like $abc['foo'][] = 8;
    ["assignment_keyword_var"] = "var%s+([%w_]+)%s+=", -- .* for cases like $abc['foo'][] = 8;
    ["assignment_keyword_let"] = "let%s+([%w_]+)%s+=", -- .* for cases like $abc['foo'][] = 8;
    ["assignment_list_const"] = "const%s+%[([^%]]+)%]", -- .* for cases like $abc['foo'][] = 8;
    ["assignment_list_var"] = "var%s+%[([^%]]+)%]", -- .* for cases like $abc['foo'][] = 8;
    ["assignment_list_let"] = "let%s+%[([^%]]+)%]", -- .* for cases like $abc['foo'][] = 8;
    ["assignment_dict_const"] = "const%s+{([^}]+)}", -- .* for cases like $abc['foo'][] = 8;
    ["assignment_dict_var"] = "var%s+{([^}]+)}", -- .* for cases like $abc['foo'][] = 8;
    ["assignment_dict_let"] = "let%s+{([^}]+)}", -- .* for cases like $abc['foo'][] = 8;
    ["lambda_args"] = "%([^%)]+%)%s*=>", -- .* for cases like $abc['foo'][] = 8;
    ["function_args"] = "function%([^%)]+%)", -- .* for cases like $abc['foo'][] = 8;
    ["assignment_list_const"] = "const%s+([%w_]+)", -- .* for cases like $abc['foo'][] = 8;
    ["assignment_list_var"] = "var%s+([%w_]+)", -- .* for cases like $abc['foo'][] = 8;
    ["assignment_list_let"] = "let%s+([%w_]+)", -- .* for cases like $abc['foo'][] = 8;
    ["for_var"] = "for%s*%(var%s+(([^)%]}]+)%)", -- .* for cases like $abc['foo'][] = 8;
    ["for_const"] = "for%s*%(const%s+(([^)%]}]+)%)", -- .* for cases like $abc['foo'][] = 8;
    ["for_let"] = "for%s*%(let%s+(([^)%]}]+)%)", -- .* for cases like $abc['foo'][] = 8;
    ["import"] = "import%s+(.*)%sfrom", -- .* for cases like $abc['foo'][] = 8;
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
          for i in string.gmatch(match, "[^ ,]+") do
            i = string.gsub(i, "[({}):]", "")

            if not seen[i] and not (i == "=>" ) and not (i == "as") and not (i == "*") then
              seen[i] = true
              table.insert(result, { textEditText = i, cmp { kind_text ="typescript_local_keyword" }, label = string.sub(i, 1, 999) })
            end
          end
        end
      end
    end
  end
  return result
end
function typescriptlocalkeywords:complete(params, callback)
  line = params.context.cursor.line
  lines = vim.api.nvim_buf_get_lines(0, 0, line + 1, 0)
  found = typescript_find_keywords(lines)
  callback(found)
end

return typescriptlocalkeywords
