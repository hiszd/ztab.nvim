local highlight = require("ztab.highlight")
local constants = require("ztab.constants")
local test = require("ztab.test")

--- Get tab title text
---@param bufnr number #Buffer number
---@param isSelected boolean #Is the tab selected?
---@return {content: string, hlsel: string, hldsel: string} | nil #Return title with highlights
local title = function(bufnr, isSelected)
  local hlsel = "TabLineSel"
  local hldsel = "TabLine"
  hldsel = highlight.get_hl_name(constants.highlight_names.title, false, true, true, false)
  hlsel = highlight.get_hl_name(constants.highlight_names.title, true, true, true, false)
  local file = vim.fn.bufname(bufnr)
  local buftype = vim.fn.getbufvar(bufnr, "&buftype")
  local filetype = vim.fn.getbufvar(bufnr, "&filetype")

  local titl = ''

  if buftype == "help" then
    titl = titl .. "help:" .. vim.fn.fnamemodify(file, ":t:r")
  elseif buftype == "quickfix" then
    titl = titl .. "quickfix"
  elseif filetype == "TelescopePrompt" then
    titl = titl .. "Telescope"
  elseif filetype == "git" then
    titl = titl .. "Git"
  elseif filetype == "fugitive" then
    titl = titl .. "Fugitive"
  elseif file:sub(file:len() - 2, file:len()) == "FZF" then
    titl = titl .. "FZF"
  elseif buftype == "terminal" then
    local _, mtch = string.match(file, "term:(.*):(%a+)")
    titl = titl .. (mtch ~= nil and mtch or vim.fn.fnamemodify(vim.env.SHELL, ":t"))
  elseif file == "" then
    titl = titl .. "[No Name]"
  else
    titl = titl .. vim.fn.pathshorten(vim.fn.fnamemodify(file, ":p:~:t"))
  end

  local rtrn = { content = titl, hlsel = hlsel, hldsel = hldsel }
  return rtrn
end

return {
  get = title
}
