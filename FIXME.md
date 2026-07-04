# Code Smells in `jekyll_plugin_support`

A review of the codebase turned up the issues below. They are ordered by
severity. Line numbers refer to the state of the repo at the time of review and
may drift.

## High severity


### 4. `redef_without_warning` is dead code

`lib/jekyll_plugin_support.rb:25-28` defines it but nothing calls it (only
`experiments/redefine_constant.rb` references the idea). Remove or actually use
it.

This "code smell" is a false positive, as shwon by the change log comment: 1.0.0
/ 2024-07-23 Added the `redef_without_warning` method so tag and block plugins
can be subclassed.

### 5. Duplicate module declaration

`module JekyllSupport` is opened twice (`lib/jekyll_plugin_support.rb:24` and
`:43`). Harmless but confusing — consolidate.

## Medium severity

### 6. Massive duplication between `JekyllTag` and `JekyllBlock`

`render`, `initialize`, and `set_error_context` are ~90% identical across
`lib/tag/jekyll_plugin_support_tag.rb` and
`lib/block/jekyll_plugin_support_block.rb`. The block version even logs
`e.full_message` **twice** (lines 89 and 93). Extract a shared
`JekyllPluginBase` module.

### 7. Inconsistent `@mode` resolution

- `lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:55-60` checks four sources (`env.JEKYLL_ENV`, `env.JEKYLL_ENVIRONMENT`, `config.JEKYLL_ENV`, `config.JEKYLL_ENVIRONMENT`).
- `lib/tag/jekyll_plugin_support_tag.rb:67` and `lib/block/jekyll_plugin_support_block.rb:74` only check `env.JEKYLL_ENV`.

Same concept, three implementations, different behavior. Centralize into one helper.

### 8. `lookup_liquid_variables` silently swallows errors

```ruby
rescue StandardError => e
  logger.error { e.full_message }
end   # returns nil
```

On failure it logs and returns `nil`. Callers then do
`@argument_string.to_s.strip` on `nil`, masking the real bug. Six methods in
`lib/jekyll_plugin_support/jekyll_plugin_support_class.rb` have the same
anti-pattern (logs + returns nil/implicit-nil). At minimum return the unmodified
`markup_original` so callers don't crash downstream.

### 9. `process_layout_variables` logs the wrong thing

```ruby
if value.nil?
  value = ''
  logger.warn { "layout.#{value} is undefined." }   # value is now '' — prints "layout. is undefined"
end
```

Should reference `name`, not `value`. (`lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:130-141`)

### 10. `inject_config_vars` mutates caller state and ignores its own comment

```ruby
@mode = env&.[]('JEKYLL_ENV') || ...   # sets instance var @mode on a module method
```

Setting `@mode` inside a `self.` method sets it on the module, not any tag
instance — almost certainly not intended. The comment also says it modifies
`scopes`, but it sets `scope[name]` which is the desired mutation; the comment
is misleading.
(`lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:47-73`)

### 11. `attr_reader` redeclares inherited attributes

`JekyllTagNoArgParsing` (`lib/tag/jekyll_plugin_support_tag_noarg.rb:3`) and
`JekyllBlockNoArgParsing` redeclare `attr_reader :argument_string, :helper, ...`
already declared by the parent. Redundant and a maintenance trap.

### 12. `parse` has a leftover TODO and dead branch

```ruby
@params_original = @keys_values_original unless respond_to?(:no_arg_parsing) && no_arg_parsing
...
@params = @keys_values # TODO: @keys_values should be deleted
```

The conditional on `@params_original` is moot because `reinitialize` only calls
`parse` when `!@no_arg_parsing`. And the TODO has lingered.
(`lib/helper/jekyll_plugin_helper.rb:91-106`)

### 13. `define_singleton_method` hack in `reinitialize`

```ruby
define_singleton_method(:argv) { warn_fetch :argv }
```

Four of these redefine public readers to `abort` at runtime. Better expressed by
*not* defining them at all, or raising a typed exception instead of `abort`
(which kills the whole Jekyll process).
(`lib/helper/jekyll_plugin_helper.rb:39-54`)

## Lower severity

### 14. `abort` used for control flow

`lib/util/send_chain.rb`, `lib/helper/jekyll_plugin_helper.rb`,
`lib/hooks/a_page.rb` (via `exit 2`/`exit 3`), and both tag base classes use
`abort`/`exit` to signal programming errors. In a library this is hostile —
raise an exception instead so the host can decide.

### 15. `exit 2` / `exit 3` from a library (`lib/hooks/a_page.rb:22, 29`)

A gem should never terminate the host process. Raise.

### 16. Stale conditional fallback pattern

```ruby
FIXNUM_MAX = (2**((0.size * 8) - 2)) - 1 unless defined? FIXNUM_MAX
```

`unless defined?` guards on constants that are clearly first-time definitions
are cargo-culted throughout (`DISPLAYED_CALLS`, `END_OF_DAYS`,
`JekyllPluginSupportError`). They obscure intent.

### 17. Comment typos / placeholder text in docs

`@ptions` appears in the parse_context doc block of *both* tag and block files
(should be `@options`). Comments like `# Are error and logger.error defined?`
(`lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:18`) read like
unanswered questions left in production.

### 18. Commented-out dead code blocks

`lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:5-9`,
`lib/tag/jekyll_plugin_support_tag.rb:72-74`,
`lib/block/jekyll_plugin_support_block.rb:82-84`,
`lib/error/jekyll_custom_error.rb:47-50` all retain commented-out
implementations. Delete — git remembers.

### 19. `parameter_specified?` returns a confusing value

```ruby
return false if @keys_values.to_s.empty?
```

Converting a Hash to String to test emptiness works but reads oddly;
`@keys_values.empty?` (with a nil guard) is clearer. Also returns `undefined`
(the comment admits "returns undefined if parameter was specified") — semantics
are murky. (`lib/helper/jekyll_plugin_helper.rb:29-37`)

### 20. `_` prefixed unused param but still required

`dump_vars(_logger, liquid_context)` — the `_` prefix says "unused," but callers
must still pass it. Either drop the parameter or use it.
(`lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:30`)

### 21. `require_directory` with safe-navigation on `Dir[]`

```ruby
Dir[...]&.sort&.each
```

`Dir[]` never returns `nil`, so `&.` is misleading noise. (`lib/jekyll_plugin_support.rb:1-5`)

### 22. `pry` as a runtime dependency

`pry` is a development/debugging tool. Shipping it as a hard runtime dependency
(`jekyll_plugin_support.gemspec`) and calling `binding.pry` in production code
paths (`lib/tag/jekyll_plugin_support_tag.rb:83`,
`lib/block/jekyll_plugin_support_block.rb:94`) is a smell — make it optional via
`if defined?(Pry)`.

## Suggested order to tackle

3. **Extract shared base for `JekyllTag`/`JekyllBlock` (#6)** — biggest maintainability win.
4. **Centralize `@mode` resolution (#7)** and stop mutating module state (#10).
5. Sweep the `abort`/`exit` calls (#14, #15) and remove dead/commented code (#4, #18).
