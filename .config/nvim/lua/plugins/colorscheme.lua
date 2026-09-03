return {
  {
    "LazyVim/LazyVim",
    opts = {
      -- No plugin theme: use Nvim's defaults with the terminal's ANSI palette.
      colorscheme = function()
        vim.cmd.colorscheme("default")
        vim.opt.termguicolors = false
      end,
    },
  },
}
