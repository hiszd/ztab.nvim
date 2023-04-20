---@alias ZTabSeparatorNames
---| `constants.sep_names.thin`
---| `constants.sep_names.thick`
---| `constants.sep_names.slant`
---| `constants.sep_names.slope`
---| `constants.sep_names.padded_slant`

---@alias ZTabDeviconColors
---| "true"
---| "false"
---| "selected"

---@class NameGenerationArgs
---@field visibility number

---@class CellOpts
---@field left_sep boolean
---@field right_sep boolean
--
---@alias ZTabColorInput
---| "activecol.fg"
---| "activecol.bg"
---| "inactivecol.fg"
---| "inactivecol.bg"
---| "fillcol.fg"
---| "fillcol.bg"

---@class ZTabHighlightGroup
---@field fg ZTabColorInput | string
---@field bg ZTabColorInput | string
---@field sp ZTabColorInput | string?
---@field underline boolean?

---@class ZElSetupOpts
---@field enabled boolean?
---@field sep_name ZTabSeparatorNames?
---@field left_sep boolean
---@field right_sep boolean
---@field devicon_colors ZTabDeviconColors
---@field highlight ZTabHighlightOpts?

---@class ZSetupOpts
---@field bufline ZElSetupOpts
---@field tabline ZElSetupOpts

---@class ZTabHighlightOpts
---@field ["separator"] ZTabHighlightGroup?
---@field ["separator_sel"] ZTabHighlightGroup?
---@field ["title"] ZTabHighlightGroup?
---@field ["title_sel"] ZTabHighlightGroup?
---@field ["modified"] ZTabHighlightGroup?
---@field ["modified_sel"] ZTabHighlightGroup?
---@field ["icon"] ZTabHighlightGroup?
---@field ["icon_sel"] ZTabHighlightGroup?
---@field ["fill"] ZTabHighlightGroup?

---@class ZElConfig
---@field sep_name ZTabSeparatorNames
---@field left_sep boolean
---@field right_sep boolean
---@field devicon_colors ZTabDeviconColors
---@field highlight ZTabHighlightOpts

---@class ZConfig
---@field tabline ZElConfig
---@field bufline ZElConfig
---@field opts ZSetupOpts
