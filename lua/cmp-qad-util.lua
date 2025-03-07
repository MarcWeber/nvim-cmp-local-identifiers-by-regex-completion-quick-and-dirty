local M = {}

function M.compare_by_line (entry1, entry2)
  local diff = (entry2.completion_item.qdline or 0) - (entry1.completion_item.qdline or 0) 
  if diff < 0 then
    return true
  elseif diff > 0 then
    return false
  end
  return nil
end

M.qd_langs = {"lua", "python", "ruby", "vim", "php", "javascript", "typescript", "shell", "haskell", "nix", "go"}

function M.treesitter_type()
  -- lua print(vim.inspect(require'cmp-qad-util'.treesitter_type()))
  local parsers = require "nvim-treesitter.parsers"
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1
  local col = cursor[2]
  local bufnr = 0
  local root_lang_tree = parsers.get_parser(bufnr)
  local lang_tree = root_lang_tree:language_for_range { line, col, line, col }
  for _, tree in ipairs(lang_tree:trees()) do
    local root = tree:root()
    if root and vim.treesitter.is_in_node_range(root, line, col) then
      local node = root:named_descendant_for_range(line, col, line, col)
      return node:type()
    end
  end
end

return M
