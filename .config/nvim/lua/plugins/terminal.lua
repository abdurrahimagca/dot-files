-- Terminals under <leader>t.
--
-- Toggling HIDES the window rather than closing it: win:toggle -> hide ->
-- close({ buf = false }), which skips the buffer wipe (snacks/win.lua:619,542).
-- The shell keeps running and comes back with its scrollback intact. `q` in
-- normal mode inside the terminal does the same thing.
--
-- Two upstream sharp edges shape the opts below:
--
-- 1. snacks keys terminals by cmd/cwd/env/count only -- NOT by window position
--    (snacks/terminal.lua:176). Two toggles that differ only by position would
--    resolve to the same id, so the float would just re-toggle the bottom
--    terminal. The explicit counts keep them separate.
--
-- 2. cwd MUST resolve identically from inside the terminal, or toggling from
--    within computes a different id and spawns a duplicate instead of hiding.
--    LazyVim.root() cannot do that: it resolves per-buffer, and a terminal
--    buffer's name is `term://...`, so bufpath() fs_realpath's it to nil, the
--    lsp and .git detectors bail, and it falls back to vim.uv.cwd(). Whenever
--    nvim's cwd is not the project root, those two disagree. Omitting cwd lets
--    snacks default to getcwd(0), which reads the same from any buffer.
--    (LazyVim's own <leader>ft passes cwd = LazyVim.root() and has this quirk.)
--
-- Tradeoff of the pinned counts: a count prefix (2<leader>tt) no longer opens a
-- second bottom terminal. Positions staying correct is worth more.
return {
  "folke/snacks.nvim",
  keys = {
    { "<leader>t", "", desc = "+terminal" },
    {
      "<leader>tt",
      function()
        Snacks.terminal.toggle(nil, { count = 1, win = { position = "bottom" } })
      end,
      desc = "Terminal (bottom)",
    },
    {
      "<leader>tf",
      function()
        Snacks.terminal.toggle(nil, { count = 2, win = { position = "float" } })
      end,
      desc = "Terminal (float)",
    },
  },
}
