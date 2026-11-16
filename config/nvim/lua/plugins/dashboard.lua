-- CODE4U · dashboard con arte de img2art (ver lua/code4u/header.lua)
return {
  "folke/snacks.nvim",
  opts = function(_, opts)
    opts.dashboard = opts.dashboard or {}
    opts.dashboard.sections = {
      function() return require("code4u.header").section() end,
      { text = { { "CODE 🌹 4U", hl = "SnacksDashboardHeader" } }, align = "center", padding = 1 },
      { section = "keys", gap = 1, padding = 1 },
      { section = "startup" },
    }
  end,
}
