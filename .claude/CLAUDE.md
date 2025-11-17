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

- Git projects have environment variables that point to their directories. Some examples:

  - `$jekyll_plugin_support` points to the directory containing the
    `jekyll_plugin_support` Git project.
  - `$jekyll_href` points to the directory containing the `jekyll_href` Git
    project that defines the `href` plugin.
  - `$jekyll_pre` points to the directory containing the `jekyll_pre` Git
    project that defines the `pre` plugin.
  - `$jekyll_img` points to the directory containing the `jekyll_img` Git
    project that defines the `img` plugin.
  - `$jekyll_flexible_include_plugin` points to the
    `jekyll_flexible_include_plugin` Git project that contains the directory
    containing the `flexible_include` plugin.


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


## DO THIS NOW

Read and execute `FUTURE.md`.
