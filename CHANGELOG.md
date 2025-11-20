# Change Log

## Unreleased

* **FIXED**: Resolved JekyllDrop iteration error that occurred when plugins tried to iterate over JekyllDrop objects
  using `.each`. JekyllDrop provides specific attributes (`jekyll.version`, `jekyll.environment`) via method calls,
  not iteration. Fixed by implementing direct attribute access using `respond_to?` checks.
* **FIXED**: Multiple Jekyll build errors related to missing dependencies and plugin loading:
  - Installed missing gems: `jekyll_href` (3.0.2), `jekyll_outline` (1.3.1), `jekyll_flexible_include` (2.0.28)
  - Resolved version compatibility issues by updating `jekyll_flexible_include`
  - Fixed plugin loading by moving plugin files from `demo/_plugins/` to root `_plugins/` directory
  - Created missing include files and directories required by plugins
* **IMPROVED**: Code style and linting compliance - removed trailing whitespace, fixed modifier if usage, string literals
* **IMPROVED**: Demo website now builds successfully in ~4 seconds without fatal errors
* **IMPROVED**: Documentation updated to reflect variable expansion behavior and error handling improvements

## 3.1.3 / 2025-01-02

* **BREAKING CHANGE**: Modified `JekyllPluginHelper.expand_env` to only expand Bash environment
  variables (`$VAR` or `${VAR}`), not Windows environment variables (`%VAR%`). This prevents false
  expansions in web content where text strings contain pairs of percent signs that are not
  environment variables.
* Removed the `use_wslvar` parameter from `JekyllPluginHelper.expand_env` method signature.
* `JekyllPluginHelper.env_var_expand_windows` is still available for plugins that specifically
  need Windows environment variable expansion.
* `jekyll_flexible_include_plugin` now explicitly calls both `env_var_expand_bash` and
  `env_var_expand_windows` for file paths to maintain its ability to handle both Bash and
  Windows environment variables.
* Updated `JekyllPluginHelper.find_windows_envar` to properly fall back to environment variable
  search when `wslvar` is not available or doesn't find the variable.


## 3.1.2 / 2025-11-17

* Support for [Claude CLI](https://www.mslinn.com/llm/7900-claude.html) is
  provided in the `.claude` directory. This was implemented so it would work
  with other LLMs, for example [Cursor](https://mslinn.com/llm/7980_cursor.html) and
  [MiniMax Mini-Agent](https://www.mslinn.com/llm/7997-mini-agent.html).
* `JekyllPluginHelper.env_var_expand_windows` expands Windows environment
  variables (surrounded by `%` characters) using a case-insensitive search,
  which also works when running on Linux and macOS. This is used by
  [`jekyll_flexible_include_plugin`](https://www.mslinn.com/jekyll_plugins/jekyll_flexible_include.html).
* `JekyllPluginHelper.wsl_detected?` detects if Jekyll is running under WSL
* Changed `JekyllPluginHelper.initialize` to make `no_arg_parsing` a keyword argument.
* Now requires `jekyll_draft` using `Gemfile` instead of the gemspec, to avoid a warning
  when running `bundle install`.
* Handles `include` variables with types other than `String`.


## 3.1.1 / 2025-09-13

* Now looks up Windows environment variables (surrounded by `%` characters).
  An error is generated for undefined variables.


## 3.1.0 / 2025-06-10

* Added attribute `order` and method `field` to support `jekyll_outline`.
* Added another constructor for `AllCollectionsHooks::APage`, called `apage_from`.
* Added new method `new_attribute` to module `JekyllSupport`.
* The displayed date field (`:date` or `:last_modified`) now defaults to the primary sort field.
* Modified specs tests.
* Jekyll tag `AllCollectionsTag` now accepts an optional parameter called
  `collection_name`, which filters the selected data source. A warning is logged
  if the data source is anything but `all_collections`.
* Moved `APage` and its constructors to the `JekyllCollections` module.


## 3.0.0 / 2025-02-09

* Numbered as v3.0.0 because `jekyll_draft` was at v2.1.0 and the two projects should have similar version numbers.
* `Jekyll_all_collections` was folded into this project.
* Now requires [Jekyll 4.4.1](https://jekyllrb.com/news/2025/01/29/jekyll-4-4-1-released/) or later,
  and Ruby 3.2.0 or later


## 1.1.0 / 2025-02-07

* Now replaces include and layout variables with their values
* Renamed `@helper.markup` to `@helper.argument_string`
* Improved `nil` handling throughout
* Added the **Debug Demo production** launch configuration to debug the demo website in production mode
* Added the `bin/release_port` script that kills hung processes being debugged
* Added the `cleanDemo` task for the **Debug Demo production** and **Debug Demo development** tasks
* Many minor improvements to the demo.
* `JekyllSupport::JekyllPluginHelper::register` now accepts a `quiet` option, to suppress the signon message.
  Use it like this:

  ```ruby
  JekyllPluginHelper.register(self, 'tag_name', quiet: true)
  ```


## 1.0.3 / 2024-08-19

* Still fussing with error handling


## 1.0.2 / 2024-08-19

* Computes line_number and path properly
* Refactored demo CSS
* Improved custom plugin error handling and sample code.
  The following seems to be optimal for custom plugins; it suppresses the ridiculously long stack trace that used to be generated:

   ```ruby
   begin
     # ...
   rescue DemoInlineTagError => e # jekyll_plugin_support handles StandardError
     @logger.error { e.logger_message }
     exit! 1 if @die_on_demo_tag_error

     e.html_message
   end
   ```


## 1.0.1 / 2024-07-27

* Moved `warn_short_trace`, `maybe_reraise_error`, `remove_ansi_color`,
`format_error_message` and `exit_without_stack_trace` into `JekyllSupportError`.
* Added missing `shared_include.css` and `clippy.svg` to `demo/`.
* Fixed missing module name when invoking `format_error_message`.


## 1.0.0 / 2024-07-23

* Added the `redef_without_warning` method so tag and block plugins can be subclassed.
* Put most of the functionality into the `JekyllSupport` module.
* Made tag and block code more consistent


## 0.8.6 / 2024-06-11

* Fixup version, containing what was supposed to be in v0.8.5


## 0.8.5 / 2024-03-25

* Empty block tags now return a value. See https://talk.jekyllrb.com/t/empty-liquid-block-not-rendering


## 0.8.4 / 2024-02-27

* Problem in error handler fixed.
* A warning is logged if an environment variable is undefined and `die_if_undefined` is not set.


## 0.8.3 / 2024-01-05

* Variables defined in front matter of layouts and pages are now handled.


## 0.8.2 / 2024-01-03

* `JekyllSupport::JekyllBlock` and `JekyllSupport::JekyllTag` subclasses now have automatically created error classes,
  named after the subclass.
* Error class methods have been provided for standardized and convenient error handling:
  * `shorten_backtrace`
  * `logger_message`
  * `html_message`
* Tags now self-report when registered.


## 0.8.1 / 2023-12-10

* Added the `JekyllPluginHelper.remove_html_tags` method.


## 0.8.0 / 2023-11-14

* Restructured for better support of Liquid variables.
* Removed redundant class name in error message.
* Improved handling of StandardError.
* Demo site now shows how to define and handle custom errors.
* Added `@tag_config` variable, which can be inspected to determine whether to die on various types of exceptions.
* Added `format_error_message`, `maybe_reraise_error`, and `raise_error` to `JekyllBlock` and `JekyllTag`
* Adds a method called `shorten_backtrace` to `StandardError` and all custom error
  classes defined by `JekyllSupport.define_error`.
  See the `demo/` directory for examples of how to use this optional feature.
* The `plugin-vars` section in `_config.yml` was renamed to `liquid_vars`.


## 0.7.2 / 2023-08-14

* Hopefully takes care of issue [#4](../../issues/4).


## 0.7.1 / 2023-08-11

* Suppressed stack trace from issue [#4](../../issues/4).
* Now using Shopify `ruby-lsp` instead of `rebornix.Ruby` by Peng Lv
* Debug configurations changed to `rdbg` instead of `ruby`, so the `debase` development dependency was changed to
  [`debug`](https://marketplace.visualstudio.com/items?itemName=KoichiSasada.vscode-rdbg),
  which provides the `rdgb` command.
  The `ruby-debug-ide` development dependency is also no longer required.


## 0.7.0 / 2023-05-22

* Added `error_short_trace` and `warn_short_trace` methods for displaying non-fatal errors on the console.

## 0.6.2 / 2023-05-15

* Removed annoying blank line output when attribute was invoked.

## 0.6.1 / 2023-04-12

* Added `CallChain.excerpt_caller` to detect if an excerpt is being generated.


## 0.6.0 / 2023-04-05

* Added attribution support
* Renamed `jekyll_plugin_support_helper.rb` to `jekyll_plugin_helper.rb`.
* Now returns `undefined` instead of `false'` when `@keys_values.empty?`
  and parameter is not specified.


## 0.5.3 / 2023-03-19

* Added properties `argv_original`, `keys_values_original`, `remaining_markup_original`,
    and `params_original`, which are the original values of `argv`, `keys_values`,
    `remaining_markup`, and `params`, before environment variable expansion.


## 0.5.2 / 2023-03-17

* Added `@helper.remaining_markup` public method, which returns remaining markup passed to your tag,
  after keyword and name/value parsing is complete.
  * Finally wrote proper `rspec` tests.
  * Finally documented argument parsing.
  * Fixed bug introduced in v0.5.1 which did not remove elements from `@params`.


## 0.5.1 / 2023-02-17

* `no_arg_parsing` optimization added.


## 0.5.0 / 2023-02-15

* Plugins now register themselves
* Plugins now report their name and version
* `@layout`, `@paginator`, and `@theme` have values if supported by the version of Jekyll, and they are active.
  (See [Jekyll docs](https://jekyllrb.com/docs/variables/).)


## 0.4.1 / 2023-02-14

* Fixed several problems
* Added demo site


## 0.4.0 / 2023-02-12

* `render_impl` for tags and blocks now predefines more instance variables:

  * `@liquid_context` &ndash; passed to `render`
  * `@config` Jekyll configuration
  * `@envs` Environment variables
  * `@mode` ('development', 'test' or 'production')


## 0.3.1 / 2023-02-07

* `JekyllBlock.render_impl` and `JekyllTag.render_impl` now define `@page` and `@site`.


## 0.3.0 / 2023-01-14

* Added support for tags, which should subclass JekyllSupport::JekyllTag


## 0.2.0 / 2023-01-12

* Refactored


## 0.1.0 / 2023-01-10

* Initial version; only supports Jekyll block tags
