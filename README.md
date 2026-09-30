# Personal dotfiles (yadm)

Configuration for Zsh, Neovim, Ghostty, AeroSpace, and related tools.
This repository uses your home directory as its work tree.

## Setup

Install [yadm](https://yadm.io/docs/install) and clone into your home directory:

```sh
yadm clone git@github.com:edrenck/dotfiles.git
```

Run the bootstrap (yadm also offers to run it after cloning):

```sh
yadm bootstrap
```

Preview changes or choose a server setup by invoking the script directly:

```sh
~/.config/yadm/bootstrap --dry-run
~/.config/yadm/bootstrap --cli
~/.config/yadm/bootstrap --docker
```

The bootstrap installs missing tools and can be rerun after pulling updates.
It uses Homebrew on macOS (installing Homebrew if needed) and apt on Debian/Ubuntu.
On a fresh Mac, finish the Xcode Command Line Tools installation if prompted,
then rerun. Run as your normal user; apt requests sudo when needed.

### Installed tools

- Shell: Zsh, Antidote and the declared plugins, Starship, fzf, zoxide, thefuck.
- Terminal utilities: eza, bat, fd, ripgrep, lazygit, lazydocker, btop, lf.
- Editor: Neovim >= 0.11.2, Tree-sitter CLI >= 0.25, Node/npm, Python and build tools.
- Repository: Git, yadm, Gitleaks >= 8.19 and the enabled pre-commit hook.
- Desktop: Ghostty; on macOS also AeroSpace, Borders and Space Mono Nerd Font.
- With `--docker`: Docker Desktop on macOS, or docker.io and Compose on Linux.

`--cli` skips desktop apps and fonts. Docker host installation is opt-in because
many machines already use a remote Docker host. Start Docker Desktop after
installation, or configure Linux daemon access separately; bootstrap does not
add your user to the root-equivalent docker group or change existing daemons.
It leaves your login shell unchanged. To switch it, use `chsh -s "$(command -v zsh)"`;
your distribution may require that path to be listed in `/etc/shells`.

On Linux, apt is preferred. If apt lacks a tool or its Neovim/Tree-sitter/Gitleaks
version is too old, the bootstrap installs a GitHub release under `~/.local`,
verifying SHA-256 before extraction. Release fallbacks support x86_64 and arm64.
Existing suitable tools are retained. It also supplies `bat` and `fd` symlinks
when Debian calls them `batcat` and `fdfind`.

Ghostty uses apt where available (Ubuntu 26.04+). Otherwise it uses the
[community .deb builds linked by Ghostty](https://ghostty.org/docs/install/binary),
matched to Ubuntu 24.04/25.10/26.04 or Debian trixie/forky and compatible derivatives.
Older unsupported desktop distributions stop with an explanation; use `--cli`
or install Ghostty manually. No third-party apt repository is added.

Neovim installs LazyVim/Mason plugins on first launch. Language-specific JDKs,
SDKs, credentials and development environments remain project/machine choices.
The custom Osaka-Mono font is not redistributed here: install it separately or
select an available font in Ghostty. Linux users can install a Nerd Font for
Neovim/eza icons; the Starship prompt uses standard Unicode symbols.

The pre-commit hook scans an exact snapshot of the staged tree (including binary
contents) and blocks commits when Gitleaks is missing. Its output is redacted.
Bootstrap enables it on each machine via `yadm config core.hooksPath`.

## Layout

- `.zshrc`: interactive entry point and ignored `.zshrc.local` overrides.
- `.config/zsh/`: shared environment, shell options, aliases, and plugins.
- `.config/starship.toml`: prompt configuration.
- `.zsh_plugins.txt`: Antidote plugin list.
- `.config/yadm/bootstrap`: macOS/Linux dependency installation.
- `.config/yadm/install-release.py`: verified Linux release fallbacks.
- `.config/nvim/`: LazyVim configuration and plugin locks.
- `.aerospace.toml`: macOS window-manager configuration.


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
