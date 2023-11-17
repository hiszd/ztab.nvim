-- local hlmod = require('ztab.highlight')
-- local dP = require('ztab.utils').dP
local M = {}

M.id = 0
---@alias ZTabPartDrawFunc fun(s: ZTabPart): string

---@alias ZTabPartDivs "content" | "postfix" | "prefix"

-- TODO: how to handle dynamic content? Need a fetcher?
---@class ZTabPart
M.ZTabPart = {
  ---@type {[ZTabPartDivs]: {sel: string, nosel: string}}
  highlight = {},
  ---@type {[ZTabPartDivs]: string | fun(): string}
  text = {},
  ---@type boolean
  isSelected = false,
  ---@type fun(s: ZTabPart): nil
  getter = function(s)
  end,
  ---@type ZTabPartDrawFunc
  __drawfunc = function(s)
    if s.isSelected then
      return s:getHighlight("prefix").sel ..
          (s.text["prefix"] and s.text["prefix"] or "") ..
          s:getHighlight("content").sel ..
          (s.text["content"] and s.text["content"] or "") ..
          s:getHighlight("postfix").sel .. (s.text["postfix"] and s.text["postfix"] or "")
    else
      return s:getHighlight("prefix").nosel ..
          (s.text["prefix"] and s.text["prefix"] or "") ..
          s:getHighlight("content").nosel ..
          (s.text["content"] and s.text["content"] or "") ..
          s:getHighlight("postfix").nosel .. (s.text["postfix"] and s.text["postfix"] or "")
    end
  end
}

-- ---Create new store item
-- ---@param o? table
-- ---@return ZTabPart
-- function M.ZTabPart:new(o)
--   o = o or {} -- create object if user does not provide one
--   setmetatable(o, self)
--   self.__index = self
--   return o
-- end

---@param o? table
function M.ZTabPart:new(o)
  local idtab = { id = M.id }
  M.id = M.id + 1
  o = vim.tbl_deep_extend('force', idtab, o or {})
  self.__index = self
  return setmetatable(o, self)
end

---@return any
function M.ZTabPart:draw()
  self:getter()
  return self.__drawfunc(self)
end

---Provide a custom rendering function for the part
---@param f ZTabPartDrawFunc #the function to draw the part
---@return nil
function M.ZTabPart:setDraw(f)
  self.__drawfunc = f
end

---If c ~= nil then set self.text.content to c, else return self.text.content
---@return string | nil
---@param c? string | fun(): string
function M.ZTabPart:content(c)
  if c then
    self.text["content"] = c
  else
    if self.text["content"] then
      if type(self.text["content"]) == "function" then
        return self.text:content()
      elseif type(self.text["content"]) == "string" then
        return tostring(self.text["content"])
      else
        return nil
      end
    end
  end
end

---If c ~= nil then set self.text.prefix to c, else return self.text.prefix
---@return string | function | nil
---@param c? string | function
function M.ZTabPart:prefix(c)
  if c then
    self.text["prefix"] = c
  else
    return self.text["prefix"]
  end
end

---If c ~= nil then set self.text.postfix to c, else return self.text.postfix
---@return string | function | nil
---@param c? string | function
function M.ZTabPart:postfix(c)
  if c then
    self.text["postfix"] = c
  else
    return self.text["postfix"]
  end
end

---Get Highlight information
---@param n ZTabPartDivs #The name of the element you want the highlight for
---@return {sel: string, nosel: string}
function M.ZTabPart:getHighlight(n)
  local hl = self.highlight[n]
  if hl then
    return { sel = hl.sel, nosel = hl.nosel }
  else
    return { sel = "", nosel = "" }
  end
end

---Set Highlight information
---@param n ZTabPartDivs #The name of the element you want the highlight for
---@param h {sel?: string, nosel?: string} #The highlight group you want it changed to
function M.ZTabPart:setHighlight(n, h)
  self.highlight[n] = vim.tbl_deep_extend("force", self.highlight[n], h or {})
end

return M
