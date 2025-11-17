# Future Work

Do not perform any of the following without specific authorization.

## Rework Windows Environment Variable Expansion

Many shells, for example Bash, denote environment variable references (env vars)
by prefixing them with a dollar sign ($). Windows environment variables are
denoted differently, by enclosing them within percents (%).

In JPS, the current implementation of environment expansion is defined in the
`JekyllPluginHelper.expand_env` method in
`$jekyll_plugin_support/lib/helper/jekyll_plugin_helper_class.rb`. This method
currently calls `JekyllPluginHelper.expand_env`, which in turn calls
`JekyllPluginHelper.env_var_expand_bash` and
`JekyllPluginHelper.env_var_expand_windows`. This is problematic because
websites often contain text strings that contain pairs of percents that should
not be expanded because they do not correspond to environment variables (for
example "blah%some_text%more text").

To correct the problem, `expand_env` should never call `env_var_expand_windows`,
and should instead merely return the result of calling `env_var_expand_bash`.
This means that the `use_wslvar` method is not required by this method and the
method signature should be simplified. The

`JekyllPluginHelper.env_var_expand_windows` will be called by JPS plugins when
required, so it must remain as is, without any changes.

Currently the only Jekyll plugin that needs to call
`JekyllPluginHelper.env_var_expand_windows` is `jekyll_flexible_include_plugin`.
We only need to call this method to expand the `file` parameter, exactly as shown in `$jekyll_flexible_include_plugin/demo/index.html`.

Modify `$jekyll_flexible_include_plugin/lib/flexible_include_private_methods.rb`
so the `@filename` parameter is expanded using both
`JekyllPluginHelper.env_var_expand_bash` and
`JekyllPluginHelper.env_var_expand_windows`.

Describe your plan and obtain approval before starting.
