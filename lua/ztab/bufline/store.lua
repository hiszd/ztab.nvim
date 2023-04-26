Store = {
  ---@type table<number, number>
  bufs = {},
  ---@type number
  bufcount = 0,
}

function Store:new(o)
  o = o or {} -- create object if user does not provide one
  setmetatable(o, self)
  self.__index = self
  return o
end

---@param bufs table
function Store:updatebufs(bufs)
  self.bufs = bufs
  local count = 0
  for _ in pairs(bufs) do
    count = count + 1
  end
  self.bufcount = count
end

---@param nbuf number #ztab buffer
function Store:remnbuf(nbuf)
  local zbuf = self:getzbuf(nbuf)
  if zbuf ~= nil then
    print("nbuf: " .. nbuf .. " zbuf: " .. zbuf)
    table.remove(self.bufs, zbuf)
    self.bufcount = self.bufcount - 1
  end
end

---@param zbuf number #ztab buffer
function Store:remzbuf(zbuf)
  table.remove(self.bufs, zbuf)
  self.bufcount = self.bufcount - 1
end

---@param nbuf number
function Store:addbuf(nbuf)
  local len = self.bufcount
  if self:getzbuf(nbuf) then
    return
  end
  table.insert(self.bufs, len + 1, nbuf)
  self.bufcount = len + 1

  print("zbufs")
  P(self.bufs)
end

---Return ztab buffer tab number from nvim buffer number
---@param nvimbuf number #nvim buffer number
---@return number | nil #ztab buffer tab number
function Store:getzbuf(nvimbuf)
  for zbuf, buf in pairs(self.bufs) do
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
