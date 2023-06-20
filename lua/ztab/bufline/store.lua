Store = {
  ---@type table<number, number>
  bufs = {},
  ---@type number
  bufcount = 0,
}

---Create new store item
---@param o table? #table that would be made into a store
---@return any
function Store:new(o)
  o = o or {} -- create object if user does not provide one
  setmetatable(o, self)
  self.__index = self
  return o
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
end

---Remove buffer by Neovim buffer id
---@param nbuf number #neovim buffer id
function Store:remnbuf(nbuf)
  local zbuf = self:getzbuf(nbuf)
  if zbuf ~= nil then
    table.remove(self.bufs, zbuf)
    self.bufcount = self.bufcount - 1
  end
end

---Remove buffer by ztab buffer index
---@param zbuf number #ztab buffer
function Store:remzbuf(zbuf)
  table.remove(self.bufs, zbuf)
  self.bufcount = self.bufcount - 1
end

---Add buffer to ztab list by neovim buffer id
---@param nbuf number #neovim buffer id
function Store:addbuf(nbuf)
  local len = self.bufcount
  if self:getzbuf(nbuf) then
    return
  end
  table.insert(self.bufs, len + 1, nbuf)
  self.bufcount = len + 1
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

return Store
