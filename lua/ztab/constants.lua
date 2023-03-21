local M = {}
---------------------------------------------------------------------------//
-- Constants
---------------------------------------------------------------------------//
---@type string
M.padding = " "

---@type string
M.indicator = "▎"

---@type table<string, string>
M.hl_appends = {
  ["selected"] = "Selected",
}

---@type table
M.highlight_names = {
  separator = "Separator",
  separator_sel = "SeparatorSelected",
  title = "Title",
  title_sel = "TitleSelected",
  modified = "Modified",
  modified_sel = "ModifiedSelected",
  icon = "Icon",
  icon_sel = "IconSelected",
  fill = "Fill",
}

---@type table
M.sep_names = {
  thin = "thin",
  thick = "thick",
  slant = "slant",
  slope = "slope",
  padded_slant = "padded_slant",
}

---@type table<string, string[]>
M.sep_chars = {
  [M.sep_names.thin] = { "▏", "▕" },
  [M.sep_names.thick] = { "▌", "▐" },
  [M.sep_names.slant] = { "", "" },
  [M.sep_names.slope] = { "", "" },
  [M.sep_names.padded_slant] = { "" .. M.padding, "" .. M.padding },
}

---@type string
M.positions_key = "BufferlinePositions"

---@type table
M.visibility = {
  SELECTED = 3,
  INACTIVE = 2,
  NONE = 1,
}

---@type string
M.FOLDER_ICON = ""

---@type string
M.ELLIPSIS = "…"

return M
