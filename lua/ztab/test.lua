local utils = require('ztab.utils')

---@class ZPart
---@field highlight ZTabHighlightGroup
---@field content string
---@field prefix string
---@field postfix string
---@field drawfunc ZPartDrawFunc

---@alias ZPartDrawFunc fun(s: ZPart): string

---@type ZPart
local part = {
  highlight = {
  },
  content = '',
  prefix = '',
  postfix = '',
  drawfunc = function(s)
    return s.content
  end
}

---Create new store item
---@param o table? #table that would be made into a store
---@return any
function part:new(o)
  o = o or {} -- create object if user does not provide one
  setmetatable(o, self)
  self.__index = self
  return o
end

function part:draw()
  part.drawfunc(self)
end

---Provide a custom rendering function for the part
---@param f ZPartDrawFunc #the function to draw the part
function part:setDraw(f)
  part.drawfunc = f
end

---Replace the content with a new string
---@param c string #new content to replace the old
function part:fill(c)
  self.content = c
end

---Append to the content of the part
---@param c string #content to append to the old
function part:append(c)
  self.content = self.content .. c
end

---Prepend to the content of the part
---@param c string #content to prepend to the old
function part:prepend(c)
  self.content = c .. self.content
end
