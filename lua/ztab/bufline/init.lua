require("ztab.types")

local constants = require("ztab.constants")
local highlight = require("ztab.highlight")
-- local dP = require("ztab.utils").dP

---@type table
local M = {}

local store = require("ztab.bufline.store"):new()

M.store = store

M.get_listed_buffers = function()
  local bufs_loaded = {}

  local getnm = vim.api.nvim_buf_get_name
  local is_loaded = vim.api.nvim_buf_is_loaded
  for i, buf_hndl in ipairs(vim.api.nvim_list_bufs()) do
    if is_loaded(buf_hndl) then
      bufs_loaded[i] = { buf_hndl, getnm(buf_hndl) }
    end
  end

  return bufs_loaded
end

M.get_all_buffers = function()
  local buffers = {}
  local len = 0
  local vim_fn = vim.fn

  for buffer = 1, vim_fn.bufnr('$') do
    len = len + 1
    buffers[len] = buffer
  end

  return buffers
end

---Navigate to a buftab by nvim buffer id
---@param nbuf number #neovim buffer id
local nbufgoto = function(nbuf)
  local zbuf = M.store:getzbuf(nbuf)
  if zbuf then
    vim.api.nvim_set_current_buffer(nbuf)
  end
end

---Navigate to a buftab by ztab buffer index
---@param zbuf number #ztab buffer index
local zbufgoto = function(zbuf)
  local nbuf = M.store:getnbuf(zbuf)
  -- print("berts")
  -- print(nbuf)
  if nbuf then
    vim.api.nvim_set_current_buf(nbuf)
  end
end

local wasactive = false

---Update function for ui changes to bufline when tabline is also open
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
---@param isSelected boolean #Is the buffer selected?
---@param ntab boolean #Are tabs active?
---@return string #Return devicon with highlights
local devicon = function(bufnr, isSelected, ntab)
  local tab = ntab and "true" or "false"
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
        con.bufline.wtabhighlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, true)]],
        con.bufline.wtabhighlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, false)]],
      },
          ["true"] = {
        con.bufline.highlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, true)]],
        con.bufline.highlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, false)]],
        con.bufline.wtabhighlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, true)]],
        con.bufline.wtabhighlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, false)]],
      },
          ["false"] = {
        con.bufline.highlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, true)]],
        con.bufline.highlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, false)]],
        con.bufline.wtabhighlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, true)]],
        con.bufline.wtabhighlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, false)]],
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
              ["false"] = {
            fg = color,
            bg = reqcol["selected"][1].bg,
          },
              ["true"] = {
            fg = color,
            bg = reqcol["selected"][3].bg,
          },
        },
            ["false"] = {
              ["false"] = {
            fg = reqcol["selected"][2].fg,
            bg = reqcol["selected"][2].bg,
          },
              ["true"] = {
            fg = reqcol["selected"][2].fg,
            bg = reqcol["selected"][4].bg,
          },
        },
      },
          ["true"] = {
            ["true"] = {
              ["false"] = {
            fg = color,
            bg = reqcol["selected"][1].bg,
          },
              ["true"] = {
            fg = color,
            bg = reqcol["selected"][3].bg,
          },
        },
            ["false"] = {
              ["false"] = {
            fg = color,
            bg = reqcol["selected"][2].bg,
          },
              ["true"] = {
            fg = color,
            bg = reqcol["selected"][4].bg,
          },
        },
      },
          ["false"] = {
            ["true"] = {
              ["false"] = {
            fg = reqcol["selected"][1].fg,
            bg = reqcol["selected"][1].bg,
          },
              ["true"] = {
            fg = reqcol["selected"][3].fg,
            bg = reqcol["selected"][3].bg,
          },
        },
            ["false"] = {
              ["false"] = {
            fg = reqcol["selected"][2].fg,
            bg = reqcol["selected"][2].bg,
          },
              ["true"] = {
            fg = reqcol["selected"][4].fg,
            bg = reqcol["selected"][4].bg,
          },
        },
      },
    }
    local hlsel = "TabLineSel"
    local hldsel = "TabLine"
    local hl_name_sel = h.get_hl_name(devhl, true, true, true, false)
    local selcolcmp = h.extract_highlight_colors(hl_name_sel)
    local ifpt11 = (selcolcmp.found == false)
    local ifpt22 = (selcolcmp.fg ~= color)
    if ifpt11 or ifpt22 then
      hlsel = h.update_component_highlight_group({
        bg = colors[opt]["true"][tab].bg,
        fg = colors[opt]["true"][tab].fg,
        sp = con.bufline.highlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, true)]].sp,
        underline = con.bufline.highlight[constants.highlight_vars[h.get_hl_name(
              constants.highlight_names.icon,
              true
            )]].underline,
      }, hl_name_sel, false, false, false)
    else
      hlsel = hl_name_sel
    end
    local hl_name_dsel = h.get_hl_name(devhl, false, true, true, false)
    local dselcolcmp = h.extract_highlight_colors(hl_name_dsel)
    local ifpt1 = (dselcolcmp.found == false)
    local ifpt2 = (dselcolcmp.fg ~= color)
    if ifpt1 or ifpt2 then
      hldsel = h.update_component_highlight_group({
        bg = colors[con.bufline.devicon_colors]["false"][tab].bg,
        fg = colors[con.bufline.devicon_colors]["false"][tab].fg,
        sp = con.bufline.highlight[constants.highlight_vars[h.get_hl_name(
              constants.highlight_names.icon,
              false
            )]].sp,
        underline = con.bufline.highlight[constants.highlight_vars[h.get_hl_name(
              constants.highlight_names.icon,
              false
            )]].underline,
      }, hl_name_dsel, false, false, false)
    else
      hldsel = hl_name_dsel
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
      .. devicon(bufnr, isSelected, wasactive)
  if con.bufline.left_sep then
    ret = ret .. separator(bufnr, isSelected, "right")
  end
  ret = ret .. highlight.hl(highlight.get_hl_name(constants.highlight_names.fill, false, true, true, false))

  return ret
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
