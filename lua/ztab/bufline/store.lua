local utils = require('ztab.utils')
local test = require('ztab.test')
local constants = require('ztab.constants')
local highlight = require('ztab.highlight')
---@type ZConfig
local con = require("ztab").helpers.__config

---@class BufTab
BufTab = {
  ---Neovim buffer number
  ---@type number | nil
  nbuf = nil,
  ---@type boolean
  isSelected = true,
  ---@type {lsep: ZTabPart, title: ZTabPart, status: ZTabPart, devicon: ZTabPart, rsep: ZTabPart }
  parts = {
  }
}

local t1 = 0

---@param bufnr number
---@param sep {r: boolean,l: boolean, type: ZTabSeparatorNames}
---@return BufTab
function BufTab:new(bufnr, sep)
  ---@type BufTab
  local o = {
    nbuf = bufnr,
    parts = {
      lsep = test.ZTabPart:new({
        highlight = {
          ["content"] = {
            sel = highlight.hl(highlight.get_hl_name(constants.highlight_names.separator, true, true, true, false)),
            nosel = highlight.hl(highlight.get_hl_name(constants.highlight_names.separator, false, true, true, false))
          },
        },
        text = {
          ["content"] = constants.sep_chars[sep.type][2] .. " "
        },
      }),
      title = test.ZTabPart:new({
        highlight = {
          ["content"] = {
            sel = highlight.hl(highlight.get_hl_name(constants.highlight_names.title, true, true, true, false)),
            nosel = highlight.hl(highlight.get_hl_name(constants.highlight_names.title, false, true, true, false))
          },
        },
        ---@type fun(s: ZTabPart): nil
        getter = function(s)
          local title = require('ztab.bufline.getters.title').get(bufnr, self.isSelected)
          if title then
            s.text["content"] = title.content
            s.highlight["content"].sel = highlight.hl(title.hlsel)
            s.highlight["content"].nosel = highlight.hl(title.hldsel)
          end
        end,
      }),
      status = test.ZTabPart:new({
        highlight = {
          ["content"] = {
            sel = highlight.hl(highlight.get_hl_name(constants.highlight_names.modified, true, true, true, false)),
            nosel = highlight.hl(highlight.get_hl_name(constants.highlight_names.modified, false, true, true, false))
          },
        },
        text = {
          ["content"] = '   '
        },
      }),
      devicon = test.ZTabPart:new({
        highlight = {
          ["content"] = {
            sel = highlight.hl(highlight.get_hl_name(constants.highlight_names.modified, true, true, true, false)),
            nosel = highlight.hl(highlight.get_hl_name(constants.highlight_names.modified, false, true, true, false))
          },
        },
        ---@type fun(s: ZTabPart): nil
        getter = function(s)
          local dev = require('ztab.bufline.getters.devicon').get(bufnr, false)
          if t1 < 9 then
            P(dev)
            t1 = t1 + 1
          end
          if dev then
            s.text["content"] = dev.content
            s.highlight["content"].sel = highlight.hl(dev.hlsel)
            s.highlight["content"].nosel = highlight.hl(dev.hldsel)
          end
        end,
      }),
      rsep = test.ZTabPart:new({
        highlight = {
          ["content"] = {
            sel = highlight.hl(highlight.get_hl_name(constants.highlight_names.separator, true, true, true, false)),
            nosel = highlight.hl(highlight.get_hl_name(constants.highlight_names.separator, false, true, true, false))
          },
        },
        text = {
          ["content"] = " " .. constants.sep_chars[sep.type][1]
        },
      }),
    }
  }
  self.__index = self
  return setmetatable(o, self)
end

---@param s boolean
function BufTab:updateSelected(s)
  self.isSelected = s
end

local amnt = 0

---@param type ZTabSepStrings
function BufTab:draw(type)
  for k, _ in pairs(self.parts) do
    if (type ~= "slant" or type ~= "padded_slant") then
      if (k ~= "lsep" or k ~= "rsep") then
        self.parts[k].isSelected = self.isSelected
      else
        self.parts[k].isSelected = false
      end
    else
      self.parts[k].isSelected = self.isSelected
    end
  end
  -- get this functional
  local lsep = self.parts.lsep:draw()
  local title = self.parts.title:draw()
  local status = self.parts.status:draw()
  local devicon = self.parts.devicon:draw()
  local rsep = self.parts.rsep:draw()
  if amnt < 2 then
    amnt = amnt + 1
  end
  local line = ''
  line = line .. lsep
  line = line .. title
  line = line .. status
  line = line .. devicon
  line = line .. rsep
  return line
end

local id = 0

---@class Store
Store = {
  ---@type BufTab[]
  bufs = {},
}

---Create new store item
---@param o table? #table that would be made into a store
---@return Store
function Store:new(o)
  local idstor = { id = id }
  id = id + 1
  o = vim.tbl_deep_extend('force', idstor, o or {})
  self.__index = self
  return setmetatable(o, self)
end

---Remove buffer by Neovim buffer id
---@param nbuf number #neovim buffer id
function Store:remnbuf(nbuf)
  local zbuf = self:getzbuf(nbuf)
  if zbuf ~= nil then
    table.remove(self.bufs, zbuf)
  end
end

---Add buffer to ztab list by neovim buffer id
---@param nbuf number #neovim buffer id
function Store:addbuf(nbuf)
  if self:buffilter(nbuf) then
    if self:getzbuf(nbuf) == nil then
      local o = BufTab:new(nbuf, { l = con.bufline.left_sep, r = con.bufline.right_sep, type = con.bufline.sep_name })
      table.insert(self.bufs, o)
    end
  end
end

---Return ztab buffer tab number from nvim buffer number
---@param nvimbuf number #nvim buffer number
---@return number | nil #ztab buffer tab number
function Store:getzbuf(nvimbuf)
  local rtrn = nil
  for i, n in pairs(self.bufs) do
    if n.nbuf == nvimbuf then
      rtrn = i
    end
  end
  return rtrn
end

---Return nvim buffer from ztab buffer tab number
---@param ztabbuf number #ztab buffer tab number
---@return number | nil #nvim buffer number
function Store:getnbuf(ztabbuf)
  local ztab = tonumber(ztabbuf)
  local buftab = nil
  for i, n in ipairs(self.bufs) do
    if i == ztab then
      buftab = n.nbuf
    end
  end
  if buftab then
    return buftab
  else
    return nil
  end
end

---@param bufnr number #Buffer number to run filter on
---@return boolean #true = pass, false = fail
function Store:buffilter(bufnr)
  local bufinfo = vim.fn.getbufinfo(bufnr)[1]
  if bufinfo == nil then
    utils.dP({ bufnr, "info=null" })
    return false
  end
  local ft = vim.fn.getbufvar(bufnr, "&filetype")
  local hidden = bufinfo.hidden == 1
  if bufinfo.name == "" or nil then
    utils.dP({ bufnr, "name=null" })
    return false
  end
  if ft == "" or nil then
    return false
  end
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    utils.dP({ bufnr, "loaded=false" })
    return false
  end
  if not (tonumber(vim.api.nvim_buf_line_count(bufnr)) > 0) then
    utils.dP({ bufnr, "lines<=0 " })
    -- print(vim.api.nvim_buf_line_count(bufnr) .. " buf:" .. bufnr)
    return false
  end
  if hidden then
    utils.dP({ bufnr, "hidden=true" })
    -- return false
  end

  -- print(vim.api.nvim_buf_line_count(bufnr) .. " buf:" .. bufnr)
  utils.dP({ bufnr, "pass" })
  return true
end

function Store:updateSelected(nbuf)
  for k, v in pairs(self.bufs) do
    if v.nbuf == nbuf then
      self.bufs[k].isSelected = true
    else
      self.bufs[k].isSelected = false
    end
  end
end

return Store
