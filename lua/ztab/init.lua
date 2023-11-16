require("ztab.types")
local utils = require("ztab.utils")

local constants = require("ztab.constants")
local highlight = require("ztab.highlight")
local defaults = require("ztab.defaults")
local config = require("ztab.config")

---@type table
local M = {}

---@type ZConfig
M.__config = defaults.__config

-- ---@param tabhighlights ZTabHighlightOpts #Highlight option fields
-- ---@param bufhighlights ZTabHighlightOpts #Highlight option fields
-- ---@return nil
-- M.theme_update = function(tabhighlights, bufhighlights)
--   if tabhighlights then
--     M.__config.tabline.highlight = vim.tbl_deep_extend("keep", tabhighlights, M.__config.tabline.highlight)
--   end
--   if bufhighlights then
--     M.__config.bufline.highlight = vim.tbl_deep_extend("keep", bufhighlights, M.__config.bufline.highlight)
--   end
--   for i, hlgrp in pairs(M.__config.tabline.highlight) do
--     if constants.highlight_names[i] then
--       highlight.update_component_highlight_group(hlgrp, constants.highlight_names[i], true, false, true)
--     end
--   end
--   for i, hlgrp in pairs(M.__config.bufline.highlight) do
--     if constants.highlight_names[i] then
--       highlight.update_component_highlight_group(hlgrp, constants.highlight_names[i], true, true, false)
--     end
--   end
-- end
--
M.extract_highlight_colors = highlight.extract_highlight_colors

---@param opts ZSetupOpts #Options to configure the plugin
local setup = function(opts)
  M.__config = config.setup(M.__config, opts)
end

return {
  helpers = M,
  setup = setup,
  hlcols = highlight.defaulthlcols(),
}
