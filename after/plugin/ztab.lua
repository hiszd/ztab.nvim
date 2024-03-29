local dP = require('ztab.utils').dP

-- Buffer events
vim.api.nvim_create_autocmd({ "BufDelete", "BufUnload" }, {
  callback = function(info)
    dP({ info, require("ztab.bufline")._private.store.bufs })
    local zbuf = require("ztab.bufline")._private.store:getzbuf(info.buf)
    if zbuf ~= nil then
      require("ztab.bufline")._private.store:remnbuf(info.buf)
      vim.cmd("redrawstatus")
    end
  end,
})

vim.api.nvim_create_autocmd("BufRead", {
  callback = function(info)
    require("ztab.bufline")._private.store:addbuf(info.buf)
    vim.cmd("redrawstatus")
  end,
})

-- Tab events
vim.api.nvim_create_autocmd("TabNew", {
  callback = function()
    require("ztab.bufline")._private.tabsactive(true)
  end,
})

vim.api.nvim_create_autocmd("TabClosed", {
  callback = function()
    if vim.fn.tabpagenr("$") <= 1 then
      require("ztab.bufline")._private.tabsactive(false)
    end
  end,
})
