require('ztab.types')
local constants = require("ztab.constants")
local highlight = require("ztab.highlight")

---@type table
local M = {}

---------------------------------------------------------------------------//
-- Default Tab Config
---------------------------------------------------------------------------//
---@type ZConfig
M.__config = {
  tabline = {
    enabled = true,
    sep_name = constants.sep_names.thick,
    left_sep = true,
    right_sep = false,
    devicon_colors = "selected",
    highlight = highlight.default_hl(false, constants.sep_names.thick),
    wtabhighlight = highlight.default_hl(false, constants.sep_names.thick),
  },
  bufline = {
    enabled = false,
    sep_name = constants.sep_names.thick,
    left_sep = true,
    right_sep = false,
    devicon_colors = "selected",
    highlight = highlight.default_hl(false, constants.sep_names.thick),
    wtabhighlight = highlight.default_hl(true, constants.sep_names.thick),
  },
  opts = {
    debug = true,
    tabline = {
      highlight = {},
      sep_name = constants.sep_names.thick,
      left_sep = true,
      right_sep = false,
      devicon_colors = "selected",
    },
    bufline = {
      highlight = {},
      wtabhighlight = {},
      sep_name = constants.sep_names.thick,
      left_sep = true,
      right_sep = false,
      devicon_colors = "selected",
    },
  },
}

return M
