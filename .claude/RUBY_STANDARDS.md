# Ruby Programming Standards

Jekyll is a Ruby gem that creates static websites.

This project (`jekyll_plugin_support`) is a framework for writing and testing
[Jekyll](https://jekyllrb.com/) plugins in the Ruby language.
These plugins share common coding standards and debugging techniques.

## General

- Write using Ruby 3.4.7 features and recommended syntax.
- Preserve existing comments and formatting.
- Use multiline strings whenever possible using squiggly heredocs (`<<~IDENTIFIER`).
- Assume the reader knows the Ruby language, so do not explain common Ruby
  coding techniques.
- Assume the reader is new to writing Jekyll plugins and is unfamiliar with
  `jekyll_plugin_support`.
- Only write new comments when they are non-obvious.
- Follow the existing coding style.
- Before making any changes, tell the user a high-level explanation
  - If requested, show detailed changes.
  - Proceed after the user approves the changes.


## Unit Tests

- Write unit tests using RSpec for non-trivial functionality.
  See the `spec` subdirectory for examples of existing tests.
- Configuration for unit tests is provided in the top-level `_config.yml` in this project.


## Demo Project

Many features cannot be easily tested using RSpec. However, all features should
be testable by making Jekyll web pages in the Jekyll website in the `demo`
subdirectory and running the demo.

- Use the scripts in the `bin` directory to test functionality in a live setup.

- All Jekyll plugins based on `jekyll_plugin_support` should include a `demo`
  subdirectory.

- Configuration for the `demo` Jekyll website is provided in `_config.yml` in
  that subdirectory.

### Demo Project Configuration

- The `Gemfile` in the `demo` subdirectory can be used for debugging plugins
  based on `jekyll_plugin_support`.

- Each of the `gem` lines can include an optional `path` argument, like
  `path: jekyll_flexible_include`. Here is an example:

  ```ruby
  jekyll_flexible_include = ENV.fetch('jekyll_flexible_include', nil)
  group :jekyll_plugins do
    gem 'jekyll_flexible_include', path: jekyll_flexible_include
  end
  ```
