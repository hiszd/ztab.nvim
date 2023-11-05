local highlight = require("ztab.highlight")
local constants = require("ztab.constants")
local dP = require("ztab.utils").dP

local M = {}

---------------------------------------------------------------------------//
-- Setup Function
---------------------------------------------------------------------------//
---@param C ZConfig #Current config
---@param opts ZConfig #Setup options
---@return table #Return entire module
M.setup = function(C, opts)
  C = vim.tbl_deep_extend("force", C, opts or {})

  if C.opts.debug then
    require('ztab.utils').setDebug(true)
  end

  for i, hlgrp in pairs(C.tabline.highlight) do
    if constants.highlight_names[i] then
      highlight.update_component_highlight_group(hlgrp, constants.highlight_names[i], true, false, true)
    end
  end
  for i, hlgrp in pairs(C.bufline.highlight) do
    if constants.highlight_names[i] then
      highlight.update_component_highlight_group(hlgrp, constants.highlight_names[i], true, true, false)
    end
  end

  if C.tabline.enabled then
    vim.opt.tabline = "%!v:lua.require'ztab.tabline'.draw()"
  end
  if C.bufline.enabled then
    vim.opt.winbar = "%!v:lua.require'ztab.bufline'.draw()"
  end


  return C
end

return M
