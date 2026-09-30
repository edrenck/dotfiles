# Personal dotfiles (yadm)

Configuration for Zsh, Neovim, Ghostty, AeroSpace, and related tools.
This repository uses your home directory as its work tree.

## Setup

Install [yadm](https://yadm.io/docs/install) and clone into your home directory:

```sh
yadm clone git@github.com:edrenck/dotfiles.git
```

For the shell tools on macOS:

```sh
brew install zsh neovim eza bat fd fzf zoxide starship ripgrep antidote thefuck lazygit lazydocker gitleaks
yadm config core.hooksPath .config/yadm/git-hooks
```

The hook runs only after enabling it on each machine. It scans a snapshot of the staged tree (including binary contents) with
Gitleaks and blocks commits if the scanner is missing. Review its redacted output.

## Layout

- `.zshrc`: interactive entry point and ignored `.zshrc.local` overrides.
- `.config/zsh/`: shared environment, shell options, aliases, and plugins.
- `.config/starship.toml`: prompt configuration.
- `.zsh_plugins.txt`: Antidote plugin list.
- `.config/nvim/`: LazyVim configuration and plugin locks.
- `.aerospace.toml`: window-manager configuration.

This is currently a macOS-focused setup, not a cross-platform bootstrap.

## Keep private data local

The home-level `.gitignore` permits only selected configuration paths. Add a new
path deliberately when you want to manage another tool. Never use `yadm add -f`
for credentials. Stage specific files and inspect `yadm diff --cached --stat`.

Authentication stores, Anytype API keys, editor prompt databases, histories,
logs, and environment files must remain local. Store shell secrets in
`~/.zshrc.local` or use a password manager. An ignore rule does not untrack files
already committed, remove old history, or revoke a leaked credential.

## Past credential exposure

The published history contained GitHub token strings in the Copilot SQLite WAL
and a nonempty Anytype API-key file. Their validity was not tested.
The affected credentials have been rotated. Authentication and prompt database
files are excluded from the tracked tree. History cleanup is part of this
security update; old clones and cached views may still retain copies.

Follow [GitHub's sensitive-data removal guide](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository).
A history rewrite requires coordinating existing clones and force-pushing;
it cannot remove copies downloaded by others.
