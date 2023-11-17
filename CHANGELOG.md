# Change Log

## 0.7.3 / 2023-11-14

* Restructured for better support of Liquid variables.
* Removed redundant class name in error message.
* Improved handling of StandardError.
* Demo site now shows how to define and handle custom errors.
* Added `format_error_message`, `maybe_reraise_error`, and `raise_error` to `JekyllBlock` and `JekyllTag`


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
