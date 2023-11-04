require("ztab.types")
local constants = require("ztab.constants")
local dP = require("ztab.utils").dP

local fmt = string.format

---Add prefix for buffer, or tab depending on input
---@param buf boolean #Buf prefix?
---@param tab boolean #Tab prefix?
---@return string #Prefix string to be appended
local addpfix = function(buf, tab)
  local addpfix = ""
  if buf and not tab then
    addpfix = constants.ADDPFIXBuf
  elseif tab and not buf then
    addpfix = constants.ADDPFIXTab
  end
  return addpfix
end

local M = {}

--- Get highlight name with or without prefix based on selection
---@param hl_name string #Highlight name
---@param sel boolean? #Is tab selected
---@param pfix boolean? #Should the prefix be prepended?
---@param buf boolean? #Buf prefix?
---@param tab boolean? #Tab prefix?
---@return string #Return the final ZTab hl group name
M.get_hl_name = function(hl_name, sel, pfix, buf, tab)
  local addprefix = addpfix(buf and true or false, tab and true or false)
  if sel then
    if pfix == false then
      return hl_name .. (sel and constants.hl_appends["selected"] or "")
    elseif pfix == true and addprefix ~= "" then
      return table.concat(
        { constants.PREFIX, addprefix, hl_name .. (sel and constants.hl_appends["selected"] or "") },
        "_"
      )
    else
      return table.concat({ constants.PREFIX, hl_name .. (sel and constants.hl_appends["selected"] or "") }, "_")
    end
  else
    if pfix == false then
      return hl_name
    elseif pfix == true and addprefix ~= "" then
      return table.concat({ constants.PREFIX, addprefix, hl_name }, "_")
    else
      return table.concat({ constants.PREFIX, hl_name }, "_")
    end
  end
end

---@param h ZTabHighlightOpts
---@return ZTabHighlightOpts
M.typed_highlights = function(h)
  local defcol = M.defaulthlcols()
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
    dP(color)
  end
  return ""
end

--- Update highlight group for the highlight_tag with prefix added and return the group name
---@param color ZTabHighlightGroup #Highlight group information
---@param highlight_tag string #Highlight group name without prefix
---@param pfix boolean? #General prefix
---@param buf boolean? #Buffer prefix
---@param tab boolean? #Tabline prefix
---@return string #Complete highlight group name
M.update_component_highlight_group = function(color, highlight_tag, pfix, buf, tab)
  if color.bg ~= nil and color.fg ~= nil then
    local addprefix = addpfix(buf and true or false, tab and true or false)
    local highlight_group_name
    if pfix then
      if addprefix ~= "" then
        highlight_group_name = table.concat({ constants.PREFIX, addprefix, highlight_tag }, "_")
      else
        highlight_group_name = table.concat({ constants.PREFIX, highlight_tag }, "_")
      end
    else
      if addprefix ~= "" then
        highlight_group_name = table.concat({ addprefix, highlight_tag }, "_")
      else
        highlight_group_name = highlight_tag
      end
    end
    pcall(function()
      vim.api.nvim_set_hl(0, highlight_group_name, {
        fg = color.fg,
        bg = color.bg,
        sp = (color.sp and color.sp or color.fg),
        underline = color.underline or false,
      })
    end)
    -- Printf("group:%q fg:%q bg:%q", highlight_group_name, color.fg, color.bg)
    return highlight_group_name
  else
    print("need to specify a background and foreground color")
    dP(color)
  end
  return ""
end

--- Get colors from a highlight group and return them
---@param color_group string #Highlight group name
---@return ZTabHighlightGroup #Returns highlight group color information
M.extract_highlight_colors = function(color_group)
  local rtrn = { bg = "", fg = "", found = false }
  if vim.fn.hlexists(color_group) == 0 then
    return rtrn
  end
  local color = vim.api.nvim_get_hl_by_name(color_group, true)
  if color.foreground == nil or color.background == nil then
    return rtrn
  end
  if color.background ~= nil then
    rtrn.bg = string.format("#%06x", color.background)
    rtrn.found = true
  end
  if color.foreground ~= nil then
    rtrn.fg = string.format("#%06x", color.foreground)
    rtrn.found = true
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

---@param w boolean? #Is this with or without tabline
---@param type string? #Is this with or without tabline
M.default_hl = function(w, type)
  local defhl = M.defaulthlcols()
  local fillcol = defhl.fillcol
  local inactivecol = defhl.inactivecol
  local activecol = defhl.activecol
  ---@type ZTabHighlightOpts
  local rtrn = {
    ["separator_sel"] = {
      fg = fillcol.fg,
      bg = activecol.bg,
      sp = activecol.fg,
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
    ["icon_sel"] = {
      fg = activecol.fg,
      bg = activecol.bg,
      sp = activecol.fg,
      underline = false,
    },
  }

  --If this is with tabs
  if w then
    rtrn = vim.tbl_deep_extend("keep", {
      ["fill"] = {
        fg = fillcol.fg,
        bg = activecol.bg,
        sp = fillcol.fg,
        underline = false,
      },
      ["title"] = {
        fg = inactivecol.fg,
        bg = activecol.bg,
        sp = inactivecol.fg,
        underline = false,
      },
      ["icon"] = {
        fg = activecol.fg,
        bg = activecol.bg,
        sp = activecol.fg,
        underline = false,
      },
      ["separator"] = {
        fg = fillcol.bg,
        bg = activecol.bg,
        sp = inactivecol.fg,
        underline = false,
      },
    }, rtrn)
    --If this is without tabs
  else
    rtrn = vim.tbl_deep_extend("keep", {
      ["fill"] = {
        fg = fillcol.fg,
        bg = fillcol.bg,
        sp = fillcol.fg,
        underline = false,
      },
      ["title"] = {
        fg = inactivecol.fg,
        bg = inactivecol.bg,
        sp = inactivecol.fg,
        underline = false,
      },
      ["icon"] = {
        fg = inactivecol.fg,
        bg = inactivecol.bg,
        sp = inactivecol.fg,
        underline = false,
      },
      ["separator"] = {
        fg = fillcol.bg,
        bg = inactivecol.bg,
        sp = inactivecol.fg,
        underline = false,
      },
    }, rtrn)
  end

  -- If the type of tab is any slant the default behavior is to look like a tab
  if type ~= constants.sep_names.thin and type ~= constants.sep_names.thick then
    rtrn = vim.tbl_deep_extend("keep", {
      ["separator"] = {
        fg = inactivecol.bg,
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
    }, rtrn)
  end

  return rtrn
end

return M
