local M = {}

M.merge_tables = function(f, s)
  for k, v in pairs(s) do f[k] = v end
  return f
end

return M
