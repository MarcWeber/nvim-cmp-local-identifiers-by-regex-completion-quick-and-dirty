-- TODO enable tests for all languages
-- local qd_langs = {"lua", "python", "ruby", "vim", "php", "javascript", "typescript"}
-- local qd_langs = {"python"}
local qd_langs = {"javascript"}

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
  local m = require('cmp-qad-regex-' .. v)
  local found = {}
  local test_doc = [[
const fs = require('fs')

let programm = ""

const befehle = (x) => programm = programm += `\n${programm}`

const start = () => befehle(`
G17
G0 X0 Y0 Z0
G91
`)

const commentar = (x) =>  console.log(`% ${x}`);
const breite = 50

const linie = (hoehe) => befehle(`
    G1 Y${hoehe}
    G1 Y-${hoehe}
`)

// HIER DAS PROGRAMM SCHREIBEN
start()
for (let i = 1; i <= 10 ; i++) {
  commentar(`Linie nr ${i} hoehe ${i}`)
  linie(i)
  befehle(`G1 X1`)
}

fs.writeFileSync("/tmp/datei.gcode")
  ]]

  local lines = iterator_to_array(string.gmatch(test_doc, "[^\n]+"))
end

print("test complete")
