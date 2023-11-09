local dP = require('ztab.utils').dP
local test = require('ztab.test')

---@class BufTab
BufTab = {
  ---Neovim buffer number
  ---@type number | nil
  number = nil,
  ---@type ZTabPart
  parts = {}
}

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

---Replace the buffers int the Store with bufs
---@param bufs table #list of buffers
function Store:updatebufs(bufs)
  self.bufs = bufs
  local count = 0
  for _ in pairs(bufs) do
    count = count + 1
  end
  self.bufcount = count
  -- self:changed()
end

---Remove buffer by Neovim buffer id
---@param nbuf number #neovim buffer id
function Store:remnbuf(nbuf)
  local zbuf = self:getzbuf(nbuf)
  if zbuf ~= nil then
    table.remove(self.bufs, zbuf)
    self.bufcount = self.bufcount - 1
  end
  -- self:changed()
end

---Remove buffer by ztab buffer index
---@param zbuf number #ztab buffer
function Store:remzbuf(zbuf)
  table.remove(self.bufs, zbuf)
  self.bufcount = self.bufcount - 1
  -- self:changed()
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
  -- self:changed()
end

---Return ztab buffer tab number from nvim buffer number
---@param nvimbuf number #nvim buffer number
---@return number | nil #ztab buffer tab number
function Store:getzbuf(nvimbuf)
  for zbuf, buf in pairs(self.bufs) do
    if buf == nvimbuf then
      return zbuf
    end
  end
end

---Return nvim buffer from ztab buffer tab number
---@param ztabbuf number #ztab buffer tab number
---@return number | nil #nvim buffer number
function Store:getnbuf(ztabbuf)
  ---@type number
  local bufcount = self.bufcount
  if tonumber(bufcount) >= tonumber(ztabbuf) then
    for zb, nb in ipairs(Store.bufs) do
      if tonumber(zb) == tonumber(ztabbuf) then
        return nb
      end
    end
  end
  return nil
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
