---@type boolean
local debug = false

local M = {}

M.dP = function(...)
  if debug then
    print(vim.inspect(...))
  end
end

return M
