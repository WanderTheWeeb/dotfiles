-- CODE4U · convierte el header de img2art (formato alpha-nvim) a secciones de snacks.dashboard
-- regenerar: ~/.config/nvim/scripts/header <imagen> [columnas] [colores] [umbral]
--   ancha:  header art/logo.png 56 16 20
--   chica:  header art/logo-stack.png 32 16 20 && mv lua/code4u/art.lua lua/code4u/art-stack.lua
local M = {}

-- ancha (art.lua) si cabe; si la ventana es chica, la de 2 renglones (art-stack.lua)
function M.section()
  local dir = vim.fn.stdpath("config") .. "/lua/code4u/"
  local small = vim.o.columns < 72 or vim.o.lines < 32
  local file = dir .. (small and "art-stack.lua" or "art.lua")
  local ok, art = pcall(dofile, file) -- dofile: re-aplica los highlights I2A* cada vez
  if not ok or not art then return {} end
  local items = {}
  for i, line in ipairs(art.val) do
    local chunks, prev = {}, nil
    for _, h in ipairs(art.opts.hl[i] or {}) do
      local txt = line:sub(h[2] + 1, h[3])
      if prev and prev.hl == h[1] then
        prev[1] = prev[1] .. txt -- junta celdas contiguas del mismo color
      else
        prev = { txt, hl = h[1] }
        chunks[#chunks + 1] = prev
      end
    end
    items[#items + 1] = { text = chunks, align = "center" }
  end
  items[#items].padding = 1
  return items
end

return M
