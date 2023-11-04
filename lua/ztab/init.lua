require("ztab.types")

local dP = require("ztab.utils").dP
local constants = require("ztab.constants")
local highlight = require("ztab.highlight")
local defaults = require("ztab.defaults")
local setup = require("ztab.config").setup

---@type table
local M = {}

M.__config = defaults.__config

---@param tabhighlights ZTabHighlightOpts #Highlight option fields
---@param bufhighlights ZTabHighlightOpts #Highlight option fields
---@return nil
M.theme_update = function(tabhighlights, bufhighlights)
  if tabhighlights then
    M.__config.tabline.highlight = vim.tbl_deep_extend("keep", tabhighlights, M.__config.tabline.highlight)
  end
  if bufhighlights then
    M.__config.bufline.highlight = vim.tbl_deep_extend("keep", bufhighlights, M.__config.bufline.highlight)
  end
  for i, hlgrp in pairs(M.__config.tabline.highlight) do
    if constants.highlight_names[i] then
      highlight.update_component_highlight_group(hlgrp, constants.highlight_names[i], true, false, true)
    end
  end
  for i, hlgrp in pairs(M.__config.bufline.highlight) do
    if constants.highlight_names[i] then
      highlight.update_component_highlight_group(hlgrp, constants.highlight_names[i], true, true, false)
    end
  end
end

M.create_hl_groups = function()
  M.__config.tabline.highlight = highlight.default_hl()
  M.__config.bufline.highlight = highlight.default_hl()
  setup(M.__config)
  for i, hlgrp in pairs(M.__config.tabline.highlight) do
    if constants.highlight_names[i] then
      highlight.update_component_highlight_group(hlgrp, constants.highlight_names[i], true, false, true)
    end
  end
  for i, hlgrp in pairs(M.__config.bufline.highlight) do
    if constants.highlight_names[i] then
      highlight.update_component_highlight_group(hlgrp, constants.highlight_names[i], true, true, false)
    end
  end
end

M.extract_highlight_colors = highlight.extract_highlight_colors

return {
  helpers = M,
  setup = setup,
}
