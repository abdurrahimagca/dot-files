-- Follows the macOS system appearance: gruvbox-material dark in dark mode,
-- gruvbox-material light in light mode. Both use the "hard" contrast variant.
local function system_background()
  if vim.fn.has("mac") == 0 then
    return "dark"
  end
  -- `defaults read` exits non-zero when the key is absent, which means light mode.
  local out = vim.fn.system({ "defaults", "read", "-g", "AppleInterfaceStyle" })
  if vim.v.shell_error == 0 and out:lower():find("dark") then
    return "dark"
  end
  return "light"
end

local function sync_background()
  local bg = system_background()
  if vim.o.background ~= bg then
    vim.o.background = bg
  end
end

return {
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.gruvbox_material_background = "hard"
      vim.g.gruvbox_material_foreground = "original"
      vim.g.gruvbox_material_better_performance = 1
      vim.g.gruvbox_material_enable_italic = 1
      vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
      vim.o.background = system_background()

      -- Re-check whenever nvim regains focus, so flipping the system theme
      -- while nvim is in the background gets picked up on return.
      vim.api.nvim_create_autocmd({ "FocusGained", "VimResume" }, {
        group = vim.api.nvim_create_augroup("gruvbox_follow_system", { clear = true }),
        callback = sync_background,
      })

      vim.api.nvim_create_user_command("BackgroundSync", sync_background, {
        desc = "Match background to macOS appearance",
      })
      vim.keymap.set("n", "<leader>uB", function()
        vim.o.background = vim.o.background == "dark" and "light" or "dark"
      end, { desc = "Toggle light/dark background" })
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox-material",
    },
  },
}
