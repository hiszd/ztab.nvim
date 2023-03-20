-- Shamelessly stolen from
-- https://github.com/hoob3rt/lualine.nvim/blob/master/lua/lualine/utils/utils.lua

require('ztab.types')
local constants = require('ztab.constants')

local fmt = string.format

local M = {}

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

M.get_hl_name = function(hl_name, sel)
  if sel then
    return PREFIX .. '_' .. hl_name .. (sel and constants.hl_appends["selected"] or '')
  end
end

M.hc_names = {
  tabline = "TabLine",
  tablinesel = "TabLineSel",
}

-- highlight string constants
---@type table<string, string>
M.hc = {
  [M.hc_names.tabline] = "%#TabLine#",
  [M.hc_names.tablinesel] = "%#TabLineSel#",
}

--- Wrap a string in vim's tabline highlight syntax
---@param item string
---@return string
function M.hl(item)
  if not item then return "" end
  return fmt("%%#%s#", item)
end

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


---@param color
M.create_component_highlight_group = function(color, highlight_tag)
  if color.bg and color.fg then
    local highlight_group_name = table.concat({ PREFIX, highlight_tag }, '_')
    if vim.fn.hlexists(highlight_group_name) == 0 then
      vim.api.nvim_set_hl(0, highlight_group_name, { fg = color.fg, bg = color.bg })
      return highlight_group_name
    end
  end
end

M.extract_highlight_colors = function(color_group, scope)
  if vim.fn.hlexists(color_group) == 0 then return nil end
  local color = vim.api.nvim_get_hl_by_name(color_group, true)
  if color.background ~= nil then
    color.bg = string.format('#%06x', color.background)
    color.background = nil
  end
  if color.foreground ~= nil then
    color.fg = string.format('#%06x', color.foreground)
    color.foreground = nil
  end
  if scope then return color[scope] end
  return color
end

return M
