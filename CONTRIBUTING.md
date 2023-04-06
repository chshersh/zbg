# Contributing

This document describes contributing guidelines for the ZBG project.

You're encouraged to read this document before your first contribution.
Spending your time familiarising yourself with these
guidelines is much appreciated because following this guide ensures
the most positive outcome for contributors and maintainers! 💖

## How to contribute

Everyone is welcome to contribute as long as they follow our
[rules for polite and respectful communication](https://github.com/chshersh/zbg/blob/main/CODE_OF_CONDUCT.md)!

And you can contribute to `zbg` in multiple ways:

1. Share your success stories or confusion moments when using `zbg` under
   [Discussions](https://github.com/chshersh/zbg/discussions).
2. Open [Issues](https://github.com/chshersh/zbg/issues) with bug
   reports or feature suggestions.
3. Open [Pull Requests (PRs)](https://github.com/chshersh/zbg/pulls)
   with documentation improvements, changes to the code or even
   implementation of desired changes!

If you would like to open a PR, **create the issue first** if it
doesn't exist. Discussing implementation details or various
architecture decisions avoids spending time inefficiently.

> You may argue that sometimes it's easier to share your vision with
> exact code changes via a PR. Still, it's better to start a
> Discussion or an Issue first by mentioning that you'll open a PR
> later with your thoughts laid out in code.

If you want to take an existing issue, please, share your intention to
work on something in the comment section under the corresponding
issue. This avoids the situation when multiple people are working on
the same problem concurrently.

## Pull Requests requirements

Generally, the process of submitting, reviewing and accepting PRs
should be as lightweight as possible if you've discussed the
implementation beforehand. However, there're still a few requirements:

1. Be polite and respectful in communications. Follow our
   [Code of Conduct](https://github.com/chshersh/zbg/blob/main/CODE_OF_CONDUCT.md).
2. The code should be formatted with `ocamlformat`
   using the [project-specific configuration][ocamlformat-config].
   Your changes will be rejected if they don't follow the formatting
   requirements.
3. Add an entry to `CHANGELOG.md` describing your changes in the format similar
   to other changes.

[ocamlformat-config]: https://github.com/chshersh/zbg/blob/main/.ocamlformat

That's all so far!

> ℹ️ **NOTE:** PRs are merged to the `main` branch using the
> "Squash and merge" button. You can produce granular commit history
> to make the review easier or if it's your preferred workflow. But
> all commits will be squashed when merged to `main`.

## Write access to the repository

If you want to gain write access to the repository, open a
[discussion with the Commit Bits category](https://github.com/chshersh/zbg/discussions/categories/commit-bits)
and mention your willingness to have it.

I ([@chshersh](https://github.com/chshersh))
grant write access to everyone who contributed to `zbg`.