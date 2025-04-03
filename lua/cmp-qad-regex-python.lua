-- TODO: 
--       def inode_to_path(self, inode: InodeT) -> str:
local M = {}
function M:is_available()
  return vim.bo.filetype == "python"
end
function M:get_keyword_pattern()
  return [[\k\+]]
end
M.test_doc = [[
  def foobar(folder):
  abc = "abc"
  ccc, ddd = zooor
  for aaa, bbb in zoo:
  class SimpleKeyValueStoragePickle:

  def gui(app_state: AppState):
      for w in app_state.windows:
]]
M.expected = { }

function M:find_keywords(codeLines)
  local ts_type = require'cmp-qad-util'.treesitter_type()
  -- { z } is treated as set, not as dictionary :-(
  local in_dictionary = ts_type == "dictionary" or ts_type == "set"

  local patterns = {
    ["for_x_in"] = "for%s+([%w_,%s]+)%s+in", -- .* for cases like $abc['foo'][] = 8;
    ["assignment"] = "([%w_,%s]+)=%s*",
    ["def"] = "def%s+([%w_]+)%(([%w_,:%s]+)%)",
    ["class"] = "class%s+([%w_]+)",
  }
  local result = {}
  local seen = {}
  for i = #codeLines, 1, -1 do
    -- for i = 1, #codeLines1, 1 do
    local line = codeLines[i]

    local function add(s)
      table.insert(result, { qdline = i, textEditText = s,  cmp = { kind_text ="python_local_keyword " .. i }, label = s})
    end

    for patternDesc, pattern in pairs(patterns) do
      local matches = { line:match(pattern) }
      if #matches > 0 then
        for _, match in ipairs(matches) do
          for m in string.gmatch(match, "[^ ,]+") do
            m = string.gsub(m, "[:]", "")
            if not seen[m] then
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
  found = M:find_keywords(lines)
  callback(found)
end
return M
