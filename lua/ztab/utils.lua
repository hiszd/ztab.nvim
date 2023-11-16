---@type boolean
local debug = true
---@type number
-- local count = 0

local M = {}

M.setDebug = function(d) debug = d end

M.dP = function(...)
  if debug then
    print(vim.inspect(...))
    -- count = count + 1
  else
    print("Debug disabled")
  end
end

return M
