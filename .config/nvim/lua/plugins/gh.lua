-- GitHub issues/PRs via snacks.gh.
--
-- <leader>gi/gI/gp/gP already come from LazyVim's editor.snacks_picker extra,
-- and snacks.gh sets `needs_setup = false`, so upstream's "recommended setup"
-- is a no-op here. This file covers only the gaps.
--
-- The big one is Actions: snacks.gh reads `statusCheckRollup` once when a PR
-- buffer opens and never refreshes it. There is no run browser and no watch.
-- The `gh` CLI does both, so the actions below drive it in a terminal float.

---Run a gh command in a float.
---auto_close is deliberately off: it defaults on via `interactive`
---(snacks/terminal.lua:105), which would tear the window down the instant a
---watch finishes -- destroying the result you were waiting for.
---@param cmd string[]
---@param title string
local function gh_float(cmd, title)
  return Snacks.terminal.open(cmd, {
    interactive = false,
    win = {
      position = "float",
      width = 0.85,
      height = 0.85,
      border = "rounded",
      title = " " .. title .. " ",
      title_pos = "center",
    },
  })
end

---Borrow snacks' own check icons so runs read like the rest of the gh UI.
---@param run table
local function run_icon(run)
  local icons = Snacks.gh.config().icons.checks
  if run.status ~= "completed" then
    return icons.pending
  elseif run.conclusion == "success" then
    return icons.success
  elseif run.conclusion == "failure" or run.conclusion == "timed_out" then
    return icons.failure
  end
  return icons.skipped
end

---Pick a workflow run, then watch it (or view it, if it already finished).
---@param opts? { branch?: string, repo?: string }
local function runs_picker(opts)
  opts = opts or {}
  local args = {
    "gh", "run", "list", "--limit", "40",
    "--json", "databaseId,displayTitle,status,conclusion,workflowName,headBranch,event",
  }
  if opts.branch then
    vim.list_extend(args, { "--branch", opts.branch })
  end
  if opts.repo then
    vim.list_extend(args, { "--repo", opts.repo })
  end

  vim.system(args, { text = true }, function(res)
    vim.schedule(function()
      if res.code ~= 0 then
        local err = vim.trim(res.stderr or "")
        return Snacks.notify.error("gh run list failed:\n" .. (err ~= "" and err or "exit " .. res.code))
      end
      local ok, runs = pcall(vim.json.decode, res.stdout)
      if not ok or type(runs) ~= "table" or #runs == 0 then
        return Snacks.notify.warn("No workflow runs" .. (opts.branch and (" on " .. opts.branch) or ""))
      end

      Snacks.picker.select(runs, {
        prompt = opts.branch and ("Runs on " .. opts.branch) or "Workflow runs",
        format_item = function(run)
          return ("%s %s  %s  %s"):format(run_icon(run), run.workflowName, run.displayTitle, run.headBranch)
        end,
      }, function(run)
        if not run then
          return
        end
        local id = tostring(run.databaseId)
        -- `run watch` only works while a run is in flight; it errors on a
        -- finished run, so fall back to `view` for those.
        local cmd = run.status == "completed" and { "gh", "run", "view", id } or { "gh", "run", "watch", id }
        if opts.repo then
          vim.list_extend(cmd, { "--repo", opts.repo })
        end
        gh_float(cmd, (run.status == "completed" and "Run " or "Watching ") .. run.workflowName)
      end)
    end)
  end)
end

---Register extra actions into snacks.gh's actions pane.
---`get_actions` iterates the actions table (snacks/gh/actions.lua:698) and
---filters on `type`/`enabled`, so adding keys here is enough to surface them
---when a PR is selected.
local function register_actions()
  local actions = require("snacks.gh.actions")

  actions.actions.gh_watch_checks = {
    desc = "Watch CI checks",
    icon = " ",
    type = "pr",
    priority = 90,
    title = "Watch checks for PR #{number}",
    enabled = function(item)
      return item.state == "open"
    end,
    action = function(item)
      gh_float({
        "gh", "pr", "checks", tostring(item.number),
        "--repo", item.repo, "--watch", "--interval", "10",
      }, "Checks · PR #" .. item.number)
    end,
  }

  actions.actions.gh_workflow_runs = {
    desc = "Workflow runs",
    icon = " ",
    type = "pr",
    priority = 90,
    title = "Workflow runs for PR #{number}",
    action = function(item)
      -- headRefName is in the api's `view` field set but not `list`, so it is
      -- nil when this fires straight off the picker. Resolve it when missing.
      if item.headRefName then
        return runs_picker({ branch = item.headRefName, repo = item.repo })
      end
      vim.system({
        "gh", "pr", "view", tostring(item.number),
        "--repo", item.repo, "--json", "headRefName", "-q", ".headRefName",
      }, { text = true }, function(res)
        vim.schedule(function()
          local branch = vim.trim(res.stdout or "")
          if res.code ~= 0 or branch == "" then
            return Snacks.notify.error("Could not resolve branch for PR #" .. item.number)
          end
          runs_picker({ branch = branch, repo = item.repo })
        end)
      end)
    end,
  }
end

return {
  "folke/snacks.nvim",
  -- LazyVim's snacks spec defines `config`, not `init`, so this is safe to add.
  init = function()
    LazyVim.on_very_lazy(register_actions)
  end,
  keys = {
    { "<leader>gw", function() runs_picker() end, desc = "GitHub Workflow Runs" },
  },
  opts = {
    gh = {
      -- Upstream default is a flat 15 lines, which doesn't scale with the
      -- screen. Values <1 resolve as a fraction of the parent window.
      scratch = { height = 0.5 },
      keys = {
        -- In a gh buffer, `c` and `o` are bound to close/reopen, shadowing
        -- vim's change and open-line operators. Unlike merge/checkout, the
        -- close action carries no confirm prompt, so a reflexive `c` walks
        -- straight into closing someone's PR. Move both off muscle memory.
        close = { "gC", "gh_close", desc = "Close" },
        reopen = { "gO", "gh_reopen", desc = "Reopen" },
      },
    },
  },
}
