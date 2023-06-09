require("ztab.types")
local constants = require("ztab.constants")

local fmt = string.format

local M = {}

--- Get highlight name with or without prefix based on selection
---@param hl_name string #Highlight name
---@param sel boolean? #Is tab selected
---@param pfix boolean? #Should the prefix be prepended?
---@return string #Return the final ZTab hl group name
M.get_hl_name = function(hl_name, sel, pfix)
  if sel then
    if pfix == false then
      return hl_name .. (sel and constants.hl_appends["selected"] or "")
    else
      return constants.PREFIX .. "_" .. hl_name .. (sel and constants.hl_appends["selected"] or "")
    end
  else
    if pfix == false then
      return hl_name
    else
      return constants.PREFIX .. "_" .. hl_name
    end
  end
end

--- Wrap a string in vim's tabline highlight syntax
---@param item string #Highlight group
---@return string #Returns formatted string matching tabline highlight syntax
function M.hl(item)
  if not item then
    return ""
  end
  return fmt("%%#%s#", item)
end

---Create highlight group for the highlight_tag with prefix added,
---if the group doesn't already exist, and return the group name
---@param color ZTabHighlightGroup #Highlight group information
---@param highlight_tag string #Highlight group name without prefix
---@return string #Complete highlight group name
M.create_component_highlight_group = function(color, highlight_tag)
  if color.bg and color.fg then
    local highlight_group_name = table.concat({ constants.PREFIX, highlight_tag }, "_")
    if vim.fn.hlexists(highlight_group_name) == 0 then
      vim.api.nvim_set_hl(
        0,
        highlight_group_name,
        { fg = color.fg, bg = color.bg, sp = (color.sp and color.sp or color.fg), underline = color.underline }
      )
      return highlight_group_name
    end
  else
    print("need to specify a background and foreground color")
    P(color)
  end
  return ""
end

--- Update highlight group for the highlight_tag with prefix added and return the group name
---@param color ZTabHighlightGroup #Highlight group information
---@param highlight_tag string #Highlight group name without prefix
---@return string #Complete highlight group name
M.update_component_highlight_group = function(color, highlight_tag)
  if color.bg ~= nil and color.fg ~= nil then
    local highlight_group_name = table.concat({ constants.PREFIX, highlight_tag }, "_")
    pcall(function()
      vim.api.nvim_set_hl(0, highlight_group_name, {
        fg = color.fg,
        bg = color.bg,
        sp = (color.sp and color.sp or color.fg),
        underline = color.underline or false,
      })
    end)
    return highlight_group_name
  else
    print("need to specify a background and foreground color")
    P(color)
  end
  return ""
end

--- Get colors from a highlight group and return them
---@param color_group string #Highlight group name
---@return ZTabHighlightGroup #Returns highlight group color information
M.extract_highlight_colors = function(color_group)
  local rtrn = { bg = "", fg = "" }
  if vim.fn.hlexists(color_group) == 0 then
    return rtrn
  end
  local color = vim.api.nvim_get_hl_by_name(color_group, true)
  if color.foreground == nil or color.background == nil then
    return rtrn
  end
  if color.background ~= nil then
    rtrn.bg = string.format("#%06x", color.background)
  end
  if color.foreground ~= nil then
    rtrn.fg = string.format("#%06x", color.foreground)
  end
  return rtrn
end

M.defaulthlcols = function()
  local defaultcols = { bg = "#FFFFFF", fg = "#000000" }

  local normhl = M.extract_highlight_colors("Normal")
  normhl = vim.tbl_deep_extend("force", defaultcols, normhl)
  local defaulthl = M.extract_highlight_colors("TabLine")
  defaulthl = vim.tbl_deep_extend("force", defaultcols, defaulthl)
  local defaultfillhl = M.extract_highlight_colors("TabLineFill")
  defaultfillhl = vim.tbl_deep_extend("force", defaultcols, defaultfillhl)
  local defaultselhl = M.extract_highlight_colors("TabLineSel")
  defaultselhl = vim.tbl_deep_extend("force", defaultcols, defaultselhl)

  local fillcol = defaultfillhl
  local inactivecol = defaulthl
  local activecol = defaultselhl
  if defaulthl.bg == defaultselhl.bg then
    activecol = normhl
  end

  return { fillcol = fillcol, inactivecol = inactivecol, activecol = activecol }
end

M.default_hl = function()
  local defhl = M.defaulthlcols()
  local fillcol = defhl.fillcol
  local inactivecol = defhl.inactivecol
  local activecol = defhl.activecol

  ---@type ZTabHighlightOpts
  local rtrn = {
        ["separator"] = {
      fg = fillcol.bg,
      bg = inactivecol.bg,
      sp = inactivecol.fg,
      underline = false,
    },
        ["separator_sel"] = {
      fg = fillcol.bg,
      bg = activecol.bg,
      sp = activecol.fg,
      underline = false,
    },
        ["title"] = {
      fg = inactivecol.fg,
      bg = inactivecol.bg,
      sp = inactivecol.fg,
      underline = false,
    },
        ["title_sel"] = {
      fg = activecol.fg,
      bg = activecol.bg,
      sp = activecol.fg,
      underline = false,
    },
        ["modified"] = {
      fg = inactivecol.fg,
      bg = inactivecol.bg,
      sp = inactivecol.fg,
      underline = false,
    },
        ["modified_sel"] = {
      fg = activecol.fg,
      bg = activecol.bg,
      sp = activecol.fg,
      underline = false,
    },
        ["icon"] = {
      fg = inactivecol.fg,
      bg = inactivecol.bg,
      sp = inactivecol.fg,
      underline = false,
    },
        ["icon_sel"] = {
      fg = activecol.fg,
      bg = activecol.bg,
      sp = activecol.fg,
      underline = false,
    },
        ["fill"] = {
      fg = fillcol.fg,
      bg = fillcol.bg,
      sp = fillcol.fg,
      underline = false,
    },
  }

  return rtrn
end

return M
