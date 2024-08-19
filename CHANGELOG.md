# Change Log


## 1.0.2 / 2024-08-19

* Computes line_number and path properly
* Refactored demo CSS
* Improved custom plugin error handling and sample code.
  The following seems to be optimal for custom plugins; it suppresses the ridiculously long stack trace that used to be generated:

   ```ruby
    rescue DemoInlineTagError => e # jekyll_plugin_support handles StandardError
      @logger.error e.logger_message
      exit! 1 if @die_on_demo_tag_error

      e.html_message
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
