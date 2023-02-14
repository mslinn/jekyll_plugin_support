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
