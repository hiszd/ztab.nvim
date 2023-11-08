local test = require('ztab.test')
local utils = require('ztab.utils')

local testpart = test.ZTabPart:new({ content = "Bobby", prefix = "Fuck" })
testpart:setDraw(function(s) return s.prefix .. " " .. s.content end)

utils.dP(testpart:draw())
utils.dP(testpart:getHighlight("content"))
utils.dP(testpart)
