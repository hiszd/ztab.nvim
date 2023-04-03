-- Same autocommand written with a Lua function instead
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    require("ztab").helpers.create_hl_groups()
  end,
})
