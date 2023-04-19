vim.api.nvim_create_autocmd("BufDelete", {
  callback = function(info)
    require("ztab.bufline")._private.remnbuf(info.buf)
    vim.cmd("redrawstatus")
  end,
})

vim.api.nvim_create_autocmd("BufAdd", {
  callback = function(info)
    require("ztab.bufline")._private.addbuf(info.buf)
    vim.cmd("redrawstatus")
  end,
})
