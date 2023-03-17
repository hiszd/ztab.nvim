-- Shamelessly stolen from
-- https://github.com/hoob3rt/lualine.nvim/blob/master/lua/lualine/utils/utils.lua

local fmt = string.format

local M = {}

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

M.create_component_highlight_group = function(color, highlight_tag)
  if color.bg and color.fg then
    local highlight_group_name = table.concat({ 'LuaTab', highlight_tag }, '_')
    M.highlight(highlight_group_name, color.fg, color.bg)
    return highlight_group_name
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
