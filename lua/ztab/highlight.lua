require('ztab.types')
local constants = require('ztab.constants')

local fmt = string.format

---@type table
local M = {}

---@type string
local PREFIX = "ZTab"

--- Create a highlight name from a string using the bufferline prefix as well as appending the state
--- of the element
---@param name string
---@param opts NameGenerationArgs
---@return string
function M.generate_name_for_state(name, opts)
  opts = opts or {}
  local visibility_suffix = ({
        Inactive = "Inactive",
        Selected = "Selected",
        None = "",
      })[opts.visibility]
  return fmt("%s%s%s", PREFIX, name, visibility_suffix)
end

--- Get highlight name with or without prefix based on selection
---@param hl_name string
---@param sel boolean?
---@param pfix boolean?
---@return string
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
---@param item string
---@return string
function M.hl(item)
  if not item then return "" end
  return fmt("%%#%s#", item)
end

---@param name string
---@param foreground string
---@param background string
---@return nil
M.highlight = function(name, foreground, background)
  local command = { 'highlight', name }
  if foreground and foreground ~= 'none' then
    table.insert(command, 'guifg=' .. foreground)
  end
  if background and background ~= 'none' then
    table.insert(command, 'guibg=' .. background)
  end
  vim.cmd(table.concat(command, ' '))
end

--- Create highlight group for the highlight_tag with prefix added
---, if the group doesn't already exist, and return the group name
---@param color HighlightGroup
---@param highlight_tag string
---@return string
M.create_component_highlight_group = function(color, highlight_tag)
  if color.bg and color.fg then
    local highlight_group_name = table.concat({ PREFIX, highlight_tag }, '_')
    if vim.fn.hlexists(highlight_group_name) == 0 then
      vim.api.nvim_set_hl(0, highlight_group_name, { fg = color.fg, bg = color.bg })
      return highlight_group_name
    end
  else
    print("need to specify a background and foreground color")
    P(color)
  end
  return ''
end

--- Update highlight group for the highlight_tag with prefix added and return the group name
---@param color HighlightGroup
---@param highlight_tag string
---@return string
M.update_component_highlight_group = function(color, highlight_tag)
  if color.bg and color.fg then
    local highlight_group_name = table.concat({ PREFIX, highlight_tag }, '_')
    vim.api.nvim_set_hl(0, highlight_group_name, { fg = color.fg, bg = color.bg })
    return highlight_group_name
  else
    print("need to specify a background and foreground color")
    P(color)
  end
  return ''
end


--- Get colors from a highlight group and return them
---@param color_group string
---@return HighlightGroup | nil
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
  },
      ["separator_sel"] = {
    fg = defaulthl.bg,
    bg = defaultselhl.bg,
  },
      ["title"] = {
    fg = defaulthl.fg,
    bg = defaulthl.bg,
  },
      ["title_sel"] = {
    fg = defaultselhl.fg,
    bg = defaultselhl.bg,
  },
      ["modified"] = {
    fg = defaulthl.fg,
    bg = defaulthl.bg,
  },
      ["modified_sel"] = {
    fg = defaultselhl.fg,
    bg = defaultselhl.bg,
  },
      ["icon"] = {
    fg = defaulthl.fg,
    bg = defaulthl.bg,
  },
      ["icon_sel"] = {
    fg = defaultselhl.fg,
    bg = defaultselhl.bg,
  },
      ["fill"] = {
    fg = defaultfillhl.fg,
    bg = defaultfillhl.bg,
  }
}

return M
