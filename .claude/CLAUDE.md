# Jekyll Plugin Support Instructions for Claude

## General Instructions

- See `RUBY_STANDARDS.md` in this directory for Ruby coding instructions.

- Do not output emojis in user dialog.

- Do not speak in superlatives; instead, be strictly factual.

- Do not ask the user several questions at once.
  Instead, ask questions one at a time.

- Make no assumptions. Ask the user about every ambiguity or corner case,
  and suggest a better way if there is one.

- If you need to write documentation, place the file in the `docs/` directory.

- Before every git command, if `.git/index.lock` exists, delete it using `sudo`.


## Requirements for Done

The following must be completed before your work can be considered to be done.

- Update documentation with changes
- Unit tests must pass
- Linters for all languages (bash, Ruby, Markdown, etc) must succeed.
- Unit tests must pass.
- Update `README.md` for user-visible changes only.
- Update `CHANGES.md` for user-visible changes, describe at a high level.
- Update `.claude/PROGRESS.md`.
- Only then `git push` with a message and commit.
