-- TODO enable tests for all languages
-- local qd_langs = {"lua", "python", "ruby", "vim", "php", "javascript", "typescript"}
-- local qd_langs = {"python"}
-- local qd_langs = {"javascript"}
local qd_langs = {"php"}

local function iterator_to_array(...)
  local arr = {}
  for v in ... do
    table.insert(arr, v)
  end
  return arr
end

-- load with load("return ..".. str)
function serialize(thing)
  local function s(value)
    if type(value) == "table" then
      local str = "{"
      local comma = ""
      for k, v in pairs(value) do
        str = str .. comma
        if type(k) == "number" then
          str = str .. "[" .. k .. "]="
        elseif type(k) == "string" then
          str = str .. k .. "="
        else
          -- Unsupported key type
          error("Unsupported key type: " .. type(k))
        end

        str = str .. s(v)
        comma = ","
      end
      return str .. "}"
    elseif type(value) == "number" or type(value) == "boolean" then
      return tostring(value)
    elseif type(value) == "string" then
      return string.format("%q", value)
    elseif nil==value then
      return "nil"
    else
      -- Unsupported value type
      error("Unsupported value type: " .. type(value))
    end
  end

  return s(thing)
end

for i,v in ipairs(qd_langs) do
  print("testing " .. v)

  local m = require('cmp-qad-regex-' .. v)

  local found = {}
  local lines = iterator_to_array(string.gmatch(m.test_doc, "[^\n]+"))
  for _, v in ipairs(m:find_keywords(lines)) do
    table.insert(found, {v.insertText, v.label} )
  end
  if not (serialize(found) == serialize(m.expected)) then
    print("FAILED: " .. v)
    print("expected")
    print(vim.inspect(m.expected))

    print("got")
    print(vim.inspect(found))
  end
end

print("test complete")
