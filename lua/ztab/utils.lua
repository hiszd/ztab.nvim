---@type boolean
local debug = false

local M = {}

M.setDebug = function(d) debug = d end

M.dP = function(...)
  if debug then
    print(vim.inspect(...))
  end
end

return M
