local M = {}
function M:is_available()
    return vim.bo.filetype == "nix"
end

function M:get_keyword_pattern()
    return [[\k\+]]
end

M.test_doc = [[
  test file
  let
    var1 = "value";
    nested.attr = 42;
    func1 = arg: arg + 1;
    complex = { a, b }: a + b;
  in
  {
    output = value;
    inherit (pkgs) var1 func1;
  }
]]

M.expected = {}

function M:find_keywords(codeLines)
    local patterns = {
        -- F1: Assignment patterns
        ["simple_assign"] = "([%w_%.]+)%s*=%s*[^;]+;",           -- var = value;
        ["nested_assign"] = "([%w_%.]+%.[%w_%.]+)%s*=%s*[^;]+;", -- nested.attr = 42;
        
        -- F2: Function patterns
        ["func_single"] = "([%w_]+)%s*=%s*([^:%s]+)%s*:",        -- func1 = arg: ...
        ["func_multi"] = "([%w_]+)%s*=%s*%{%s*([^%}]+)%s*}:",    -- complex = { a, b }: ...
        
        -- Additional useful Nix patterns
        ["inherit"] = "inherit%s+%([^%)]+%)%s+([^;]+)",          -- inherit (pkgs) var1 func1
        ["attr_set"] = "{([^}]+)}",                              -- { output = value; }
    }
    
    local result = {}
    local seen = {}
    
    local function add(item, sub, line)
        if not seen[item] then
            seen[item] = true
            table.insert(result, {
                qdline = line,
                textEditText = item,
                cmp = { kind_text = "nix_local_keyword " .. line },
                label = string.sub(item, sub, 999)
            })
        end
    end
    
    for i = #codeLines, 1, -1 do
        local line = codeLines[i]
        for patternDesc, pattern in pairs(patterns) do
            local matches = { line:match(pattern) }
            if #matches > 0 then
                for _, match in ipairs(matches) do
                    if patternDesc == "inherit" or patternDesc == "attr_set" then
                        -- Split multiple items in inherit or attr sets
                        for m in string.gmatch(match, "[%w_%.]+") do
                            add(m, 1, i)
                        end
                    elseif patternDesc == "func_multi" then
                        -- Handle function with multiple args { a, b }
                        local fname = matches[1]
                        local args = matches[2]
                        add(fname, 1, i)
                        for arg in string.gmatch(args, "[%w_]+") do
                            add(arg, 1, i)
                        end
                    else
                        add(match, 1, i)
                    end
                end
            end
        end
    end
    
    -- Add the specific scope transformation you requested
    for _, item in ipairs(result) do
        if item.label:match("^[%w_]+$") then
            table.insert(result, {
                qdline = item.qdline,
                textEditText = "inherit (pkgs) " .. item.label .. ";",
                cmp = { kind_text = "nix_inherit_scope" },
                label = "inherit (pkgs) " .. item.label
            })
        end
    end
    
    return result
end

function M:complete(params, callback)
    local line = params.context.cursor.line
    local lines = vim.api.nvim_buf_get_lines(0, 0, line + 1, 0)
    local found = M:find_keywords(lines)
    callback(found)
end

return M
