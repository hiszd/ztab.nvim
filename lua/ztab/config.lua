local highlight = require("ztab.highlight")
local constants = require("ztab.constants")
local dP = require("ztab.utils").dP

local M = {}

---------------------------------------------------------------------------//
-- Setup Function
---------------------------------------------------------------------------//
---@param C ZConfig #Setup options
---@return table #Return entire module
M.setup = function(C)
  if C.opts then
    -- local b = C.opts.bufline and true or false
    -- local t = C.opts.tabline and true or false
    if C.opts.bufline.enabled then
      if C.opts.bufline.sep_name then
        C.opts.bufline.sep_name = C.opts.bufline.sep_name
        C.bufline.sep_name = C.opts.bufline.sep_name
      end
      if C.opts.bufline.left_sep then
        C.opts.bufline.left_sep = C.opts.bufline.left_sep
        C.bufline.left_sep = C.opts.bufline.left_sep
      end
      if C.opts.bufline.right_sep then
        C.opts.bufline.right_sep = C.opts.bufline.right_sep
        C.bufline.right_sep = C.opts.bufline.right_sep
      end
      if C.opts.bufline.devicon_colors then
        C.opts.bufline.devicon_colors = C.opts.bufline.devicon_colors
        C.bufline.devicon_colors = C.opts.bufline.devicon_colors
      end
      -- Merge the default configuration and the one provided by the user
      if C.opts.bufline.highlight then
        C.opts.bufline.highlight = C.opts.bufline.highlight
        C.bufline.highlight = vim.tbl_deep_extend(
          "keep",
          C.opts.bufline.highlight,
          highlight.default_hl(false, C.bufline.sep_name)
        )
        C.bufline.highlight = highlight.typed_highlights(C.bufline.highlight)
      else
        C.bufline.highlight = highlight.typed_highlights(C.bufline.highlight)
      end
      -- Merge the default configuration and the one provided by the user
      if C.opts.bufline.wtabhighlight then
        print("testing")
        C.opts.bufline.wtabhighlight = C.opts.bufline.wtabhighlight
        C.bufline.wtabhighlight = vim.tbl_deep_extend(
          "keep",
          C.opts.bufline.wtabhighlight,
          highlight.default_hl(true, C.bufline.sep_name)
        )
        C.bufline.wtabhighlight = highlight.typed_highlights(C.bufline.wtabhighlight)
        dP(C.bufline.wtabhighlight)
      else
        C.bufline.wtabhighlight = highlight.typed_highlights(C.bufline.wtabhighlight)
      end
      if C.opts.bufline.enabled then
        C.opts.bufline.enabled = C.opts.bufline.enabled
        C.bufline.enabled = C.opts.bufline.enabled
      end
    end
    if C.opts.tabline.enabled then
      if C.opts.tabline.sep_name then
        C.opts.tabline.sep_name = C.opts.tabline.sep_name
        C.tabline.sep_name = C.opts.tabline.sep_name
      end
      if C.opts.tabline.left_sep then
        C.opts.tabline.left_sep = C.opts.tabline.left_sep
        C.tabline.left_sep = C.opts.tabline.left_sep
      end
      if C.opts.tabline.right_sep then
        C.opts.tabline.right_sep = C.opts.tabline.right_sep
        C.tabline.right_sep = C.opts.tabline.right_sep
      end
      if C.opts.tabline.devicon_colors then
        C.opts.tabline.devicon_colors = C.opts.tabline.devicon_colors
        C.tabline.devicon_colors = C.opts.tabline.devicon_colors
      end
      -- Merge the default configuration and the one provided by the user
      if C.opts.tabline.highlight then
        C.opts.tabline.highlight = C.opts.tabline.highlight
        C.tabline.highlight = vim.tbl_deep_extend(
          "keep",
          C.opts.tabline.highlight,
          highlight.default_hl(false, C.tabline.sep_name)
        )
        C.tabline.highlight = highlight.typed_highlights(C.tabline.highlight)
      end
      if C.opts.tabline.enabled then
        C.opts.tabline.enabled = C.opts.tabline.enabled
        C.tabline.enabled = C.opts.tabline.enabled
      end
    end
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
