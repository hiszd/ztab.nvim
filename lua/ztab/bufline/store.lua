local dP = require('ztab.utils').dP
local test = require('ztab.test')
local constants = require('ztab.constants')
local highlight = require('ztab.highlight')

---@class BufTab
BufTab = {
  ---Neovim buffer number
  ---@type number | nil
  nbuf = nil,
  ---@type {lsep: ZTabPart, title: ZTabPart, status: ZTabPart, devicon: ZTabPart, rsep: ZTabPart }
  parts = {
  }
}

---@param bufnr number
---@param sep {r: boolean,l: boolean, type: ZTabSeparatorNames}
---@return BufTab
function BufTab:new(bufnr, sep, title)
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
        content = constants.sep_chars[sep.type][1]
      }),
      title = test.ZTabPart:new({
        highlight = {
          ["content"] = {
            sel = highlight.hl(highlight.get_hl_name(constants.highlight_names.title, true, true, true, false)),
            nosel = highlight.hl(highlight.get_hl_name(constants.highlight_names.title, false, true, true, false))
          },
        },
        content = title
      }),
      status = test.ZTabPart:new({
        highlight = {
          ["content"] = {
            sel = highlight.hl(highlight.get_hl_name(constants.highlight_names.modified, true, true, true, false)),
            nosel = highlight.hl(highlight.get_hl_name(constants.highlight_names.modified, false, true, true, false))
          },
        },
        content = ' '
      }),
      devicon = test.ZTabPart:new({
        highlight = {
          ["content"] = {
            sel = highlight.hl(highlight.get_hl_name(constants.highlight_names.modified, true, true, true, false)),
            nosel = highlight.hl(highlight.get_hl_name(constants.highlight_names.modified, false, true, true, false))
          },
        },
        content = require('ztab.bufline').devicon()
      }),
    }
  }
  self.__index = self
  return setmetatable(o, self)
end

local id = 0

---@class Store
Store = {
  ---@type {}: BufTab
  bufs = {},
}

---Create new store item
---@param o table? #table that would be made into a store
---@return Store
function Store:new(o)
  local idstor = { id = id }
  id = id + 1
  local o = vim.tbl_deep_extend('force', idstor, o or {})
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
    local len = table.maxn(self.bufs)
    if self:getzbuf(nbuf) == nil then
      table.insert(self.bufs, len + 1, nbuf)
      self.bufcount = len + 1
    end
  end
end

---Return ztab buffer tab number from nvim buffer number
---@param nvimbuf number #nvim buffer number
---@return number | nil #ztab buffer tab number
function Store:getzbuf(nvimbuf)
end

---Return nvim buffer from ztab buffer tab number
---@param ztabbuf number #ztab buffer tab number
---@return number | nil #nvim buffer number
function Store:getnbuf(ztabbuf)
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
        }
        content = constants.sep_chars[sep.type][1]
      })
    }
  }
  self.__index = self
  return setmetatable(o, self)
end

local id = 0

---@class Store
Store = {
  ---@type {}: BufTab
  bufs = {},
}

---Create new store item
---@param o table? #table that would be made into a store
---@return Store
function Store:new(o)
  local idstor = { id = id }
  id = id + 1
  local o = vim.tbl_deep_extend('force', idstor, o or {})
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
    local len = table.maxn(self.bufs)
    if self:getzbuf(nbuf) == nil then
      table.insert(self.bufs, len + 1, nbuf)
      self.bufcount = len + 1
    end
  end
end

---Return ztab buffer tab number from nvim buffer number
---@param nvimbuf number #nvim buffer number
---@return number | nil #ztab buffer tab number
function Store:getzbuf(nvimbuf)
end

---Return nvim buffer from ztab buffer tab number
---@param ztabbuf number #ztab buffer tab number
---@return number | nil #nvim buffer number
function Store:getnbuf(ztabbuf)
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
