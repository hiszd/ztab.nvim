---@type boolean
local debug = true

local function dP(...)
  if debug then
    print(vim.inspect(...))
  end
end

Store = {
  ---@type table<number, number>
  bufs = {},
  ---@type number
  bufcount = 0,
}

function Store:changed()
  ---@type table<number, number>
  local bufs = {}
  for index, value in pairs(self.bufs) do
    -- dP({"raw buf", index, value})
    if self:buffilter(value) then
      bufs[index] = value
      P({"nnn", bufs})
      -- dP({ "correct buf", index, value })
    else
      dP({ "buf removed", index, value })
    end
  end
  self.bufs = bufs
end

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
  self:changed()
end

---Remove buffer by Neovim buffer id
---@param nbuf number #neovim buffer id
function Store:remnbuf(nbuf)
  local zbuf = self:getzbuf(nbuf)
  if zbuf ~= nil then
    table.remove(self.bufs, zbuf)
    self.bufcount = self.bufcount - 1
  end
  self:changed()
end

---Remove buffer by ztab buffer index
---@param zbuf number #ztab buffer
function Store:remzbuf(zbuf)
  table.remove(self.bufs, zbuf)
  self.bufcount = self.bufcount - 1
  self:changed()
end

---Add buffer to ztab list by neovim buffer id
---@param nbuf number #neovim buffer id
function Store:addbuf(nbuf)
  if self:buffilter(nbuf) then
    local len = self.bufcount
    if self:getzbuf(nbuf) == nil then
      table.insert(self.bufs, len + 1, nbuf)
      self.bufcount = len + 1
    end
  end
  self:changed()
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
    return false
  end

  -- print(vim.api.nvim_buf_line_count(bufnr) .. " buf:" .. bufnr)
  dP({ bufnr, "pass" })
  return true
end

return Store
