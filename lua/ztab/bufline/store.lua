local dP = require('ztab.utils').dP
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
          ["content"] = constants.sep_chars[sep.type][1]
        },
      }),
      title = test.ZTabPart:new({
        highlight = {
          ["content"] = {
            sel = highlight.hl(highlight.get_hl_name(constants.highlight_names.title, true, true, true, false)),
            nosel = highlight.hl(highlight.get_hl_name(constants.highlight_names.title, false, true, true, false))
          },
        },
        text = {
          ["content"] = require('ztab.bufline').title(bufnr, self.isSelected)
        },
        updateContent = function() require('ztab.bufline').title(bufnr, self.isSelected) end
      }),
      status = test.ZTabPart:new({
        highlight = {
          ["content"] = {
            sel = highlight.hl(highlight.get_hl_name(constants.highlight_names.modified, true, true, true, false)),
            nosel = highlight.hl(highlight.get_hl_name(constants.highlight_names.modified, false, true, true, false))
          },
        },
        text = {
          ["content"] = ' '
        },
      }),
      devicon = test.ZTabPart:new({
        highlight = {
          ["content"] = {
            sel = highlight.hl(highlight.get_hl_name(constants.highlight_names.modified, true, true, true, false)),
            nosel = highlight.hl(highlight.get_hl_name(constants.highlight_names.modified, false, true, true, false))
          },
        },
        text = {
          ["content"] = require('ztab.bufline').devicon(bufnr, self.isSelected, false)
        },
      }),
      rsep = test.ZTabPart:new({
        highlight = {
          ["content"] = {
            sel = highlight.hl(highlight.get_hl_name(constants.highlight_names.separator, true, true, true, false)),
            nosel = highlight.hl(highlight.get_hl_name(constants.highlight_names.separator, false, true, true, false))
          },
        },
        text = {
          ["content"] = constants.sep_chars[sep.type][2]
        },
      }),
    }
  }
  self.__index = self
  return setmetatable(o, self)
end

function BufTab:updateSelected(s)
  self.isSelected = vim.api.nvim_get_current_buf() == self.nbuf
end

local amnt = 0

function BufTab:draw()
  self:updateSelected()
  if amnt < 2 then
    for i, n in pairs(self.parts) do
      require('ztab.utils').dP(n)
    end
    amnt = amnt + 1
  end
  local line = ''
  line = line .. self.parts.lsep:draw()
  line = line .. self.parts.title:draw()
  line = line .. self.parts.status:draw()
  line = line .. self.parts.devicon:draw()
  line = line .. self.parts.rsep:draw()
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
  return self.bufs[ztabbuf].nbuf
end

---@param bufnr number #Buffer number to run filter on
---@return boolean #true = pass, false = fail
function Store:buffilter(bufnr)
  local bufinfo = vim.fn.getbufinfo(bufnr)[1]
  if bufinfo == nil then
    dP({ bufnr, "info=null" })
    return false
  end
  local ft = vim.fn.getbufvar(bufnr, "&filetype")
  local hidden = bufinfo.hidden == 1
  if bufinfo.name == "" or nil then
    dP({ bufnr, "name=null" })
    return false
  end
  if ft == "" or nil then
    return false
  end
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    dP({ bufnr, "loaded=false" })
    return false
  end
  if not (tonumber(vim.api.nvim_buf_line_count(bufnr)) > 0) then
    dP({ bufnr, "lines<=0 " })
    -- print(vim.api.nvim_buf_line_count(bufnr) .. " buf:" .. bufnr)
    return false
  end
  if hidden then
    dP({ bufnr, "hidden=true" })
    -- return false
  end

  -- print(vim.api.nvim_buf_line_count(bufnr) .. " buf:" .. bufnr)
  dP({ bufnr, "pass" })
  return true
end

return Store
