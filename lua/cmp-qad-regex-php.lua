local phplocalkeywords = {}
function phplocalkeywords:is_available()
  return vim.bo.filetype == "php"
end
function phplocalkeywords:get_keyword_pattern()
  return [[\k\+]]
end
local function php_find_keywords(codeLines)
  -- test file
  -- function n1(){
  -- }
  -- function ($n2, $$n3, $n4)use(&$n5, $n6){
  --   if ($n12 = "abc"){ }
  --   $n13[foo()] = 20;
  --   static $n7, $n8;
  --   $n9 = "abc";
  -- };
  -- try {
  -- } catch (Exception $n10){
  -- }
  -- preg_match("/foo/", $bar, $n11);  // if pattern or string is function call this fails R695106136 hard to match if you use function calls or such maybe extend with treesitter or such ? but might catch many cases
  local patterns = {
    ["var_assignment"] = "($[%w_]+)%[.*=", -- .* for cases like $abc['foo'][] = 8;
    ["expr_assignment"] = "($[%w_]+)%s+= ", -- if ($x = true){.. x is defined)
    ["global"] = "global ([^;]+)",
    ["static_var"] = "static ($[%w_]+)",
    ["in_list"] = "list%(([^)]+)%)",
    ["foreachkv"] = "as%s+($[%w_]+)%s+=>%s+($[%w_]+)",
    ["foreachv"] = "as%s+($[%w_]+)",
    ["function_name_and_args"] = "function%s+([%w_.]+)%s*%(([^)]+)%)",
    ["function_no_name_args"] = "function%s*%(([^)]+)%)",
    ["constructor_args"] = "__construct%s*%(([^)]+)%)",
    ["fn"] = "fn%((%$[%w_]+)%)",
    ["use"] = "use%(([^)]+)%)",
    ["catch"] = "catch%s*%([^ ]+%s+($[%w_]+)%)",
    ["preg_match_last"] = "preg_match%s*%(.*,%s*($[%w_]+)%)", -- R695106136
    ["define"] = "define%(['\"]([^'\"]+)['\"]",
  }
  local result = {}
  local seen = {}
  local function add(i, sub, line)
    if not seen[i] then
      seen[i] = true
      table.insert(result, { textEditText = i,  cmp = { kind_text ="php_local_keyword " .. line }, label = string.sub(i, sub,  999) })
    end
  end
  for i = #codeLines, 1, -1 do
    -- for i = 1, #codeLines , 1 do
    local line = codeLines[i]
    for patternDesc, pattern in pairs(patterns) do
      local matches = { line:match(pattern) }
      if #matches > 0 then
        for _, match in ipairs(matches) do
          for m in string.gmatch(match, "[^ ,]+") do
            if string.sub(m, 1, 1) == '&' then
              m = string.sub(m, 2)
            end
            if string.sub(m, 1, 3) == '...' then -- ...$args case
              add(string.sub(m, 4), 1, i)
              add(m, 0, i)
            else
              add(m, 1, i)
            end
          end
        end
      end
    end
  end
  return result
end
function phplocalkeywords:complete(params, callback)
  line = params.context.cursor.line
  lines = vim.api.nvim_buf_get_lines(0, 0, line + 1, 0)
  found = php_find_keywords(lines)
  callback(found)
end
print("returning phplocalkeywords")
return phplocalkeywords
