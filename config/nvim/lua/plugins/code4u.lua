-- CODE4U · tokyonight repintado con la paleta de la terminal
return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
      transparent = true,
      styles = { sidebars = "transparent", floats = "transparent" },
      on_colors = function(c)
        c.bg, c.bg_dark = "#0d0f24", "#12153a"
        c.bg_highlight = "#1b1f4a"
        c.bg_float, c.bg_popup, c.bg_sidebar = "#12153a", "#1b1f4a", "#0d0f24"
        c.fg, c.fg_dark, c.comment = "#f2ead8", "#aab4f2", "#6b79d6"
        c.blue, c.border, c.border_highlight = "#6b79d6", "#2a2f5e", "#e33a8e"
        c.magenta, c.purple = "#e33a8e", "#ff7cbd"
        c.red, c.green = "#d8323c", "#7fd6a8"
        c.yellow, c.orange, c.cyan = "#f2c76b", "#f2b0c9", "#6bc9d6"
      end,
      on_highlights = function(hl, c)
        local none = "NONE"
        -- todo transparente: que se vea el mapa de fondo
        for _, g in ipairs({
          "Normal", "NormalNC", "NormalFloat", "NormalSB", "SignColumn", "FoldColumn",
          "EndOfBuffer", "StatusLine", "StatusLineNC", "TabLine", "TabLineFill", "WinBar", "WinBarNC",
          "FloatTitle", "Pmenu", "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeEndOfBuffer",
          "SnacksNormal", "SnacksNormalNC", "SnacksPicker", "SnacksPickerList", "SnacksPickerInput",
          "SnacksPickerPreview", "SnacksPickerBox", "SnacksDashboardNormal", "WhichKeyNormal",
          "TelescopeNormal", "TelescopePromptNormal", "TelescopeResultsNormal", "TelescopePreviewNormal",
          "LazyNormal", "MasonNormal", "NoiceCmdlinePopup", "NotifyBackground",
        }) do
          local cur = type(hl[g]) == "table" and hl[g] or {}
          hl[g] = vim.tbl_extend("force", cur, { bg = none })
        end
        -- bordes en azul de ruta, títulos en magenta
        hl.FloatBorder = { fg = "#6b79d6", bg = none }
        hl.FloatTitle = { fg = "#e33a8e", bg = none, bold = true }
        hl.WinSeparator = { fg = "#2a2f5e", bg = none }
        hl.SnacksPickerBorder = { fg = "#6b79d6", bg = none }
        hl.SnacksPickerTitle = { fg = "#e33a8e", bold = true }
        hl.NotifyBackground = { bg = "#0d0f24" }
        -- únicos tintes: cursor, selección y menú
        hl.CursorLine = { bg = "#1b1f4a" }
        hl.CursorLineNr = { fg = "#ff7cbd", bold = true }
        hl.LineNr = { fg = "#2a2f5e" }
        hl.Visual = { bg = "#5a1f45" }
        hl.PmenuSel = { bg = "#5a1f45", fg = "#f2ead8", bold = true }
        hl.PmenuSbar = { bg = none }
        hl.PmenuThumb = { bg = "#6b79d6" }
        hl.Search = { bg = "#6b79d6", fg = "#0d0f24" }
        hl.IncSearch = { bg = "#e33a8e", fg = "#f2ead8" }
      end,
    },
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "tokyonight" } },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options.section_separators = ""
      opts.options.component_separators = "·"
      -- lualine sin fondo en el centro, bloques de modo en magenta
      local t = require("lualine.themes.tokyonight-night")
      for _, m in pairs(t) do if m.c then m.c.bg = "NONE" end end
      t.normal.a.bg = "#e33a8e"; t.normal.b = { bg = "#1b1f4a", fg = "#f2ead8" }
      opts.options.theme = t
    end,
  },
}
