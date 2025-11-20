# Progress

## Completed Tasks

### Fix JekyllDrop Iteration Error (2025-11-20)

**Problem**: When launching the demo Jekyll website, multiple plugins (HRefTag, JekyllBadge, IfDraft, ElseDraft, UnlessDraft, ElseNotDraft) failed with:
```
undefined method 'each' for an instance of Jekyll::Drops::JekyllDrop (NoMethodError)
```

This occurred in `JekyllSupport.process_jekyll_variables` method which tried to call `.each` on the `jekyll` parameter (a JekyllDrop object).

**Root Cause**: JekyllDrop provides access to `jekyll.version` and `jekyll.environment` via method calls, but does not support iteration with `.each`.

**Solution Implemented**:
- Modified `JekyllSupport.process_jekyll_variables` in `lib/jekyll_plugin_support/jekyll_plugin_support_class.rb`
- Changed from iterating with `.each` to checking for specific JekyllDrop attributes
- Now properly accesses: `jekyll.version` and `jekyll.environment`
- Added nil check and proper error handling

**Files Modified**:
- `lib/jekyll_plugin_support/jekyll_plugin_support_class.rb` - Updated `process_jekyll_variables` method (line 171-179)

**Tests**: All 51 tests pass ✓
**Result**: Jekyll server launches successfully without JekyllDrop iteration errors ✓

**Benefits**:
- Jekyll global variables ({{jekyll.version}} and {{jekyll.environment}}) now work correctly
- Prevents runtime errors when processing Jekyll global variables in plugins
- Maintains backward compatibility with existing code
- Proper error handling for edge cases

### Rework Windows Environment Variable Expansion (2025-01-02)

**Problem**: The `expand_env` method was calling both `env_var_expand_bash` and `env_var_expand_windows`, which caused false expansions in web content where text strings contain pairs of percent signs that are not environment variables.

**Solution Implemented**:
- Modified `JekyllPluginHelper.expand_env` in `lib/helper/jekyll_plugin_helper_class.rb` to only call `env_var_expand_bash`
- Removed the `use_wslvar` parameter from `expand_env` method signature
- Updated `JekyllPluginHelper.find_windows_envar` to properly fall back to environment variable search when `wslvar` is not available or doesn't find the variable
- Modified `jekyll_flexible_include_plugin/lib/flexible_include.rb` to explicitly call both `env_var_expand_bash` and `env_var_expand_windows` for file paths
- Updated tests in `spec/expand_env_spec.rb` to reflect the new behavior

**Files Modified**:
- `lib/helper/jekyll_plugin_helper_class.rb` - Updated `expand_env` and `find_windows_envar` methods
- `lib/helper/jekyll_plugin_helper.rb` - Removed `use_wslvar` parameter from parse method
- `spec/expand_env_spec.rb` - Updated tests to verify new behavior
- `$jekyll_flexible_include_plugin/lib/flexible_include.rb` - Added explicit Windows env var expansion for file paths

**Tests**: All 51 tests pass ✓
**Linting**: Code style violations fixed ✓

**Benefits**:
- Text content with percent signs no longer triggers false environment variable expansions
- `env_var_expand_windows` remains available for plugins that specifically need Windows environment variable support
- The `flexible_include` plugin maintains its ability to handle both Bash (`$VAR`) and Windows (`%VAR%`) environment variables in file paths
