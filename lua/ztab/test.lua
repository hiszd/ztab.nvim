require('ztab.class')

local M = {}

M.id = 0
---@alias ZTabPartDrawFunc fun(s: ZTabPart): string

---@class ZTabPart
M.ZTabPart = {
  ---@type {[string]: {sel: string, nosel: string}}
  highlight = {
    ["content"] = {
      sel = '',
      nosel = '',
    },
    ["prefix"] = {
      sel = '',
      nosel = '',
    },
    ["postfix"] = {
      sel = '',
      nosel = '',
    },
  },
  ---@type {[string]: string}
  text = {
    ["content"] = '',
    ["prefix"] = '',
    ["postfix"] = '',
  },
  ---@type boolean
  isSelected = false,
  __drawfunc = function(s)
    return s.text["prefix"] .. " " .. s.text["content"] .. " " .. s.text["postfix"]
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
  local o = vim.tbl_deep_extend('force', idtab, o or {})
  self.__index = self
  return setmetatable(o, self)
end

---@return any
function M.ZTabPart:draw()
  return M.ZTabPart.__drawfunc(self)
end

---Provide a custom rendering function for the part
---@param f ZTabPartDrawFunc #the function to draw the part
---@return nil
function M.ZTabPart:setDraw(f)
  M.ZTabPart.__drawfunc = f
end

---If c ~= nil then set self.text.content to c, else return self.text.content
---@return string | nil
---@param c? string
function M.ZTabPart:content(c)
  if c then
    self.text["content"] = c
  else
    return self.text["content"]
  end
end

---If c ~= nil then set self.text.prefix to c, else return self.text.prefix
---@return string | nil
---@param c? string
function M.ZTabPart:prefix(c)
  if c then
    self.text["prefix"] = c
  else
    return self.text["prefix"]
  end
end

---If c ~= nil then set self.text.postfix to c, else return self.text.postfix
---@return string | nil
---@param c? string
function M.ZTabPart:postfix(c)
  if c then
    self.text["postfix"] = c
  else
    return self.text["postfix"]
  end
end

---Get Highlight information
---@param n "content" | "prefix" | "postfix" #The name of the element you want the highlight for
---@return {sel: string, nosel: string}
function M.ZTabPart:getHighlight(n)
  return self.highlight[n]
end

---Set Highlight information
---@param n "content" | "prefix" | "postfix" #The name of the element you want the highlight for
---@param h {sel?: string, nosel?: string} #The highlight group you want it changed to
function M.ZTabPart:setHighlight(n, h)
  self.highlight[n] = vim.tbl_deep_extend("force", self.highlight[n], h or {})
end

return M
