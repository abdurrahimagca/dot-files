# dotfiles

Bare git repo at `~/.dotfiles`, work-tree is `$HOME`. Files stay where they
live — there is no separate copy to edit. You edit `~/.zshrc`, you commit
`~/.zshrc`.

## Daily use

```sh
dots                      # status (only tracked files, never all of $HOME)
dota ~/.zshrc             # stage
dotc "add fzf keybinds"   # commit
dotp                      # push
dotl                      # last 20 commits
```

`dot` is raw git with the right flags, so anything works: `dot diff`,
`dot restore`, `dot log -p ~/.zshrc`.

## Adding a new config

```sh
dota ~/.config/foo && dotc "track foo" && dotp
```

## New machine

```sh
git clone --bare git@github.com:abdurrahimagca/dotfiles.git ~/.dotfiles
alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
dot config status.showUntrackedFiles no
dot config core.excludesFile "$HOME/.dotfiles-ignore"
dot checkout main          # will refuse if it would clobber existing files
```

If checkout complains about existing files, move them aside and retry.

## Secrets

Never committed. They go in `~/.zshrc.local`, which `.dotfiles-ignore`
excludes. `.zshrc` sources it if present. On a new machine, recreate that file
by hand.

`~/.dotfiles-ignore` also blocks `.ssh/`, `.aws/`, `.gnupg/`, `*.pem`,
`*_history`, `node_modules/` and similar.

## Partially tracked

`~/.config/herdr` holds ~6MB of logs, sockets and session history alongside
its config. `.dotfiles-ignore` excludes the directory and re-includes only
`config.toml`. Same pattern works for any app that mixes config with state.

## Deliberately not tracked

- `~/.config/sketchybar` — untracked on request; files still on disk
- `~/.config/opencode` — contains a committed `node_modules`
- `~/.claude.json` — holds credentials

## nvim history

`~/.config/nvim` used to be its own git repo (7 commits, no remote). It was
absorbed into this repo, so those commits no longer live in
`~/.config/nvim/.git`. The full history is preserved at:

    ~/.dotfiles-backups/nvim-history-20260730.bundle

To get it back: `git clone ~/.dotfiles-backups/nvim-history-20260730.bundle nvim-old`

That bundle is outside the work-tree and is NOT itself backed up. Copy it
somewhere durable if those commits matter.
