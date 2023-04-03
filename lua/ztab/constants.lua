local M = {}
---------------------------------------------------------------------------//
-- Constants
---------------------------------------------------------------------------//
---@type string
M.padding = " "

---@type string
local PREFIX = "ZTab"
M.PREFIX = PREFIX

---@type string
M.indicator = "▎"

---@type table<string, string>
M.hl_appends = {
      ["selected"] = "Selected",
}

---@type table
local highlight_names = {
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
M.highlight_names = highlight_names

---@type table<string, string>
M.highlight_vars = {
      [highlight_names.separator] = "separator",
      [PREFIX .. "_" .. highlight_names.separator] = "separator",
      [highlight_names.separator_sel] = "separator_sel",
      [PREFIX .. "_" .. highlight_names.separator_sel] = "separator_sel",
      [highlight_names.title] = "title",
      [PREFIX .. "_" .. highlight_names.title] = "title",
      [highlight_names.title_sel] = "title_sel",
      [PREFIX .. "_" .. highlight_names.title_sel] = "title_sel",
      [highlight_names.modified] = "modified",
      [PREFIX .. "_" .. highlight_names.modified] = "modified",
      [highlight_names.modified_sel] = "modified_sel",
      [PREFIX .. "_" .. highlight_names.modified_sel] = "modified_sel",
      [highlight_names.icon] = "icon",
      [PREFIX .. "_" .. highlight_names.icon] = "icon",
      [highlight_names.icon_sel] = "icon_sel",
      [PREFIX .. "_" .. highlight_names.icon_sel] = "icon_sel",
      [highlight_names.fill] = "fill",
      [PREFIX .. "_" .. highlight_names.fill] = "fill",
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
      [M.sep_names.thin] = { "▕", "▏" },
      [M.sep_names.thick] = { "▐", "▌" },
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
