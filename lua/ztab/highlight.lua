require('ztab.types')
local constants = require('ztab.constants')

local fmt = string.format

---@type table
local M = {}

---@type string
local PREFIX = "ZTab"

--- Get highlight name with or without prefix based on selection
---@param hl_name string #Highlight name
---@param sel boolean? #Is tab selected
---@param pfix boolean? #Should the prefix be prepended?
---@return string #Return the final ZTab hl group name
M.get_hl_name = function(hl_name, sel, pfix)
  if sel then
    if pfix == false then
      return hl_name .. (sel and constants.hl_appends["selected"] or '')
    else
      return PREFIX .. '_' .. hl_name .. (sel and constants.hl_appends["selected"] or '')
    end
  else
    if pfix == false then
      return hl_name
    else
      return PREFIX .. '_' .. hl_name
    end
  end
end

--- Wrap a string in vim's tabline highlight syntax
---@param item string #Highlight group
---@return string #Returns formatted string matching tabline highlight syntax
function M.hl(item)
  if not item then return "" end
  return fmt("%%#%s#", item)
end

---Create highlight group for the highlight_tag with prefix added,
---if the group doesn't already exist, and return the group name
---@param color HighlightGroup #Highlight group information
---@param highlight_tag string #Highlight group name without prefix
---@return string #Complete highlight group name
M.create_component_highlight_group = function(color, highlight_tag)
  if color.bg and color.fg then
    local highlight_group_name = table.concat({ PREFIX, highlight_tag }, '_')
    if vim.fn.hlexists(highlight_group_name) == 0 then
      vim.api.nvim_set_hl(0, highlight_group_name,
        { fg = color.fg, bg = color.bg, sp = (color.sp and color.sp or color.fg), underline = color.underline })
      return highlight_group_name
    end
  else
    print("need to specify a background and foreground color")
    P(color)
  end
  return ''
end

--- Update highlight group for the highlight_tag with prefix added and return the group name
---@param color HighlightGroup #Highlight group information
---@param highlight_tag string #Highlight group name without prefix
---@return string #Complete highlight group name
M.update_component_highlight_group = function(color, highlight_tag)
  if color.bg and color.fg then
    local highlight_group_name = table.concat({ PREFIX, highlight_tag }, '_')
    vim.api.nvim_set_hl(0, highlight_group_name,
      { fg = color.fg, bg = color.bg, sp = (color.sp and color.sp or color.fg), underline = color.underline })
    return highlight_group_name
  else
    print("need to specify a background and foreground color")
    P(color)
  end
  return ''
end


--- Get colors from a highlight group and return them
---@param color_group string #Highlight group name
---@return HighlightGroup | nil #Returns highlight group color information
M.extract_highlight_colors = function(color_group)
  if vim.fn.hlexists(color_group) == 0 then return nil end
  local color = vim.api.nvim_get_hl_by_name(color_group, true)
  local rtrn = { bg = '', fg = '' }
  if color.background ~= nil then
    rtrn.bg = string.format('#%06x', color.background)
  end
  if color.foreground ~= nil then
    rtrn.fg = string.format('#%06x', color.foreground)
  end
  return rtrn
end


local defaulthl = M.extract_highlight_colors('Tabline') or
    { bg = '', fg = '' }
local defaultfillhl = M.extract_highlight_colors('TablineFill') or
    { bg = '', fg = '' }
local defaultselhl = M.extract_highlight_colors('TablineSel') or
    { bg = '', fg = '' }

---@type HighlightOpts
M.default_hl = {
  ["separator"] = {
    fg = defaulthl.bg,
    bg = defaulthl.bg,
    sp = "#00ff00",
    underline = false,
  },
  ["separator_sel"] = {
    fg = defaulthl.bg,
    bg = defaultselhl.bg,
    sp = "#00ff00",
    underline = false,
  },
  ["title"] = {
    fg = defaulthl.fg,
    bg = defaulthl.bg,
    sp = "#00ff00",
    underline = true,
  },
  ["title_sel"] = {
    fg = defaultselhl.fg,
    bg = defaultselhl.bg,
    sp = "#00ff00",
    underline = true,
  },
  ["modified"] = {
    fg = defaulthl.fg,
    bg = defaulthl.bg,
    sp = "#00ff00",
    underline = false,
  },
  ["modified_sel"] = {
    fg = defaultselhl.fg,
    bg = defaultselhl.bg,
    sp = "#00ff00",
    underline = false,
  },
  ["icon"] = {
    fg = defaulthl.fg,
    bg = defaulthl.bg,
    sp = "#00ff00",
    underline = false,
  },
  ["icon_sel"] = {
    fg = defaultselhl.fg,
    bg = defaultselhl.bg,
    sp = "#00ff00",
    underline = false,
  },
  ["fill"] = {
    fg = defaultfillhl.fg,
    bg = defaultfillhl.bg,
    sp = "#00ff00",
    underline = false,
  }
}

return M
