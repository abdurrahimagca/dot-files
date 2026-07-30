-- Snacks UI sizing.
--
-- Upstream picker floats are 0.8 x 0.8, which leaves a lot of screen unused on
-- a large terminal. Bump the two presets LazyVim actually selects between:
-- `default` on wide terminals, `vertical` when under 120 columns.
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      layouts = {
        default = { layout = { width = 0.92, height = 0.92 } },
        vertical = { layout = { width = 0.92, height = 0.92 } },
      },
    },
  },
}
