local constants = require("ztab.constants")
local highlight = require("ztab.highlight")
local utils = require("ztab.utils")

--- Get tab devicon content
---@param bufnr number #Buffer number
---@param isSelected boolean #Is the buffer selected?
---@param ntab boolean #Are tabs active?
---@return {icon: string, hlsel: string, hldsel: string} | nil #Return devicon with highlights
local devicon = function(bufnr, isSelected, ntab)
  local tab = ntab and "true" or "false"
  ---@type ZConfig
  local con = require("ztab").helpers.__config
  local icon, devhl, color
  local file = vim.fn.bufname(bufnr)
  local buftype = vim.fn.getbufvar(bufnr, "&buftype")
  local filetype = vim.fn.getbufvar(bufnr, "&filetype")
  local devicons = require("nvim-web-devicons")
  local finalft = ""
  if filetype == "TelescopePrompt" then
    finalft = "telescope"
  elseif filetype == "fugitive" then
    finalft = "git"
  elseif filetype == "vimwiki" then
    finalft = "markdown"
  elseif buftype == "terminal" then
    finalft = "fish"
  else
    icon, devhl = devicons.get_icon(file, vim.fn.expand("#" .. bufnr .. ":e"))
    icon, color = devicons.get_icon_color(file, vim.fn.expand("#" .. bufnr .. ":e"))
  end
  if icon then
    -- create highlight groups for selected and not selected
    local h = require("ztab.highlight")
    local opt = con.bufline.devicon_colors

    -- the color information orgainzed by the option that will need it
    local reqcol = {
      ["selected"] = {
        con.bufline.highlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, true)]],
        con.bufline.highlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, false)]],
        con.bufline.wtabhighlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, true)]],
        con.bufline.wtabhighlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, false)]],
      },
      ["true"] = {
        con.bufline.highlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, true)]],
        con.bufline.highlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, false)]],
        con.bufline.wtabhighlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, true)]],
        con.bufline.wtabhighlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, false)]],
      },
      ["false"] = {
        con.bufline.highlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, true)]],
        con.bufline.highlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, false)]],
        con.bufline.wtabhighlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, true)]],
        con.bufline.wtabhighlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, false)]],
      },
      ["fallback"] = {
        h.extract_highlight_colors("TabLine"),
        h.extract_highlight_colors("TabLineSel"),
      },
    }

    -- the colors for each option
    local colors = {
      ["selected"] = {
        ["true"] = {
          ["false"] = {
            fg = color,
            bg = reqcol["selected"][1].bg,
          },
          ["true"] = {
            fg = color,
            bg = reqcol["selected"][3].bg,
          },
        },
        ["false"] = {
          ["false"] = {
            fg = reqcol["selected"][2].fg,
            bg = reqcol["selected"][2].bg,
          },
          ["true"] = {
            fg = reqcol["selected"][2].fg,
            bg = reqcol["selected"][4].bg,
          },
        },
      },
      ["true"] = {
        ["true"] = {
          ["false"] = {
            fg = color,
            bg = reqcol["selected"][1].bg,
          },
          ["true"] = {
            fg = color,
            bg = reqcol["selected"][3].bg,
          },
        },
        ["false"] = {
          ["false"] = {
            fg = color,
            bg = reqcol["selected"][2].bg,
          },
          ["true"] = {
            fg = color,
            bg = reqcol["selected"][4].bg,
          },
        },
      },
      ["false"] = {
        ["true"] = {
          ["false"] = {
            fg = reqcol["selected"][1].fg,
            bg = reqcol["selected"][1].bg,
          },
          ["true"] = {
            fg = reqcol["selected"][3].fg,
            bg = reqcol["selected"][3].bg,
          },
        },
        ["false"] = {
          ["false"] = {
            fg = reqcol["selected"][2].fg,
            bg = reqcol["selected"][2].bg,
          },
          ["true"] = {
            fg = reqcol["selected"][4].fg,
            bg = reqcol["selected"][4].bg,
          },
        },
      },
    }
    local hlsel = "TabLineSel"
    local hldsel = "TabLine"
    local hl_name_sel = h.get_hl_name(devhl, true, true, true, false)
    local selcolcmp = h.extract_highlight_colors(hl_name_sel)
    local ifpt11 = (selcolcmp.found == false)
    local ifpt22 = (selcolcmp.fg ~= color)
    if ifpt11 or ifpt22 then
      hlsel = h.update_component_highlight_group({
        bg = colors[opt]["true"][tab].bg,
        fg = colors[opt]["true"][tab].fg,
        sp = con.bufline.highlight[constants.highlight_vars[h.get_hl_name(constants.highlight_names.icon, true)]].sp,
        underline = con.bufline.highlight[constants.highlight_vars[h.get_hl_name(
          constants.highlight_names.icon,
          true
        )]].underline,
      }, hl_name_sel, false, false, false)
    else
      hlsel = hl_name_sel
    end
    local hl_name_dsel = h.get_hl_name(devhl, false, true, true, false)
    local dselcolcmp = h.extract_highlight_colors(hl_name_dsel)
    local ifpt1 = (dselcolcmp.found == false)
    local ifpt2 = (dselcolcmp.fg ~= color)
    if ifpt1 or ifpt2 then
      hldsel = h.update_component_highlight_group({
        bg = colors[con.bufline.devicon_colors]["false"][tab].bg,
        fg = colors[con.bufline.devicon_colors]["false"][tab].fg,
        sp = con.bufline.highlight[constants.highlight_vars[h.get_hl_name(
          constants.highlight_names.icon,
          false
        )]].sp,
        underline = con.bufline.highlight[constants.highlight_vars[h.get_hl_name(
          constants.highlight_names.icon,
          false
        )]].underline,
      }, hl_name_dsel, false, false, false)
    else
      hldsel = hl_name_dsel
    end

    -- local selectedHlStart = h.hl(isSelected and hlsel or hldsel)
    -- local selectedHlEnd = h.hl(h.get_hl_name(constants.highlight_names.title, isSelected, true, true, false))
    -- local rtrn = selectedHlStart .. icon .. selectedHlEnd .. spacer(isSelected)
    local rtrn = { icon = icon, hlsel = hlsel, hldsel = hldsel }
    return rtrn
  end
  return nil
end

return {
  get = devicon
}
