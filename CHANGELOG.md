## 0.5.2 / 2023-03-17
  * Added `@helper.remaining_markup` public method, which returns remaining markup passed to your tag, after keyword and name/value parsing is complete.
  * Finally wrote proper `rspec` tests.
  * Finally documented argument parsing.
  * Fixed bug introduced in v0.5.1 which did not remove elements from `@params`.

## 0.5.1 / 2023-02-17
  * `no_arg_parsing` optimization added.

## 0.5.0 / 2023-02-15
  * Plugins now register themselves
  * Plugins now report their name and version
  * `@layout`, `@paginator`, and `@theme` have values if supported by the version of Jekyll, and they are active. (See [Jekyll docs](https://jekyllrb.com/docs/variables/).)

## 0.4.1 / 2023-02-14
  * Fixed several problems
  * Added demo site

## 0.4.0 / 2023-02-12
 * `render_impl` for tags and blocks now predefines more instance variables:
   - `@liquid_context` &ndash; passed to `render`
   - `@config` Jekyll configuration
   - `@envs` Environment variables
   - `@mode` ('development', 'test' or 'production')

## 0.3.1 / 2023-02-07
  * `JekyllBlock.render_impl` and `JekyllTag.render_impl` now define `@page` and `@site`.

## 0.3.0 / 2023-01-14
  * Added support for tags, which should subclass JekyllSupport::JekyllTag

## 0.2.0 / 2023-01-12
  * Refactored

## 0.1.0 / 2023-01-10
  * Initial version; only supports Jekyll block tags
