local M = {}
function M:is_available()
  return vim.bo.filetype == "typescript"
end
function M:get_keyword_pattern()
  return [[\k\+]]
end
M.test_doc = [[
  const N1 = 7
  const [N3, N2] = [1,2]
  const {N4, N5} = 7
  let N6 = 7
  var N7 = 7
  const N8 = 7
  (N9) => ..
  (N10: Array<Number>) => ..
  function(N17: Array<Number>) => ..
  for (let N11 of [2])
  for (let N12 in {"a": 20})
  import {N15,N16} from ..
  import * as N13 from ..
  import * as N14 from ..
]]
M.expected = { }

function M:find_keywords(codeLines)
  local patterns = {
    ["assignment_keyword_const"] = "const%s+([%w_]+)%s+=", -- .* for cases like $abc['foo'][] = 8;
    ["assignment_keyword_var"] = "var%s+([%w_]+)%s+=", -- .* for cases like $abc['foo'][] = 8;
    ["assignment_keyword_let"] = "let%s+([%w_]+)%s+=", -- .* for cases like $abc['foo'][] = 8;
    ["assignment_list_const"] = "const%s+%[([^%]]+)%]", -- .* for cases like $abc['foo'][] = 8;
    ["assignment_list_var"] = "var%s+%[([^%]]+)%]", -- .* for cases like $abc['foo'][] = 8;
    ["assignment_list_let"] = "let%s+%[([^%]]+)%]", -- .* for cases like $abc['foo'][] = 8;
    ["assignment_dict_const"] = "const%s+{([^}]+)}", -- .* for cases like $abc['foo'][] = 8;
    ["assignment_dict_var"] = "var%s+{([^}]+)}", -- .* for cases like $abc['foo'][] = 8;
    -- ["assignment_dict_let"] = "let%s+{([^}]+)}", -- .* for cases like $abc['foo'][] = 8;
    -- ["lambda_args"] = "%([^%)]+%)%s*=>", -- .* for cases like $abc['foo'][] = 8;
    -- ["function_args"] = "function%([^%)]+%)", -- .* for cases like $abc['foo'][] = 8;
    -- ["assignment_list_const"] = "const%s+([%w_]+)", -- .* for cases like $abc['foo'][] = 8;
    -- ["assignment_list_var"] = "var%s+([%w_]+)", -- .* for cases like $abc['foo'][] = 8;
    -- ["assignment_list_let"] = "let%s+([%w_]+)", -- .* for cases like $abc['foo'][] = 8;
    -- ["for_var"] = "for%s*%(var%s+(([^)%]}]+)%)", -- .* for cases like $abc['foo'][] = 8;
    -- ["for_const"] = "for%s*%(const%s+(([^)%]}]+)%)", -- .* for cases like $abc['foo'][] = 8;
    -- ["for_let"] = "for%s*%(let%s+(([^)%]}]+)%)", -- .* for cases like $abc['foo'][] = 8;
    -- ["import"] = "import%s+(.*)%sfrom", -- .* for cases like $abc['foo'][] = 8;
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
            m = string.gsub(m, "[({}):]", "")

            if not seen[m] and not (m == "=>" ) and not (m == "as") and not (m == "*") then
              seen[m] = true
              table.insert(result, { textEditText = m, cmp = { kind_text = "typescript_local_keyword" .. i }, label = string.sub(m, 1, 999) })
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
