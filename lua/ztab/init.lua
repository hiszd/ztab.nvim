require("ztab.types")

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
    highlight = highlight.default_hl(),
  },
  bufline = {
    enabled = false,
    sep_name = constants.sep_names.thick,
    left_sep = true,
    right_sep = false,
    devicon_colors = "selected",
    highlight = highlight.default_hl(),
    wtabhighlight = highlight.default_hl(),
  },
  opts = {
    tabline = {
      highlight = {},
      sep_name = constants.sep_names.thick,
      left_sep = true,
      right_sep = false,
    },
    bufline = {
      highlight = {},
      wtabhighlight = {},
      sep_name = constants.sep_names.thick,
      left_sep = true,
      right_sep = false,
    },
  },
}

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

---------------------------------------------------------------------------//
-- Setup Function
---------------------------------------------------------------------------//
---@param opts ZSetupOpts? #Setup options
---@return table #Return entire module
local setup = function(opts)
  if opts then
    local b = opts.bufline and true or false
    local t = opts.tabline and true or false
    if b then
      if opts.bufline.sep_name then
        M.__config.opts.bufline.sep_name = opts.bufline.sep_name
        M.__config.bufline.sep_name = opts.bufline.sep_name
      end
      if opts.bufline.left_sep then
        M.__config.opts.bufline.left_sep = opts.bufline.left_sep
        M.__config.bufline.left_sep = opts.bufline.left_sep
      end
      if opts.bufline.right_sep then
        M.__config.opts.bufline.right_sep = opts.bufline.right_sep
        M.__config.bufline.right_sep = opts.bufline.right_sep
      end
      if opts.bufline.devicon_colors then
        M.__config.opts.bufline.devicon_colors = opts.bufline.devicon_colors
        M.__config.bufline.devicon_colors = opts.bufline.devicon_colors
      end
      -- Merge the default configuration and the one provided by the user
      if opts.bufline.highlight then
        M.__config.opts.bufline.highlight = opts.bufline.highlight
        M.__config.bufline.highlight =
        vim.tbl_deep_extend("keep", M.__config.opts.bufline.highlight, M.__config.bufline.highlight)
        M.__config.bufline.highlight = M.typed_highlights(M.__config.bufline.highlight)
      end
      -- Merge the default configuration and the one provided by the user
      if opts.bufline.wtabhighlight then
        M.__config.opts.bufline.wtabhighlight = opts.bufline.wtabhighlight
        M.__config.bufline.wtabhighlight =
        vim.tbl_deep_extend("keep", M.__config.opts.bufline.wtabhighlight, M.__config.bufline.wtabhighlight)
        M.__config.bufline.wtabhighlight = M.typed_highlights(M.__config.bufline.wtabhighlight)
      end
      if opts.bufline.enabled then
        M.__config.opts.bufline.enabled = opts.bufline.enabled
        M.__config.bufline.enabled = opts.bufline.enabled
      end
    end
    if t then
      if opts.tabline.sep_name then
        M.__config.opts.tabline.sep_name = opts.tabline.sep_name
        M.__config.tabline.sep_name = opts.tabline.sep_name
      end
      if opts.tabline.left_sep then
        M.__config.opts.tabline.left_sep = opts.tabline.left_sep
        M.__config.tabline.left_sep = opts.tabline.left_sep
      end
      if opts.tabline.right_sep then
        M.__config.opts.tabline.right_sep = opts.tabline.right_sep
        M.__config.tabline.right_sep = opts.tabline.right_sep
      end
      if opts.tabline.devicon_colors then
        M.__config.opts.tabline.devicon_colors = opts.tabline.devicon_colors
        M.__config.tabline.devicon_colors = opts.tabline.devicon_colors
      end
      -- Merge the default configuration and the one provided by the user
      if opts.tabline.highlight then
        M.__config.opts.tabline.highlight = opts.tabline.highlight
        M.__config.tabline.highlight =
        vim.tbl_deep_extend("keep", M.__config.opts.tabline.highlight, M.__config.tabline.highlight)
        M.__config.tabline.highlight = M.typed_highlights(M.__config.tabline.highlight)
      end
      if opts.tabline.enabled then
        M.__config.opts.tabline.enabled = opts.tabline.enabled
        M.__config.tabline.enabled = opts.tabline.enabled
      end
    end
  end

  -- print("highlight config")
  -- P(M.__config.highlight)

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

  if M.__config.tabline.enabled then
    vim.opt.tabline = "%!v:lua.require'ztab.tabline'.draw()"
  end
  if M.__config.bufline.enabled then
    vim.opt.winbar = "%!v:lua.require'ztab.bufline'.draw()"
  end

  return M
end

M.create_hl_groups = function()
  M.__config.tabline.highlight = highlight.default_hl()
  M.__config.bufline.highlight = highlight.default_hl()
  setup(M.__config.opts)
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

M.extract_highlight_colors = highlight.extract_highlight_colors

return {
  helpers = M,
  setup = setup,
}
