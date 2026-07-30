-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Route yanks through OSC 52 when this nvim is being driven from another
-- machine, so the text lands in *that* machine's clipboard instead of this
-- box's pbcopy. Nvim never picks OSC 52 on its own -- see
-- runtime/autoload/provider/clipboard.vim, it only honours the string form of
-- g:clipboard when set explicitly.
--
-- Set unconditionally on purpose. Detecting "am I remote?" does not work here:
-- herdr is a server/client multiplexer whose pane shells are children of the
-- long-lived server process, so they inherit its ancestry (local Ghostty), not
-- that of whatever mosh client is currently attached. Env-var and process-tree
-- probes both fail inside a pane.
--
-- Unconditional is fine because OSC 52 works locally too: Ghostty defaults to
-- clipboard-write = allow, so a local yank still reaches the system clipboard.
vim.g.clipboard = "osc52"
