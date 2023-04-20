require("ztab.types")

local constants = require("ztab.constants")
local highlight = require("ztab.highlight")

---@type table
local M = {}

M.store = {
  ---@type table<number, number>
  bufs = {},
  ---@type number
  bufcount = 0,
}

---@param bufs table
M.updatebufs = function(bufs)
  M.store.bufs = bufs
  local count = 0
  for _ in pairs(bufs) do
    count = count + 1
  end
  M.store.bufcount = count
end

---@param nbuf number #ztab buffer
M.remnbuf = function(nbuf)
  local zbuf = M.getzbuf(nbuf)
  table.remove(M.store.bufs, zbuf)
  M.store.bufcount = M.store.bufcount - 1
end

---@param zbuf number #ztab buffer
M.remzbuf = function(zbuf)
  table.remove(M.store.bufs, zbuf)
  M.store.bufcount = M.store.bufcount - 1
end

---@param nbuf number
M.addbuf = function(nbuf)
  local len = M.store.bufcount
  -- M.store.bufs[len + 1] = nbuf
  table.insert(M.store.bufs, len + 1, nbuf)
  M.store.bufcount = M.store.bufcount + 1

  print("zbufs")
  P(M.store.bufs)
end

---Return ztab buffer tab number from nvim buffer number
---@param nvimbuf number #nvim buffer number
---@return number | nil #ztab buffer tab number
M.getzbuf = function(nvimbuf)
  for zbuf, buf in pairs(M.store.bufs) do
    if buf == nvimbuf then
      -- print("zbuffer:" .. zbuf)
      -- print("nbuffer:" .. nvimbuf)
      return zbuf
    end
  end
end

---Return nvim buffer from ztab buffer tab number
---@param ztabbuf number #ztab buffer tab number
---@return number | nil #nvim buffer number
M.getnbuf = function(ztabbuf)
  ---@type number
  local bufcount = M.store.bufcount
  if tonumber(bufcount) >= tonumber(ztabbuf) then
    for zb, nb in ipairs(M.store.bufs) do
      if tonumber(zb) == tonumber(ztabbuf) then
        return nb
      end
    end
  end
  print("without")
  return nil
end

---@param nbuf number #The nvim buffer you want to navigate to
local nbufgoto = function(nbuf)
  local zbuf = M.getzbuf(nbuf)
  if zbuf then
    vim.api.nvim_set_current_buffer(nbuf)
  end
end

---@param zbuf number #The ztab buffer tab you want to navigate to
local zbufgoto = function(zbuf)
  local nbuf = M.getnbuf(zbuf)
  print("berts")
  print(nbuf)
  if nbuf then
    vim.api.nvim_set_current_buf(nbuf)
  end
end

---@param isSelected boolean #Is the tab selected
---@return string #Return spacer with highlights
local spacer = function(isSelected)
  local selhl = highlight.hl(highlight.get_hl_name(constants.highlight_names.title_sel))
  local hl = highlight.hl(highlight.get_hl_name(constants.highlight_names.title))

  return (isSelected and selhl or hl) .. " "
end

--- Get tab title text
---@param bufnr number #Buffer number
---@param isSelected boolean #Is the tab selected?
---@return string #Return title component with highlights
local title = function(bufnr, isSelected)
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
local modified = function(bufnr, isSelected)
  local hl = highlight.get_hl_name(constants.highlight_names.modified, isSelected)
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
    local hl_name = h.get_hl_name(constants.highlight_names.icon, isSelected, true)
    local defaultcol = { fg = "fg", bg = "bg" }
    local colors = defaultcol
    colors = h.extract_highlight_colors((isSelected and devhl or hl_name)) or defaultcol
    if con.bufline.devicon_colors == "true" then
      colors = h.extract_highlight_colors(devhl) or defaultcol
    elseif con.bufline.devicon_colors == "false" then
      colors = h.extract_highlight_colors(hl_name) or defaultcol
    end

    -- P(M.__config.highlight[constants.highlight_vars[hl_name]].sp)

    local bghl = h.extract_highlight_colors(hl_name)
    if bghl ~= nil then
      colors.bg = bghl.bg or defaultcol.bg
    end
    local hl = h.update_component_highlight_group({
      bg = colors.bg,
      fg = colors.fg,
      sp = con.bufline.highlight[constants.highlight_vars[hl_name]].sp,
      underline = con.bufline.highlight[constants.highlight_vars[hl_name]].underline,
    }, h.get_hl_name(devhl, isSelected, false))
    -- P("hl: " .. (hl or '') .. ' and ' .. h.get_hl_name(devhl, isSelected, false))
    local selectedHlStart = h.hl(hl)
    local selectedHlEnd = h.hl(h.get_hl_name(constants.highlight_names.title, isSelected))
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
  local hl = highlight.get_hl_name(constants.highlight_names.separator, sel)
  -- local last = index == vim.fn.tabpagenr("$")
  local first = index == 1
  local sep = ""

  if side == "left" then
    sep = constants.sep_chars[con.sep_name][2]
    if
        first and con.sep_name == constants.sep_names.slant
        or first and con.sep_name == constants.sep_names.slope
    then
      return highlight.hl(hl) .. ""
    end
    return highlight.hl(hl) .. sep
  elseif side == "right" then
    sep = constants.sep_chars[con.sep_name][1]
    return highlight.hl(hl) .. sep
  end

  return ""
end

---Produce the tab cell
---@param ztab number #Tab index
---@return string #Tab cell
local cell = function(ztab)
  local con = require("ztab").helpers.__config
  local bufnr = M.getnbuf(ztab) and M.getnbuf(ztab) or 0
  local isSelected = vim.api.nvim_get_current_buf() == bufnr
  local selhl = highlight.hl(highlight.get_hl_name(constants.highlight_names.title_sel))
  local hl = highlight.hl(highlight.get_hl_name(constants.highlight_names.title))

  local spacing = (isSelected and selhl or hl) .. spacer(isSelected)

  local ret = ""
  if con.left_sep then
    ret = ret .. separator(ztab, isSelected, "left")
  end
  ret = ret
      .. spacing
      .. title(bufnr, isSelected)
      .. spacing
      .. modified(bufnr, isSelected)
      .. devicon(bufnr, isSelected)
  if con.right_sep then
    ret = ret .. separator(bufnr, isSelected, "right")
  end
  ret = ret .. highlight.hl(highlight.get_hl_name(constants.highlight_names.fill))

  return ret
end

---@param bufnr number #Buffer number to run filter on
---@return boolean #true = pass, false = fail
local buffilter = function(bufnr)
  local ft = vim.fn.getbufvar(bufnr, "&filetype")
  local hidden = vim.fn.getbufinfo(bufnr)[1].hidden == 1
  if ft == "" or nil then
    return false
  end
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    return false
  end
  if hidden then
    return false
  end

  return true
end

---------------------------------------------------------------------------//
-- Bufline Constructor
---------------------------------------------------------------------------//
---@return string #Returns the bufline
local bufline = function()
  local line = ""
  for i = 1, M.store.bufcount, 1 do
    line = line .. cell(i)
  end
  -- fill the rest with this hl group
  line = line .. highlight.hl(highlight.get_hl_name(constants.highlight_names.fill)) .. "%="
  return line
end

return {
  _private = M,
  draw = bufline,
  zbufgoto = zbufgoto,
  nbufgoto = nbufgoto,
}
