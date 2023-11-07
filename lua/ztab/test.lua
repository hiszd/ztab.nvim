local M = {}

---@alias ZTabPartDrawFunc fun(s: ZTabPart): string

---@class ZTabPart
---@field highlight? ZTabHighlightGroup
---@field content? string
---@field prefix? string
---@field postfix? string
---@field drawfunc ZTabPartDrawFunc
---@field __index? ZTabPart
---@field new? fun(self: ZTabPart, o?: table): ZTabPart
---@field draw? fun(self: ZTabPart): any
---@field setDraw? fun(self: ZTabPart, f: ZTabPartDrawFunc)
---@field append? fun(self: ZTabPart, c: string)
---@field prepend? fun(self: ZTabPart, c: string)


---@type ZTabPart
M.ZTabPart = {
  drawfunc = function(s)
    return s.content
  end
}

---Create new store item
function M.ZTabPart:new(o)
  o = o or {} -- create object if user does not provide one
  setmetatable(o, self)
  self.__index = self
  return o
end

function M.ZTabPart:draw()
  -- local rtrn = ''
  -- local p = M.ZTabPart.drawfunc(self)
  -- for s in string.gmatch(p, "%S+") do
  --   rtrn = rtrn .. self[s]
  -- end
  -- return rtrn

  return M.ZTabPart.drawfunc(self)
end

---Provide a custom rendering function for the part
---@param f ZTabPartDrawFunc #the function to draw the part
function M.ZTabPart:setDraw(f)
  M.ZTabPart.drawfunc = f
end

---Append to the content of the part
---@param c string #content to append to the old
function M.ZTabPart:append(c)
  self.content = self.content .. c
end

---Prepend to the content of the part
---@param c string #content to prepend to the old
function M.ZTabPart:prepend(c)
  self.content = c .. self.content
end

return M
