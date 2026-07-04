# Code Smells in `jekyll_plugin_support`

A review of the codebase turned up the issues below. They are ordered by
severity. Line numbers refer to the state of the repo at the time of review and
may drift.

## Medium severity

### 6. Duplication between `JekyllTag` and `JekyllBlock`

`render`, `initialize`, and `set_error_context` are ~90% identical across
`lib/tag/jekyll_plugin_support_tag.rb` and
`lib/block/jekyll_plugin_support_block.rb`. The block version even logs
`e.full_message` **twice** (lines 89 and 93). Extract a shared
`JekyllPluginBase` module.


### 12. `parse` has a leftover TODO and dead branch

```ruby
@params_original = @keys_values_original unless respond_to?(:no_arg_parsing) && no_arg_parsing
...
@params = @keys_values # TODO: @keys_values should be deleted
```

The conditional on `@params_original` is moot because `reinitialize` only calls
`parse` when `!@no_arg_parsing`. And the TODO has lingered.
(`lib/helper/jekyll_plugin_helper.rb:91-106`)

## Lower severity

### 17. Comment typos / placeholder text in docs

`@ptions` appears in the parse_context doc block of *both* tag and block files
(should be `@options`). Comments like `# Are error and logger.error defined?`
(`lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:18`) read like
unanswered questions left in production.

### 20. `_` prefixed unused param but still required

`dump_vars(_logger, liquid_context)` — the `_` prefix says "unused," but callers
must still pass it. Either drop the parameter or use it.
(`lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:30`)


## Suggested order to tackle

1. **Extract shared base for `JekyllTag`/`JekyllBlock` (#6)** — biggest maintainability win.
3. Remove dead/commented code (#4).
