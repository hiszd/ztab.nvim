---@diagnostic disable: unused-local

require('ztab.types')

local constants = require('ztab.constants')
local highlight = require('ztab.highlight')
local util = require('ztab.utils')

local defaulthl = highlight.extract_highlight_colors('Tabline') or
    { bg = '', fg = '', background = '', foreground = '' }
local defaultselhl = highlight.extract_highlight_colors('TablineSel') or
    { bg = '', fg = '', background = '', foreground = '' }

---@type table
local M = {}

---------------------------------------------------------------------------//
-- Default Config
---------------------------------------------------------------------------//
---@type ConfigType
M.__config = {
  sep_name = constants.sep_names.thick,
  highlight = {
    ["separator"] = {
      fg = defaulthl.fg,
      bg = defaulthl.bg,
    },
    ["separator_sel"] = {
      fg = defaultselhl.fg,
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
  }
}

---@type string
local tabselhl = '%#TabLineSel#'
---@type string
local tabhl = '%#TabLine#'

-- Get tab title text
M.title = function(bufnr, isSelected)
  local hl = highlight.get_hl_name(constants.highlight_names.title, isSelected)
  local file = vim.fn.bufname(bufnr)
  local buftype = vim.fn.getbufvar(bufnr, '&buftype')
  local filetype = vim.fn.getbufvar(bufnr, '&filetype')

  local rtrn = highlight.hl(hl)
  P("title: " .. highlight.hl(hl))

  if buftype == 'help' then
    rtrn = rtrn .. 'help:' .. vim.fn.fnamemodify(file, ':t:r')
  elseif buftype == 'quickfix' then
    rtrn = rtrn .. 'quickfix'
  elseif filetype == 'TelescopePrompt' then
    rtrn = rtrn .. 'Telescope'
  elseif filetype == 'git' then
    rtrn = rtrn .. 'Git'
  elseif filetype == 'fugitive' then
    rtrn = rtrn .. 'Fugitive'
  elseif file:sub(file:len() - 2, file:len()) == 'FZF' then
    rtrn = rtrn .. 'FZF'
  elseif buftype == 'terminal' then
    local _, mtch = string.match(file, "term:(.*):(%a+)")
    rtrn = rtrn .. mtch ~= nil and mtch or vim.fn.fnamemodify(vim.env.SHELL, ':t')
  elseif file == '' then
    rtrn = rtrn .. '[No Name]'
  else
    rtrn = rtrn .. vim.fn.pathshorten(vim.fn.fnamemodify(file, ':p:~:t'))
  end
  P(rtrn)
  return rtrn
end

M.modified = function(bufnr, isSelected)
  local hl = highlight.get_hl_name(constants.highlight_names.modified, isSelected)
  P(highlight.hl(hl))
  local ret = highlight.hl(hl)
  ret = ret .. vim.fn.getbufvar(bufnr, '&modified') == 1 and '[+] ' or ''
  ret = ret .. (isSelected and tabselhl or tabhl)
  return ret
end

M.devicon = function(bufnr, isSelected)
  local icon, devhl
  local file = vim.fn.bufname(bufnr)
  local buftype = vim.fn.getbufvar(bufnr, '&buftype')
  local filetype = vim.fn.getbufvar(bufnr, '&filetype')
  local devicons = require 'nvim-web-devicons'
  if filetype == 'TelescopePrompt' then
    icon, devhl = devicons.get_icon('telescope')
  elseif filetype == 'fugitive' then
    icon, devhl = devicons.get_icon('git')
  elseif filetype == 'vimwiki' then
    icon, devhl = devicons.get_icon('markdown')
  elseif buftype == 'terminal' then
    icon, devhl = devicons.get_icon('zsh')
  else
    icon, devhl = devicons.get_icon(file, vim.fn.expand('#' .. bufnr .. ':e'))
  end
  if icon then
    local h = require 'ztab.highlight'
    local fg = h.extract_highlight_colors(devhl, 'fg')
    local bg = h.extract_highlight_colors('TabLineSel', 'bg')
    local hl = h.create_component_highlight_group({ bg = bg, fg = fg }, devhl)
    local selectedHlStart = (isSelected and hl) and '%#' .. hl .. '#' or ''
    local selectedHlEnd = isSelected and tabselhl or tabhl
    return selectedHlStart .. icon .. selectedHlEnd .. ' '
  end
  return ''
end

---Get the seperator
---@param index number
---@param sel boolean
---@param side "left" | "right" | ""
---@return string
M.separator = function(index, sel, side)
  if side ~= "left" and side ~= "right" then
    return ""
  end
  local hl = highlight.get_hl_name(constants.highlight_names.separator, sel)
  local last = index == vim.fn.tabpagenr('$')
  local first = index == 0
  local sep = ""

  if side == "left" then
    sep = constants.sep_chars[M.__config.sep_name][1]
    if first then
      return ''
    end
    return hl .. sep
  elseif side == "right" then
    sep = constants.sep_chars[M.__config.sep_name][2]
    if last then
      return ''
    end
    return hl .. sep .. (sel and tabselhl or tabhl)
  end

  return ''
end


---produce the tab cell
---@param index number
---@param opts CellOpts?
---@return string
local cell = function(index, opts)
  local isSelected = vim.fn.tabpagenr() == index
  local buflist = vim.fn.tabpagebuflist(index)
  local winnr = vim.fn.tabpagewinnr(index)
  local bufnr = buflist[winnr]

  local ret = ''
  if opts and opts.left_sep then
    ret = ret .. M.separator(index, isSelected, "left")
  end
  ret = ret .. '%' .. index .. 'T' .. ' ' ..
      M.title(bufnr, isSelected) .. ' ' ..
      M.modified(bufnr, isSelected) ..
      M.devicon(bufnr, isSelected) .. '%T'
  if opts and opts.right_sep then
    ret = ret .. M.separator(index, isSelected, "right")
  end
  ret = ret .. tabhl

  return ret
end

M.tabline = function()
  local line = ''
  for i = 1, vim.fn.tabpagenr('$'), 1 do
    line = line .. cell(i)
  end
  line = line .. '%#TabLineFill#%='
  if vim.fn.tabpagenr('$') > 1 then
    line = line .. '%#TabLine#%999XX'
  end
  return line
end

---@param opts SetupOpts?
local setup = function(opts)
  if opts then
    if opts.sep_name then M.__config.sep_name = opts.sep_name end
    -- Merge the default configuration and the one provided by the user
    if opts.highlight then M.__config.highlight = util.merge_tables(M.__config.highlight, opts.highlight) end
  end

  if opts and opts.highlight then
    for i, grp in pairs(opts.highlight) do
      if constants.highlight_names[i] and M.__config.highlight[i] then
        M.__config.highlight[i].fg = grp.fg
        M.__config.highlight[i].bg = grp.bg
      else
        print("highlight name " .. i .. "does not exist")
      end
    end
  end
  for i, hlgrp in pairs(M.__config.highlight) do
    if constants.highlight_names[i] then
      local hl = highlight.create_component_highlight_group(hlgrp, constants.highlight_names[i])
    end
  end

  vim.opt.tabline = '%!v:lua.require\'ztab\'.helpers.tabline()'
end

return {
  helpers = M,
  setup = setup,
}
