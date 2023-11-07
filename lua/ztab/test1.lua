local test = require('ztab.test')
local utils = require('ztab.utils')

local testpart = test.ZTabPart:new({ content = "Bobby", prefix = "Fuck" })
testpart:setDraw(function(s) return s.prefix .. " " .. s.content end)

testpart:setHighlight("content", "ZTab_Buf_Fill")
utils.dP(testpart:draw())
utils.dP(testpart:getHighlight())
utils.dP(testpart)
