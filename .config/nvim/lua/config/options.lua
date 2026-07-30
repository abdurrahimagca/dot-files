-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Route yanks through OSC 52 when this nvim is being driven from another
-- machine, so the text lands in *that* machine's clipboard instead of this
-- box's pbcopy. Nvim never picks OSC 52 on its own -- see
-- runtime/autoload/provider/clipboard.vim, it only honours the string form of
-- g:clipboard when set explicitly.
--
-- SSH_TTY covers plain ssh. Mosh sets nothing of its own, so .zshrc walks the
-- process tree and exports MOSH_CONNECTION when mosh-server is an ancestor.
if vim.env.MOSH_CONNECTION or vim.env.SSH_TTY then
  vim.g.clipboard = "osc52"
end
