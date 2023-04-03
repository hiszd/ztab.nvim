---@diagnostic disable: unused-local

require("ztab.types")

local constants = require("ztab.constants")
local highlight = require("ztab.highlight")

---@type table
local M = {}

---@param isSelected boolean #Is the tab selected
---@return string #Return spacer with highlights
M.spacer = function(isSelected)
  local selhl = highlight.hl(highlight.get_hl_name(constants.highlight_names.title_sel))
  local hl = highlight.hl(highlight.get_hl_name(constants.highlight_names.title))

  return (isSelected and selhl or hl) .. " "
end

---------------------------------------------------------------------------//
-- Default Config
---------------------------------------------------------------------------//
---@type ConfigType
M.__config = {
  sep_name = constants.sep_names.thick,
  left_sep = true,
  right_sep = false,
  devicon_colors = "selected",
  highlight = highlight.default_hl(),
  opts = {
    highlight = {},
    sep_name = constants.sep_names.thick,
    left_sep = true,
    right_sep = false,
  },
}

--- Get tab title text
---@param bufnr number #Buffer number
---@param isSelected boolean #Is the tab selected?
---@return string #Return title component with highlights
M.title = function(bufnr, isSelected)
  local hl = highlight.get_hl_name(constants.highlight_names.title, isSelected)
  local file = vim.fn.bufname(bufnr)
  local buftype = vim.fn.getbufvar(bufnr, "&buftype")
  local filetype = vim.fn.getbufvar(bufnr, "&filetype")

  local rtrn = highlight.hl(hl)

  if buftype == "help" then
    rtrn = rtrn .. "help:" .. vim.fn.fnamemodify(file, ":t:r")
  elseif buftype == "quickfix" then
    rtrn = rtrn .. "quickfix"
  elseif filetype == "TelescopePrompt" then
    rtrn = rtrn .. "Telescope"
  elseif filetype == "git" then
    rtrn = rtrn .. "Git"
  elseif filetype == "fugitive" then
    rtrn = rtrn .. "Fugitive"
  elseif file:sub(file:len() - 2, file:len()) == "FZF" then
    rtrn = rtrn .. "FZF"
  elseif buftype == "terminal" then
    local _, mtch = string.match(file, "term:(.*):(%a+)")
    rtrn = rtrn .. (mtch ~= nil and mtch or vim.fn.fnamemodify(vim.env.SHELL, ":t"))
  elseif file == "" then
    rtrn = rtrn .. "[No Name]"
  else
    rtrn = rtrn .. vim.fn.pathshorten(vim.fn.fnamemodify(file, ":p:~:t"))
  end
  return rtrn
end

--- Get tab modified content
---@param bufnr number #Buffer number
---@param isSelected boolean #Is the tab selected
---@return string #Return modified component with highlights
M.modified = function(bufnr, isSelected)
  local hl = highlight.get_hl_name(constants.highlight_names.modified, isSelected)
  local ret = highlight.hl(hl)
  ret = ret .. (vim.fn.getbufvar(bufnr, "&modified") == 1 and ("[+]" .. M.spacer(isSelected)) or "")
  return ret
end

--- Get tab devicon content
---@param bufnr number #Buffer number
---@param isSelected boolean #Is the tab selected?
---@return string #Return devicon with highlights
M.devicon = function(bufnr, isSelected)
  local icon, devhl
  local file = vim.fn.bufname(bufnr)
  local buftype = vim.fn.getbufvar(bufnr, "&buftype")
  local filetype = vim.fn.getbufvar(bufnr, "&filetype")
  local devicons = require("nvim-web-devicons")
  if filetype == "TelescopePrompt" then
    icon, devhl = devicons.get_icon("telescope")
  elseif filetype == "fugitive" then
    icon, devhl = devicons.get_icon("git")
  elseif filetype == "vimwiki" then
    icon, devhl = devicons.get_icon("markdown")
  elseif buftype == "terminal" then
    icon, devhl = devicons.get_icon("zsh")
  else
    icon, devhl = devicons.get_icon(file, vim.fn.expand("#" .. bufnr .. ":e"))
  end
  if icon then
    local h = require("ztab.highlight")
    local hl_name = h.get_hl_name(constants.highlight_names.icon, isSelected, true)
    local defaultcol = { fg = "fg", bg = "bg" }
    local colors = defaultcol
    colors = h.extract_highlight_colors((isSelected and devhl or hl_name)) or defaultcol
    if M.__config.devicon_colors == "true" then
      colors = h.extract_highlight_colors(devhl) or defaultcol
    elseif M.__config.devicon_colors == "false" then
      colors = h.extract_highlight_colors(hl_name) or defaultcol
    end

    P(M.__config.highlight[constants.highlight_vars[hl_name]].sp)

    local bghl = h.extract_highlight_colors(hl_name)
    if bghl ~= nil then
      colors.bg = bghl.bg or defaultcol.bg
    end
    local hl = h.update_component_highlight_group({
      bg = colors.bg,
      fg = colors.fg,
      sp = M.__config.highlight[constants.highlight_vars[hl_name]].sp,
      underline = M.__config.highlight[constants.highlight_vars[hl_name]].underline,
    }, h.get_hl_name(devhl, isSelected, false))
    -- P("hl: " .. (hl or '') .. ' and ' .. h.get_hl_name(devhl, isSelected, false))
    local selectedHlStart = h.hl(hl)
    local selectedHlEnd = h.hl(h.get_hl_name(constants.highlight_names.title, isSelected))
    return selectedHlStart .. icon .. selectedHlEnd .. M.spacer(isSelected)
  end
  return ""
end

---Get separator content
---@param index number #Tab index
---@param sel boolean #Is the tab selected?
---@param side "left" | "right" | "" #Side of separator to render
---@return string #Seperator with highlights
M.separator = function(index, sel, side)
  if side ~= "left" and side ~= "right" then
    return ""
  end
  local hl = highlight.get_hl_name(constants.highlight_names.separator, sel)
  local last = index == vim.fn.tabpagenr("$")
  local first = index == 1
  local sep = ""

  if side == "left" then
    sep = constants.sep_chars[M.__config.sep_name][2]
    if first and M.__config.sep_name == constants.sep_names.slant then
      return highlight.hl(hl) .. ""
    end
    return highlight.hl(hl) .. sep
  elseif side == "right" then
    sep = constants.sep_chars[M.__config.sep_name][1]
    return highlight.hl(hl) .. sep
  end

  return ""
end

---Produce the tab cell
---@param index number #Tab index
---@return string #Tab cell
local cell = function(index)
  local isSelected = vim.fn.tabpagenr() == index
  local buflist = vim.fn.tabpagebuflist(index)
  local winnr = vim.fn.tabpagewinnr(index)
  local bufnr = buflist[winnr]
  local selhl = highlight.hl(highlight.get_hl_name(constants.highlight_names.title_sel))
  local hl = highlight.hl(highlight.get_hl_name(constants.highlight_names.title))

  local spacing = (isSelected and selhl or hl) .. M.spacer(isSelected)

  local ret = ""
  if M.__config.left_sep then
    ret = ret .. M.separator(index, isSelected, "left")
  end
  ret = ret
      .. "%"
      .. index
      .. "T"
      .. spacing
      .. M.title(bufnr, isSelected)
      .. spacing
      .. M.modified(bufnr, isSelected)
      .. M.devicon(bufnr, isSelected)
      .. "%T"
  if M.__config.right_sep then
    ret = ret .. M.separator(index, isSelected, "right")
  end
  ret = ret .. highlight.hl(highlight.get_hl_name(constants.highlight_names.fill))

  return ret
end

---------------------------------------------------------------------------//
-- Tabline Constructor
---------------------------------------------------------------------------//
---@return string #Returns the tabline
local tabline = function()
  local line = ""
  for i = 1, vim.fn.tabpagenr("$"), 1 do
    line = line .. cell(i)
  end
  -- fill the rest with this hl group
  line = line .. highlight.hl(highlight.get_hl_name(constants.highlight_names.fill)) .. "%="
  if vim.fn.tabpagenr("$") > 1 then
    -- end the line with this terminator
    line = line .. highlight.hl(highlight.get_hl_name(constants.highlight_names.fill)) .. "%999XX"
  end
  return line
end

---@param highlights HighlightOpts #Highlight option fields
---@return nil
M.theme_update = function(highlights)
  if highlights then
    M.__config.highlight = vim.tbl_deep_extend("keep", highlights, M.__config.highlight)
  end
  for i, hlgrp in pairs(M.__config.highlight) do
    if constants.highlight_names[i] then
      local hl = highlight.update_component_highlight_group(hlgrp, constants.highlight_names[i])
    end
  end
end

---------------------------------------------------------------------------//
-- Setup Function
---------------------------------------------------------------------------//
---@param opts SetupOpts? #Setup options
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
      print("highlights")
      M.__config.opts.highlight = opts.highlight
      local high = M.__config.highlight
      if high ~= nil then
        for i, hlgrp in pairs(high) do
          print(i)
          P(hlgrp)
        end
      end
      M.__config.highlight = vim.tbl_deep_extend("keep", M.__config.opts.highlight, M.__config.highlight)
    end
  end

  print("highlight config")
  P(M.__config.highlight)

  print("grpadd \n")
  for i, hlgrp in pairs(M.__config.highlight) do
    if constants.highlight_names[i] then
      -- TODO change to highlight.create_component_highlight_group() when testing is done
      local hl = highlight.update_component_highlight_group(hlgrp, constants.highlight_names[i])
    end
  end

  vim.opt.tabline = "%!v:lua.require'ztab'.tabline()"
  return M
end

M.create_hl_groups = function()
  print("creating groups")
  M.__config.highlight = highlight.default_hl()
  setup(M.__config.opts)
  for i, hlgrp in pairs(M.__config.highlight) do
    if constants.highlight_names[i] then
      -- TODO change to highlight.create_component_highlight_group() when testing is done
      local hl = highlight.update_component_highlight_group(hlgrp, constants.highlight_names[i])
    end
  end
end

return {
  helpers = M,
  setup = setup,
  tabline = tabline,
}
