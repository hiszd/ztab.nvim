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
---@param color HighlightGroup #Highlight group information
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
---@param color HighlightGroup #Highlight group information
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
---@return HighlightGroup | nil #Returns highlight group color information
M.extract_highlight_colors = function(color_group)
  if vim.fn.hlexists(color_group) == 0 then
    return nil
  end
  local color = vim.api.nvim_get_hl_by_name(color_group, true)
  local rtrn = { bg = "", fg = "" }
  if color.foreground == nil or color.background == nil then
    return nil
  end
  if color.background ~= nil then
    rtrn.bg = string.format("#%06x", color.background)
  end
  if color.foreground ~= nil then
    rtrn.fg = string.format("#%06x", color.foreground)
  end
  return rtrn
end

local normhl = M.extract_highlight_colors("Normal") or { bg = "#FFFFFF", fg = "#000000" }
local defaulthl = M.extract_highlight_colors("Tabline") or { bg = "#FFFFFF", fg = "#000000" }
local defaultfillhl = M.extract_highlight_colors("TablineFill") or { bg = "#FFFFFF", fg = "#000000" }
local defaultselhl = M.extract_highlight_colors("TablineSel") or { bg = "#FFFFFF", fg = "#000000" }

print("norm")
P(normhl)
print("def")
P(defaulthl)
print("fill")
P(defaultfillhl)
print("sel")
P(defaultselhl)

---@type HighlightOpts
M.default_hl = {
  ["separator"] = {
    fg = normhl.bg,
    bg = normhl.bg,
    sp = defaulthl.fg,
    underline = false,
  },
  ["separator_sel"] = {
    fg = normhl.bg,
    bg = defaultselhl.bg,
    sp = defaulthl.bg,
    underline = false,
  },
  ["title"] = {
    fg = defaulthl.fg,
    bg = normhl.bg,
    sp = normhl.fg,
    underline = false,
  },
  ["title_sel"] = {
    fg = defaultselhl.fg,
    bg = defaultselhl.bg,
    sp = defaultselhl.fg,
    underline = true,
  },
  ["modified"] = {
    fg = defaulthl.fg,
    bg = normhl.bg,
    sp = normhl.fg,
    underline = false,
  },
  ["modified_sel"] = {
    fg = defaultselhl.fg,
    bg = defaultselhl.bg,
    sp = defaultselhl.fg,
    underline = false,
  },
  ["icon"] = {
    fg = defaulthl.fg,
    bg = normhl.bg,
    sp = normhl.fg,
    underline = false,
  },
  ["icon_sel"] = {
    fg = defaultselhl.fg,
    bg = defaultselhl.bg,
    sp = defaultselhl.fg,
    underline = false,
  },
  ["fill"] = {
    fg = normhl.fg,
    bg = normhl.bg,
    sp = normhl.fg,
    underline = false,
  },
}

return M
