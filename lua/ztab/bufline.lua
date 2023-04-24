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
function M.store:updatebufs(bufs)
  self.bufs = bufs
  local count = 0
  for _ in pairs(bufs) do
    count = count + 1
  end
  self.bufcount = count
end

---@param bufs table
M.updatebufs = function(bufs)
  return M.store:updatebufs(bufs)
end

---@param nbuf number #ztab buffer
function M.store:remnbuf(nbuf)
  local zbuf = self:getzbuf(nbuf)
  if zbuf ~= nil then
    print("nbuf: " .. nbuf .. " zbuf: " .. zbuf)
    table.remove(self.bufs, zbuf)
    self.bufcount = self.bufcount - 1
  end
end

---@param nbuf number #ztab buffer
M.remnbuf = function(nbuf)
  return M.store:remnbuf(nbuf)
end

---@param zbuf number #ztab buffer
function M.store:remzbuf(zbuf)
  table.remove(self.bufs, zbuf)
  self.bufcount = self.bufcount - 1
end

---@param zbuf number #ztab buffer
M.remzbuf = function(zbuf)
  return M.store:remzbuf(zbuf)
end

---@param nbuf number
function M.store:addbuf(nbuf)
  local len = self.bufcount
  if M.getzbuf(nbuf) then
    return
  end
  table.insert(self.bufs, len + 1, nbuf)
  self.bufcount = self.bufcount + 1

  print("zbufs")
  P(self.bufs)
end

---@param nbuf number
M.addbuf = function(nbuf)
  return M.store:addbuf(nbuf)
end

---Return ztab buffer tab number from nvim buffer number
---@param nvimbuf number #nvim buffer number
---@return number | nil #ztab buffer tab number
function M.store:getzbuf(nvimbuf)
  for zbuf, buf in pairs(self.bufs) do
    if buf == nvimbuf then
      -- print("zbuffer:" .. zbuf)
      -- print("nbuffer:" .. nvimbuf)
      return zbuf
    end
  end
end

---Return ztab buffer tab number from nvim buffer number
---@param nvimbuf number #nvim buffer number
---@return number | nil #ztab buffer tab number
M.getzbuf = function(nvimbuf)
  return M.store:getzbuf(nvimbuf)
end

---Return nvim buffer from ztab buffer tab number
---@param ztabbuf number #ztab buffer tab number
---@return number | nil #nvim buffer number
function M.store:getnbuf(ztabbuf)
  ---@type number
  local bufcount = M.store.bufcount
  if tonumber(bufcount) >= tonumber(ztabbuf) then
    for zb, nb in ipairs(M.store.bufs) do
      if tonumber(zb) == tonumber(ztabbuf) then
        return nb
      end
    end
  end
  return nil
end

---Return nvim buffer from ztab buffer tab number
---@param ztabbuf number #ztab buffer tab number
---@return number | nil #nvim buffer number
M.getnbuf = function(ztabbuf)
  return M.store:getnbuf(ztabbuf)
end

---@param nbuf number #The nvim buffer you want to navigate to
local nbufgoto = function(nbuf)
  local zbuf = M.store:getzbuf(nbuf)
  if zbuf then
    vim.api.nvim_set_current_buffer(nbuf)
  end
end

---@param zbuf number #The ztab buffer tab you want to navigate to
local zbufgoto = function(zbuf)
  local nbuf = M.store:getnbuf(zbuf)
  print("berts")
  print(nbuf)
  if nbuf then
    vim.api.nvim_set_current_buf(nbuf)
  end
end

local wasactive = false

---@param b boolean #Are there tabs open?
M.tabsactive = function(b)
  if wasactive ~= b then
    wasactive = b
    local con = require("ztab").helpers.__config
    con.bufline.highlight = highlight.default_hl()
    if b then
      for i, hlgrp in pairs(con.bufline.wtabhighlight) do
        if constants.highlight_names[i] then
          highlight.update_component_highlight_group(hlgrp, constants.highlight_names[i], true, true, false)
        end
      end
    elseif not b then
      for i, hlgrp in pairs(con.bufline.highlight) do
        if constants.highlight_names[i] then
          highlight.update_component_highlight_group(hlgrp, constants.highlight_names[i], true, true, false)
        end
      end
    end
  end
end

---@param isSelected boolean #Is the tab selected
---@return string #Return spacer with highlights
local spacer = function(isSelected)
  local selhl = highlight.hl(highlight.get_hl_name(constants.highlight_names.title, true, true, true, false))
  local hl = highlight.hl(highlight.get_hl_name(constants.highlight_names.title, false, true, true, false))

  return (isSelected and selhl or hl) .. " "
end

--- Get tab title text
---@param bufnr number #Buffer number
---@param isSelected boolean #Is the tab selected?
---@return string #Return title component with highlights
local title = function(bufnr, isSelected)
  local hl = highlight.get_hl_name(constants.highlight_names.title, isSelected, true, true, false)
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
  local hl = highlight.get_hl_name(constants.highlight_names.modified, isSelected, true, true, false)
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
  local icon, devhl, color
  local file = vim.fn.bufname(bufnr)
  local buftype = vim.fn.getbufvar(bufnr, "&buftype")
  local filetype = vim.fn.getbufvar(bufnr, "&filetype")
  local devicons = require("nvim-web-devicons")
  if filetype == "TelescopePrompt" then
    icon, devhl = devicons.get_icon("telescope")
    icon, color = devicons.get_icon_color("telescope")
  elseif filetype == "fugitive" then
    icon, devhl = devicons.get_icon("git")
    icon, color = devicons.get_icon_color("git")
  elseif filetype == "vimwiki" then
    icon, devhl = devicons.get_icon("markdown")
    icon, color = devicons.get_icon_color("markdown")
  elseif buftype == "terminal" then
    icon, devhl = devicons.get_icon("zsh")
    icon, color = devicons.get_icon_color("zsh")
  else
    icon, devhl = devicons.get_icon(file, vim.fn.expand("#" .. bufnr .. ":e"))
    icon, color = devicons.get_icon_color(file, vim.fn.expand("#" .. bufnr .. ":e"))
  end
  if icon then
    -- create highlight groups for selected and not selected
    local h = require("ztab.highlight")
    local opt = con.bufline.devicon_colors

    -- the color information orgainzed by the option that will need it
    local reqcol = {
          ["selected"] = {
        con.bufline.highlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, true)]],
        con.bufline.highlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, false)]],
      },
          ["true"] = {
        con.bufline.highlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, true)]],
        con.bufline.highlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, false)]],
      },
          ["false"] = {
        con.bufline.highlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, true)]],
        con.bufline.highlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, false)]],
      },
          ["fallback"] = {
        h.extract_highlight_colors("TabLine"),
        h.extract_highlight_colors("TabLineSel"),
      },
    }

    -- the colors for each option
    local colors = {
          ["selected"] = {
            ["true"] = {
          fg = color,
          bg = reqcol["selected"][1].bg,
        },
            ["false"] = {
          fg = reqcol["selected"][2].fg,
          bg = reqcol["selected"][2].bg,
        },
      },
          ["true"] = {
            ["true"] = {
          fg = color,
          bg = reqcol["selected"][1].bg,
        },
            ["false"] = {
          fg = color,
          bg = reqcol["selected"][2].bg,
        },
      },
          ["false"] = {
            ["true"] = {
          fg = reqcol["selected"][1].fg,
          bg = reqcol["selected"][1].bg,
        },
            ["false"] = {
          fg = reqcol["selected"][2].fg,
          bg = reqcol["selected"][2].bg,
        },
      },
    }
    local hlsel = "TabLineSel"
    local hldsel = "TabLine"
    local hl_name_sel = h.get_hl_name(devhl, true, true, false)
    if
        h.extract_highlight_colors(hl_name_sel).found == false
        or h.extract_highlight_colors(hl_name_sel).fg ~= color
    then
      hlsel = h.update_component_highlight_group({
        bg = colors[opt]["true"].bg,
        fg = colors[opt]["true"].fg,
        sp = con.bufline.highlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, true)]].sp,
        underline = con.bufline.highlight[constants.highlight_vars[h.get_hl_name(
              constants.highlight_names.icon,
              true
            )]].underline,
      }, hl_name_sel, true, true, false)
    end
    local hl_name_dsel = h.get_hl_name(devhl, false, true, false)
    if
        h.extract_highlight_colors(hl_name_dsel).found == false
        or h.extract_highlight_colors(hl_name_dsel).fg ~= color
    then
      hldsel = h.update_component_highlight_group({
        bg = colors[con.bufline.devicon_colors]["false"].bg,
        fg = colors[con.bufline.devicon_colors]["false"].fg,
        sp = con.bufline.highlight[constants.highlight_vars[h.get_hl_name(
              constants.highlight_names.icon,
              false
            )]].sp,
        underline = con.bufline.highlight[constants.highlight_vars[h.get_hl_name(
              constants.highlight_names.icon,
              false
            )]].underline,
      }, hl_name_dsel, false, true, false)
    end

    local selectedHlStart = h.hl(isSelected and hlsel or hldsel)
    local selectedHlEnd = h.hl(h.get_hl_name(constants.highlight_names.title, isSelected, true, true, false))
    local rtrn = selectedHlStart .. icon .. selectedHlEnd .. spacer(isSelected)
    return rtrn
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
  local hl = highlight.get_hl_name(constants.highlight_names.separator, sel, true, true, false)
  -- local last = index == vim.fn.tabpagenr("$")
  local first = index == 1
  local sep = ""

  if side == "left" then
    sep = constants.sep_chars[con.bufline.sep_name][2]
    if
        first and con.bufline.sep_name == constants.sep_names.slant
        or first and con.bufline.sep_name == constants.sep_names.slope
    then
      return highlight.hl(hl) .. ""
    end
    return highlight.hl(hl) .. sep
  elseif side == "right" then
    sep = constants.sep_chars[con.bufline.sep_name][1]
    return highlight.hl(hl) .. sep
  end

  return ""
end

---Produce the tab cell
---@param ztab number #Tab index
---@return string #Tab cell
local cell = function(ztab)
  local con = require("ztab").helpers.__config
  local bufnr = M.store:getnbuf(ztab) and M.store:getnbuf(ztab) or 0
  local isSelected = vim.api.nvim_get_current_buf() == bufnr

  local spacing = spacer(isSelected)

  local ret = ""
  if con.bufline.right_sep then
    ret = ret .. separator(ztab, isSelected, "left")
  end
  ret = ret
      .. spacing
      .. title(bufnr, isSelected)
      .. spacing
      .. modified(bufnr, isSelected)
      .. devicon(bufnr, isSelected)
  if con.bufline.left_sep then
    ret = ret .. separator(bufnr, isSelected, "right")
  end
  ret = ret .. highlight.hl(highlight.get_hl_name(constants.highlight_names.fill, false, true, true, false))

  return ret
end

---@param bufnr number #Buffer number to run filter on
---@return boolean #true = pass, false = fail
M.buffilter = function(bufnr)
  local bufinfo = vim.fn.getbufinfo(bufnr)[1]
  if bufinfo == nil then
    print("info=null")
    return false
  end
  local ft = vim.fn.getbufvar(bufnr, "&filetype")
  local hidden = bufinfo.hidden == 1
  if bufinfo.name == "" or nil then
    print("name=null")
    return false
  end
  if ft == "" or nil then
    return false
  end
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    print("loaded=false")
    return false
  end
  if hidden then
    print("hidden=true")
    return false
  end

  print("pass")
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
  line = line .. highlight.hl(highlight.get_hl_name(constants.highlight_names.fill, false, true, true, false)) .. "%="
  return line
end

return {
  _private = M,
  draw = bufline,
  zbufgoto = zbufgoto,
  nbufgoto = nbufgoto,
}
