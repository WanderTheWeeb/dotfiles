-- CODE4U · markdown de primera: render bonito, imágenes en kitty, ortografía es+en
local P = {
  dark = "#12153a", hi = "#1b1f4a", dim = "#2a2f5e",
  fg = "#f2ead8", mag = "#e33a8e", pink = "#ff7cbd", blue = "#6b79d6",
  cyan = "#6bc9d6", green = "#7fd6a8", yellow = "#f2c76b", orange = "#f2b0c9",
}

local function hl()
  local set = vim.api.nvim_set_hl
  local heads = { P.mag, P.pink, P.blue, P.cyan, P.green, P.yellow }
  local bgs = { "#3a1230", "#3a1a38", "#1e2350", "#143040", "#163428", "#3a3018" }
  for i = 1, 6 do
    set(0, "RenderMarkdownH" .. i, { fg = heads[i], bold = true })
    set(0, "RenderMarkdownH" .. i .. "Bg", { fg = heads[i], bg = bgs[i], bold = true })
    set(0, "@markup.heading." .. i .. ".markdown", { fg = heads[i], bold = true })
  end
  set(0, "RenderMarkdownCode", { bg = P.dark })
  set(0, "RenderMarkdownCodeInline", { bg = P.hi, fg = P.pink })
  set(0, "RenderMarkdownBullet", { fg = P.mag })
  set(0, "RenderMarkdownDash", { fg = P.dim })
  set(0, "RenderMarkdownQuote", { fg = P.blue })
  set(0, "RenderMarkdownTableHead", { fg = P.mag })
  set(0, "RenderMarkdownTableRow", { fg = P.dim })
  set(0, "RenderMarkdownChecked", { fg = P.green })
  set(0, "RenderMarkdownUnchecked", { fg = P.dim })
  set(0, "RenderMarkdownTodo", { fg = P.yellow })
  set(0, "RenderMarkdownLink", { fg = P.cyan, underline = true })
  set(0, "@markup.link.url", { fg = P.cyan, underline = true })
  set(0, "@markup.strong", { fg = P.fg, bold = true })
  set(0, "@markup.italic", { fg = P.orange, italic = true })
  set(0, "SpellBad", { undercurl = true, sp = P.mag })
  set(0, "SpellCap", { undercurl = true, sp = P.blue })
end
vim.api.nvim_create_autocmd("ColorScheme", { callback = hl })
hl()

-- ortografía es+en en md/texto/commits (z= sugerencias, zg agrega palabra, ]s siguiente error)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = { "es", "en" }
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.conceallevel = 2
  end,
})

return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      render_modes = { "n", "c", "t" },
      anti_conceal = { enabled = true },
      heading = {
        sign = false,
        icons = { "▌ ", "▌▌ ", "▌▌▌ ", "◆ ", "◇ ", "· " },
        width = "block", left_pad = 1, right_pad = 2,
      },
      code = { sign = false, width = "block", left_pad = 2, right_pad = 2, border = "thin" },
      bullet = { icons = { "●", "○", "◆", "◇" } },
      checkbox = {
        unchecked = { icon = "󰄱 " },
        checked = { icon = "󰄵 ", scope_highlight = "@markup.strikethrough" },
        custom = { todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" } },
      },
      dash = { icon = "─" },
      pipe_table = { style = "full", cell = "padded" },
      quote = { icon = "▍" },
      latex = { enabled = false },
    },
    keys = { { "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", ft = "markdown", desc = "Render on/off" } },
  },
  {
    "iamcco/markdown-preview.nvim",
    keys = { { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "Vista previa en navegador" } },
  },
  { "folke/which-key.nvim", opts = { spec = { { "<leader>m", group = "markdown" } } } },
  -- imágenes en kitty: pon el cursor sobre ![](foto.png) y sale flotando
  { "folke/snacks.nvim", opts = { image = { enabled = true, doc = { inline = false, float = true, max_width = 60, max_height = 20 } } } },
  -- markdownlint sin las reglas ruidosas (largo de línea, html, etc.)
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        ["markdownlint-cli2"] = { args = { "--config", vim.fn.stdpath("config") .. "/markdownlint.yaml", "--" } },
      },
    },
  },
}
