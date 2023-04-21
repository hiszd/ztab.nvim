require("ztab.types")

local constants = require("ztab.constants")
local highlight = require("ztab.highlight")

---@param isSelected boolean #Is the tab selected
---@return string #Return spacer with highlights
local spacer = function(isSelected)
  local selhl = highlight.hl(highlight.get_hl_name(constants.highlight_names.title, true, true, false, true))
  local hl = highlight.hl(highlight.get_hl_name(constants.highlight_names.title, false, true, false, true))

  return (isSelected and selhl or hl) .. " "
end

--- Get tab title text
---@param bufnr number #Buffer number
---@param isSelected boolean #Is the tab selected?
---@return string #Return title component with highlights
local title = function(bufnr, isSelected)
  local hl = highlight.get_hl_name(constants.highlight_names.title, isSelected, true, false, true)
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
local modified = function(bufnr, isSelected)
  local hl = highlight.get_hl_name(constants.highlight_names.modified, isSelected, true, false, true)
  local ret = highlight.hl(hl)
  ret = ret .. (vim.fn.getbufvar(bufnr, "&modified") == 1 and ("[+]" .. spacer(isSelected)) or "")
  return ret
end

--- Get tab devicon content
---@param bufnr number #Buffer number
---@param isSelected boolean #Is the tab selected?
---@return string #Return devicon with highlights
local devicon = function(bufnr, isSelected)
  local con = require("ztab").helpers.__config
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
    local hl_name = h.get_hl_name(constants.highlight_names.icon, isSelected)
    local hl_name_full = h.get_hl_name(constants.highlight_names.icon, isSelected, true, false, true)
    local defaultcol = { fg = "fg", bg = "bg" }
    local colors = defaultcol
    colors = h.extract_highlight_colors((isSelected and devhl or hl_name)) or defaultcol
    if con.tabline.devicon_colors == "true" then
      colors = h.extract_highlight_colors(devhl) or defaultcol
    elseif con.tabline.devicon_colors == "false" then
      colors = h.extract_highlight_colors(hl_name) or defaultcol
    end

    -- P(M.__config.highlight[constants.highlight_vars[hl_name]].sp)

    local bghl = h.extract_highlight_colors(hl_name_full)
    if bghl ~= nil then
      colors.bg = bghl.bg or defaultcol.bg
    end
    local hl = h.update_component_highlight_group({
      bg = colors.bg,
      fg = colors.fg,
      sp = con.tabline.highlight[constants.highlight_vars[hl_name]].sp,
      underline = con.tabline.highlight[constants.highlight_vars[hl_name]].underline,
    }, h.get_hl_name(devhl, isSelected, false), false, false, true)
    -- P("hl: " .. (hl or '') .. ' and ' .. h.get_hl_name(devhl, isSelected, false))
    local selectedHlStart = h.hl(hl)
    local selectedHlEnd = h.hl(h.get_hl_name(constants.highlight_names.title, isSelected, true, false, true))
    return selectedHlStart .. icon .. selectedHlEnd .. spacer(isSelected)
  end
  return ""
end

---Get separator content
---@param index number #Tab index
---@param sel boolean #Is the tab selected?
---@param side "left" | "right" | "" #Side of separator to render
---@return string #Seperator with highlights
local separator = function(index, sel, side)
  local con = require("ztab").helpers.__config
  if side ~= "left" and side ~= "right" then
    return ""
  end
  local hl = highlight.get_hl_name(constants.highlight_names.separator, sel, true, false, true)
  -- local last = index == vim.fn.tabpagenr("$")
  local first = index == 1
  local sep = ""

  if side == "left" then
    sep = constants.sep_chars[con.tabline.sep_name][2]
    if
        first and con.tabline.sep_name == constants.sep_names.slant
        or first and con.tabline.sep_name == constants.sep_names.slope
    then
      return highlight.hl(hl) .. ""
    end
    return highlight.hl(hl) .. sep
  elseif side == "right" then
    sep = constants.sep_chars[con.tabline.sep_name][1]
    return highlight.hl(hl) .. sep
  end

  return ""
end

---Produce the tab cell
---@param index number #Tab index
---@return string #Tab cell
local cell = function(index)
  local con = require("ztab").helpers.__config
  local isSelected = vim.fn.tabpagenr() == index
  local buflist = vim.fn.tabpagebuflist(index)
  local winnr = vim.fn.tabpagewinnr(index)
  local bufnr = buflist[winnr]

  local spacing = spacer(isSelected)

  local ret = ""
  if con.tabline.right_sep then
    ret = ret .. separator(index, isSelected, "left")
  end
  ret = ret
      .. "%"
      .. index
      .. "T"
      .. spacing
      .. title(bufnr, isSelected)
      .. spacing
      .. modified(bufnr, isSelected)
      -- .. devicon(bufnr, isSelected)
      .. "%T"
  if con.tabline.left_sep then
    ret = ret .. separator(index, isSelected, "right")
  end
  ret = ret .. highlight.hl(highlight.get_hl_name(constants.highlight_names.fill, false, false, true))

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
  line = line .. highlight.hl(highlight.get_hl_name(constants.highlight_names.fill, false, false, true)) .. "%="
  if vim.fn.tabpagenr("$") > 1 then
    -- end the line with this terminator
    line = line
        .. highlight.hl(highlight.get_hl_name(constants.highlight_names.fill, false, false, true))
        .. "%999XX"
  end
  return line
end

return {
  draw = tabline,
}
