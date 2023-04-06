# zbg

[![GitHub CI](https://github.com/chshersh/zbg/workflows/CI/badge.svg)](https://github.com/chshersh/zbg/actions)
[![MPL-2.0 license](https://img.shields.io/badge/license-MPL--2.0-blue.svg)](LICENSE)

`zbg` (short for **Z**ero **B**ullshit **G**it) is a CLI tool for using `git` efficiently.

> ℹ️ **DISCLAIMER:** `zbg` is developed and maintained in free time
> by volunteers. The development may continue for decades or may stop
> tomorrow. You can use
> [GitHub Sponsorship](https://github.com/sponsors/chshersh) to support
> the development of this project.

## Features

* ✨ Prettier `git status`, `git log` and other commands
* 🚀 Sane defaults to `git` commands that enforce good state of your local repository
* 🌌 Achieving more by typing less

> **Warning**
> `zbg` is not a full `git` replacement!
>
> `zbg` provides helpful commands for the most
> common use case but you may still need to use some `git` commands occasionally

## Install

> ℹ️ Currently `zbg` can be installed only by building it [from sources](#from-sources).
> Alternative installation methods [may appear later](https://github.com/chshersh/zbg/issues/8).

### From sources

1. Clone the repository
    ```shell
    git clone git@github.com:chshersh/zbg.git
    cd zbg
    ```
2. Build the executable
    ```shell
    opam install . --deps-only --with-doc --with-test
    dune build
    ```
3. Copy the executable under your location in `$PATH`, e.g.:
    ```shell
    cp -f ./_build/default/bin/main.exe ~/.local/bin/zbg
    ```
4. Run `zbg --help`

## Configure

Set your GitHub username in the `user.login` field of your global `.gitconfig`:

```shell
git config --global user.login my-github-login
```

## Quick start guide

This section contains example of various usage scenarios for `zbg`.

### Developing a new feature

A typical workflow for developing a new feature may look like this:

```shell
$ zbg switch           # Switch to the main branch and  sync it

$ zbg new Feature 2.0  # Create a new branch; 'zbg switch' made sure
                       # we start developing from the latest version

<coding>               # The fun part!

$ zbg status           # Check quick summary of your changes

$ zbg commit           # Commit all local changes and write description

$ zbg push             # Push the branch
```

### Experimenting, saving and re-applying

While you were on vacation, a coworker of yours pushed some changes to your
branch, and now your want to sync their work locally and do some experimenting.

```shell
$ zbg sync     # Get the latest changes from your branch

$ zbg rebase   # Rebase on top of the main branch if anything changed

<start developing the experiment>

$ zbg clear    # Nah, scrap that, bad idea

<coding>

$ zbg stash    # Argh, too early, save and do the other thing

<coding>

$ zbg status   # Check what you've done

$ zbg commit   # Commit changes

$ zbg unstash  # Now apply your stashed changes

$ zbg commit   # Commit changes again

$ zbg push -f  # Push changes for the review
```

## All commands

The below table describes all `zbg` commands and the corresponding `git`
explanations.

> **Note**
> The table below uses default or example arguments to all commands

| `zbg` | `git` |
| ----- | ----- |
| `zbg clear` | `git add .` <br /> `git reset --hard` |
| `zbg commit My description` | `git add .` <br /> `git commit --message="My description"` |
| `zbg log` | `git log <long custom formatting string>` |
| `zbg new Branch name` | `git checkout -b my-github-username/Branch-name` |
| `zbg push` | `git push --set-upstream origin <current-branch>` |
| `zbg rebase` | `git fetch origin main` <br /> `git rebase origin/main` |
| `zbg stash` | `git stash push --include-untracked` |
| `zbg status` | `git status` (but `zbg` is prettier) |
| `zbg switch` | `git checkout main` <br /> `git pull --ff-only --prune` |
| `zbg sync` | `git pull --ff-only origin <current-branch>` |
| `zbg sync -f` | `git fetch origin <current-branch>` <br /> `git reset --hard origin/<current-branch>` |
| `zbg tag v0.1.0` | `git tag --annotate %s --message='Tag for the v0.1.0 release'` <br /> `git push origin --tags` |
| `zbg tag -d v0.1.0` | `git tag --delete v0.1.0` <br /> `git push --delete origin v0.1.0` |
| `zbg uncommit` | `git reset HEAD~1` |
| `zbg unstash` | `git stash pop` |

## For contributors

Check [CONTRIBUTING.md](https://github.com/chshersh/zbg/blob/main/CONTRIBUTING.md)
for contributing guidelines.

## Development

**First time:** Install all dependencies with `opam`:

```
opam install . --deps-only --with-doc --with-test
```

To build the project locally, use `dune`:

```
dune build
```

To run tests:

```
dune runtest
```

> Empty output means that all tests are passing.

## Troubleshooting

If you see the following error when running `zbg switch`:

```shell
$ zbg switch
fatal: ambiguous argument 'origin/HEAD': unknown revision or path not in the working tree.
Use '--' to separate paths from revisions, like this:
'git <command> [<revision>...] -- [<file>...]'
```

run the following command to sync with the remote and set the `origin/HEAD` ref locally:

```shell
git remote set-head origin -a
```
