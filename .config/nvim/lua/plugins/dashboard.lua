-- Dashboard, based on snacks' `github` example.
--
-- Three of that example's panes are dropped because they'd break here:
-- `colorscript` and `chafa` aren't installed, and neither is the `gh notify`
-- extension (its `n` key also collided with LazyVim's "New File"). Swapped in
-- gh-dash, which IS installed, plus account-wide PR panes -- this setup is for
-- reviewing, so "what's waiting on me" beats a decorative colour strip.
--
-- snacks centers the header line by line, so lines of unequal display width
-- make the art lean. The glyphs need trailing spaces to square up, and trailing
-- whitespace in source is fragile -- editors and formatters strip it silently.
-- Pad to the widest line here so the literal can't drift.
---@param art string
local function pad(art)
  local lines = vim.split(art, "\n", { plain = true, trimempty = true })
  local width = 0
  for _, line in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end
  for i, line in ipairs(lines) do
    lines[i] = line .. (" "):rep(width - vim.fn.strdisplaywidth(line))
  end
  return table.concat(lines, "\n")
end

local header = pad([[
           ▄▄▄████████▄▄▄           
       ▄▄████▀▀▀▀▀▀▀▀▀▀████▄        
     ▄███▀▀              ▀▀██▄▄     
    ███▀                    ▀██▄    
  ▄██▀▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄       ▀██   
 ▄██▀ █████████▀████████       ▀██  
 ██▀  ▀▀▀▀▀▀▀▀ ▄████████▄       ███ 
▄██           ████▀██████▄       ██ 
███          █████  ▀█████       ██▄
███         █████▀   ▀█████      ██▀
▀██        ███▀        █████    ▄██ 
 ███      ██▀           ▀███▄   ██▀ 
  ██▄                    ▀███  ███  
   ███                     ▀▀▄██▀   
    ▀██▄                   ▄███▀    
      ▀███▄▄            ▄▄███▀      
        ▀▀█████▄▄▄▄▄▄█████▀         
             ▀▀▀▀▀▀▀▀▀▀             
]])

-- Go template. Kept in a long string so the `\n` reaches gh literally, which is
-- what its template parser wants.
local pr_template =
  [[{{range .}}{{printf "#%v " .number}}{{.repository.name}}{{"\n"}}  {{truncate 42 .title}}{{"\n"}}{{end}}]]

---Passed to jobstart as a table, so the braces and quotes never touch a shell.
---@param filter string
local function pr_search(filter)
  return {
    "gh", "search", "prs", filter, "--state=open", "-L", "3",
    "--json", "repository,number,title",
    "--template", pr_template,
  }
end

return {
  "folke/snacks.nvim",
  opts = {
    dashboard = {
      preset = { header = header },
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        {
          pane = 2,
          icon = " ",
          desc = "Browse Repo",
          padding = 1,
          key = "b",
          action = function()
            Snacks.gitbrowse()
          end,
        },
        {
          pane = 2,
          icon = " ",
          desc = "gh dash",
          padding = 1,
          key = "d",
          action = function()
            Snacks.terminal.open({ "gh", "dash" }, { win = { position = "float", width = 0.9, height = 0.9 } })
          end,
        },
        function()
          local in_git = Snacks.git.get_root() ~= nil
          local cmds = {
            {
              icon = " ",
              title = "Awaiting My Review",
              cmd = pr_search("--review-requested=@me"),
              key = "v",
              action = function()
                vim.ui.open("https://github.com/pulls/review-requested")
              end,
              height = 7,
              enabled = true, -- account-wide, so useful outside a repo too
            },
            {
              icon = " ",
              title = "My Open PRs",
              cmd = pr_search("--author=@me"),
              key = "P",
              action = function()
                vim.ui.open("https://github.com/pulls")
              end,
              height = 7,
              enabled = true,
            },
            {
              icon = " ",
              title = "Open Issues",
              cmd = "gh issue list -L 3",
              key = "i",
              action = function()
                vim.fn.jobstart("gh issue list --web", { detach = true })
              end,
              height = 7,
            },
            {
              icon = " ",
              title = "Git Status",
              cmd = "git --no-pager diff --stat -B -M -C",
              height = 10,
            },
          }
          return vim.tbl_map(function(cmd)
            return vim.tbl_extend("force", {
              pane = 2,
              section = "terminal",
              enabled = in_git,
              padding = 1,
              ttl = 5 * 60,
              indent = 3,
            }, cmd)
          end, cmds)
        end,
        { section = "startup" },
      },
    },
  },
}
