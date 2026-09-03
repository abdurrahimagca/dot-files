-- Snacks UI sizing.
--
-- Upstream picker floats are 0.8 x 0.8, which leaves a lot of screen unused on
-- a large terminal. Bump the two presets LazyVim actually selects between:
-- `default` on wide terminals, `vertical` when under 120 columns.
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      -- Show dotfiles (and gitignored files such as .env) everywhere. Keep the
      -- repository's internal .git directory out of results.
      sources = {
        explorer = { hidden = true, ignored = true, exclude = { ".git", ".git/**" } },
        files = { hidden = true, ignored = true },
        grep = { hidden = true, ignored = true },
        grep_word = { hidden = true, ignored = true },
      },
      layouts = {
        default = { layout = { width = 0.92, height = 0.92 } },
        vertical = { layout = { width = 0.92, height = 0.92 } },
      },
    },
  },
}
