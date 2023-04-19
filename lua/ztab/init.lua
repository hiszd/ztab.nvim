require("ztab.types")

local constants = require("ztab.constants")
local highlight = require("ztab.highlight")

---@type table
local M = {}

---------------------------------------------------------------------------//
-- Default Config
---------------------------------------------------------------------------//
---@type ZTabConfig
M.__config = {
  sep_name = constants.sep_names.thick,
  left_sep = true,
  right_sep = false,
  devicon_colors = "selected",
  highlight = highlight.default_hl(),
  tabline = true,
  bufline = false,
  opts = {
    highlight = {},
    sep_name = constants.sep_names.thick,
    left_sep = true,
    right_sep = false,
    tabline = true,
    bufline = false,
  },
}

---@param highlights ZTabHighlightOpts #Highlight option fields
---@return nil
M.theme_update = function(highlights)
  if highlights then
    M.__config.highlight = vim.tbl_deep_extend("keep", highlights, M.__config.highlight)
  end
  for i, hlgrp in pairs(M.__config.highlight) do
    if constants.highlight_names[i] then
      highlight.update_component_highlight_group(hlgrp, constants.highlight_names[i])
    end
  end
end

---------------------------------------------------------------------------//
-- Setup Function
---------------------------------------------------------------------------//
---@param opts ZTabSetupOpts? #Setup options
---@return table #Return entire module
local setup = function(opts)
  if opts then
    if opts.sep_name then
      M.__config.opts.sep_name = opts.sep_name
      M.__config.sep_name = opts.sep_name
    end
    if opts.left_sep then
      M.__config.opts.left_sep = opts.left_sep
      M.__config.left_sep = opts.left_sep
    end
    if opts.right_sep then
      M.__config.opts.right_sep = opts.right_sep
      M.__config.right_sep = opts.right_sep
    end
    if opts.devicon_colors then
      M.__config.opts.devicon_colors = opts.devicon_colors
      M.__config.devicon_colors = opts.devicon_colors
    end
    -- Merge the default configuration and the one provided by the user
    if opts.highlight then
      M.__config.opts.highlight = opts.highlight
      M.__config.highlight = vim.tbl_deep_extend("keep", M.__config.opts.highlight, M.__config.highlight)
      M.__config.highlight = M.typed_highlights(M.__config.highlight)
    end
    if opts.tabline then
      M.__config.opts.tabline = opts.tabline
      M.__config.tabline = opts.tabline
    end
    if opts.bufline then
      M.__config.opts.bufline = opts.bufline
      M.__config.bufline = opts.bufline
    end
  end

  -- print("highlight config")
  -- P(M.__config.highlight)

  for i, hlgrp in pairs(M.__config.highlight) do
    if constants.highlight_names[i] then
      highlight.update_component_highlight_group(hlgrp, constants.highlight_names[i])
    end
  end

  if M.__config.tabline then
    vim.opt.tabline = "%!v:lua.require'ztab.tabline'()"
  end
  if M.__config.bufline then
    vim.opt.winbar = "%!v:lua.require'ztab.bufline'.draw()"
  end

  return M
end

M.create_hl_groups = function()
  M.__config.highlight = highlight.default_hl()
  setup(M.__config.opts)
  for i, hlgrp in pairs(M.__config.highlight) do
    if constants.highlight_names[i] then
      highlight.update_component_highlight_group(hlgrp, constants.highlight_names[i])
    end
  end
end

---@param h ZTabHighlightOpts
---@return ZTabHighlightOpts
M.typed_highlights = function(h)
  local defcol = highlight.defaulthlcols()
  local reptab = {
        ["activecol.fg"] = defcol.activecol.fg,
        ["activecol.bg"] = defcol.activecol.bg,
        ["inactivecol.fg"] = defcol.inactivecol.fg,
        ["inactivecol.bg"] = defcol.inactivecol.bg,
        ["fillcol.fg"] = defcol.fillcol.fg,
        ["fillcol.bg"] = defcol.fillcol.bg,
  }
  for i, hlgrp in pairs(h) do
    for r, col in pairs(reptab) do
      if hlgrp.fg == r then
        h[i].fg = col
      end
      if hlgrp.bg == r then
        h[i].bg = col
      end
      if hlgrp.sp == r then
        h[i].sp = col
      end
    end
  end
  return h
end

return {
  helpers = M,
  setup = setup,
}
