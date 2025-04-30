local M = {}

-- maybe something like hasktags running is better option ?

function M:is_available()
  return vim.bo.filetype == "haskell"
end
function M:get_keyword_pattern()
  return [[\k\+]]
end
M.test_doc = [[
module Main where
import Glob

csvFiles :: IO [String]
csvFiles = do
  let glob = "/home/marc/projects-checked-out/jobvers/data-jobvers-subversion/csvs/altes-chaos/**/*.csv"
  Glob glob

parseSpeedTest = do
    files <- csvFiles

main :: IO ()
main = putStrLn "Hello, Haskell!"
]]
M.expected = { }

function M:find_keywords(codeLines, word_before_cursor)
  local ts_type = require'cmp-qad-util'.treesitter_type()
  -- { z } is treated as set, not as dictionary :-(
  local in_dictionary = ts_type == "dictionary" or ts_type == "set"

  local patterns = {
    ["let"] = "let%s+([%w_,%s]+)%s", -- .* for cases like $abc['foo'][] = 8;
    ["fun1"] = "([%w_,%s]+)%s+::",
    ["fun2"] = "([%w_,%s]+)%s+=",
    ["monad_assignment"] = "([%w_,%s]+)%s<-",
    ["lambda_args"] = "\\%s*([%w_,%s]+)%s*->",
    -- TODO import lines etc
  }
  local result = {}
  local seen = {}
  for i = #codeLines, 1, -1 do
    -- for i = 1, #codeLines1, 1 do
    local line = codeLines[i]

    local function add(s)
      table.insert(result, { qdline = i, textEditText = s,  cmp = { kind_text = "haskell_local_keyword " .. i }, label = s})
    end

    for patternDesc, pattern in pairs(patterns) do
      local matches = { line:match(pattern) }
      if #matches > 0 then
        for _, match in ipairs(matches) do
          for m in string.gmatch(match, "[^ ,]+") do
            if not seen[m] and not (i == #codeLines and m == word_before_cursor) then
              seen[m] = true
              add(m)
              if in_dictionary then
                add("'" .. m .. "' : " .. m .. ',')
              end
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

  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1
  local col = cursor[2]
  local before_cursor = string.sub(lines[#lines], 1, col)
  local word_before_cursor = before_cursor:match("%w+$")

  found = M:find_keywords(lines, word_before_cursor)
  callback(found)
end
return M
