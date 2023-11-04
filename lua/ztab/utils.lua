---@type boolean
local debug = require('ztab').helpers.__config.debug

local M = {}

M.dP = function(...)
  if debug then
    print(vim.inspect(...))
  end
end

return M
