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

## Deliberately not tracked

- `~/.config/nvim` — its own git repo, keep it separate
- `~/.config/opencode` — contains a committed `node_modules`
- `~/.claude.json` — holds credentials
