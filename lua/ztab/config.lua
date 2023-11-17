local highlight = require("ztab.highlight")
local constants = require("ztab.constants")
local utils = require("ztab.utils")

local M = {}

---------------------------------------------------------------------------//
-- Setup Function
---------------------------------------------------------------------------//
---@param C ZConfig #Current config
---@param opts ZSetupOpts #Setup options
---@return table #Return entire module
M.setup = function(C, opts)
  local bufhlbf = C.bufline.highlight
  ---@type ZConfig
  C.opts = vim.tbl_deep_extend("force", C.opts, opts)
  C.tabline = vim.tbl_deep_extend("force", C.tabline, opts.tabline or {})
  C.bufline = vim.tbl_deep_extend("force", C.bufline, opts.bufline or {})
  local bufhlaf = C.bufline.highlight
  -- utils.dP({ bufhlbf = bufhlbf, bufhlaf = bufhlaf })

  if C.opts.debug == true then
    require('ztab.utils').setDebug(true)
  end

  local defaulthltab = highlight.default_hl(true, C.tabline.sep_name)
  local hltabtmp = vim.tbl_deep_extend("force", defaulthltab, opts.tabline.highlight)
  -- utils.dP({ hltabtmp = hltabtmp, defaulthltab = defaulthltab })
  local defaulthlbuf = highlight.default_hl(true, C.bufline.sep_name)
  local hlbuftmp = vim.tbl_deep_extend("force", defaulthlbuf, opts.bufline.highlight)
  -- utils.dP({ defaulthlbuf = defaulthlbuf, hlbuftmp = hlbuftmp })


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

  -- utils.dP({ C = C })

  return C
end

return M
