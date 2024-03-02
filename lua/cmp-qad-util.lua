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

M.qd_langs = {"lua", "python", "ruby", "vim", "php", "javascript", "typescript", "shell"}

return M
