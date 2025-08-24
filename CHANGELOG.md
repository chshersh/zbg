# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning][1]. The changelog is also
available [on GitHub][2].

## [Unreleased]

<!-- Add new changes here -->

## [0.3.0] - 2025-08-24 🧙‍♂️💀

### Fixed

- [#26](https://github.com/chshersh/zbg/issues/26):
  Set the `HOME` environment variable before calling external commands.
  (by [@etorreborre])

### Changed

- [#31](https://github.com/chshersh/zbg/pull/31):
  Command `zbg push -f` now uses git's `--force-with-lease` because it's a safer default
  (by [@kephas])
- [#10](https://github.com/chshersh/zbg/issues/10):
  Changed `fetch_main_branch` to get the base name using `Core.Filename.basename` rather than reading the output of the `basename` command.
  (by [@leedsjohn])
- [#16](https://github.com/chshersh/zbg/issues/16):
  `zbg status` now highlights staged files by making the file name bold and green.
  (by [@leedsjohn])
- Use `--delete --force` in `zbg done` instead of just `--delete`.
  (by [@chshersh])

## [0.2.0] — 2023-12-17 🎄

### Added

- [#9](https://github.com/chshersh/zbg/issues/9):
  New command `zbg done` (see [README.md](./README.md) for more details)
  (by [@sloboegen])
- [#13](https://github.com/chshersh/zbg/issues/13):
  Support both `-f` and `--force` flags in CLI
  (by [@tekknoid])

### Fixed

- [#18](https://github.com/chshersh/zbg/issues/18):
  `zbg status` now prints the diff when invoked not from the project root
  (by [@tekknoid])
- [#7](https://github.com/chshersh/zbg/issues/7), [#11](https://github.com/chshersh/zbg/issues/11):
  Escape messages in `zbg stash` and `zbg commit` commands
  (by [@paulpatault])
- [#25](https://github.com/chshersh/zbg/issues/25):
  Use the default branch always instead of hardcoding `main`
  (by [@tekknoid])


## [0.1.0] — 2023-04-10 🌇

Initial release prepared by [@chshersh].

<!-- Contributors -->

[@chshersh]: https://github.com/chshersh
[@leedsjohn]: https://github.com/leedsjohn
[@paulpatault]: https://github.com/paulpatault
[@sloboegen]: https://github.com/sloboegen
[@tekknoid]: https://github.com/tekknoid
[@kephas]: https://github.com/kephas

<!-- Header links -->

[1]: https://semver.org/
[2]: https://github.com/chshersh/zbg/releases

<!-- Versions -->

[Unreleased]: https://github.com/chshersh/zbg/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/chshersh/zbg/releases/tag/v0.3.0
[0.2.0]: https://github.com/chshersh/zbg/releases/tag/v0.2.0
[0.1.0]: https://github.com/chshersh/zbg/releases/tag/v0.1.0
