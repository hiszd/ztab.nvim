---@class NameGenerationArgs
---@field visibility number

---@class CellOpts
---@field left_sep boolean
---@field right_sep boolean

---@class HighlightGroup
---@field fg string
---@field bg string
---@field sp string?

---@class SetupOpts
---@field sep_name SeparatorNames?
---@field highlight HighlightOpts?

---@class HighlightOpts
---@field ["separator"] HighlightGroup?
---@field ["separator_sel"] HighlightGroup?
---@field ["title"] HighlightGroup?
---@field ["title_sel"] HighlightGroup?
---@field ["modified"] HighlightGroup?
---@field ["modified_sel"] HighlightGroup?
---@field ["icon"] HighlightGroup?
---@field ["icon_sel"] HighlightGroup?

---@alias SeparatorNames
---| `constants.sep_names.thin`
---| `constants.sep_names.thick`
---| `constants.sep_names.slant`
---| `constants.sep_names.slope`
---| `constants.sep_names.padded_slant`

---@class ConfigType
---@field sep_name SeparatorNames
---@field highlight HighlightOpts
