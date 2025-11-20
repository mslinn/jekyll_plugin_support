# Future Work

Do not perform any of the following without specific authorization.

## Check How Jekyll Variables Are Accessed

Jekyll provides many types of variables for Jekyll plugins to use (see https://jekyllrb.com/docs/variables/):

- `include` variables
- `layout` variables
- `page` variables
- `site` variables
- look for more

This plugin (`jekyll_plugin_support`) also reads `_config.yml` to and adds
variable definitions found there to `site` variables. These are called config
variables. Read the "Variable Expansion" section of `README.md` for information,
but beware that it might be incomplete or slightly inaccurate.

You will be asked to perform research, followed by analysis and then action.
Maintain a document called `.chat/variables.md` with your findings as you
proceed. This is not meant to be a chronological log of your progress (you
already maintain `.chat/PROGRESS.md`). Instead, this document should continually
be revised as new information becomes available.

Each of the following steps is meant to be done in separate chat sessions. Be
sure to provide enough information in `.chat/variables.md` so that you can
efficiently resume from subsequent new chat sessions.

1. Locate and summarize all the places in `jekyll_plugin_support` that obtain
   each type of variable listed above from Jekyll. Present your findings,
   commit, push and stop.

2. Read the Jekyll source code (https://github.com/jekyll/jekyll). Locate and
   summarize all the places that create variables which can be used by Jekyll
   plugins. In addition, you had flagged these in the previous step:

    - `:content` - Page content
    - `:highlighter_prefix` - Syntax highlighter prefix
    - `:highlighter_suffix` - Syntax highlighter suffix
    - `:jekyll` - Jekyll-specific variables

   Document what these 4 sources of variables are for.
   Present your findings, commit, push and stop.

3. When the user tells you to, analyze how `jekyll_plugin_support` obtains the
   names and values of Jekyll variables and summarize any problems found.
   Check the "Variable Expansion" section of `README.md` for accuracy.
   Present your findings, commit, push and stop.

4. Fix any problems found in `jekyll_plugin_support`, commit, push.

5. Update the documentation, commit, push.
