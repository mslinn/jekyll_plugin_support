# `jekyll_plugin_support` [![Gem Version](https://badge.fury.io/rb/jekyll_plugin_support.svg)](https://badge.fury.io/rb/jekyll_plugin_support)

`Jekyll_plugin_support` is a Ruby gem that facilitates writing and testing Jekyll plugins.

`Jekyll_plugin_support` can be used to create simple Jekyll plugins in
the `_plugins/` directory of your Jekyll project, or gem-based Jekyll plugins.

At present, only Jekyll tags and blocks are supported.


## Installation

1. If your Jekyll plugin is packaged as a Ruby gem, add the following to your project&rsquo;s `.gemspec`:

   ```ruby
   spec.add_dependency 'jekyll_plugin_support', '>= 0.7.3'
   ```

   Otherwise, add the following to your Jekyll project&rsquo;s `Gemfile`,
   inside the `jekyll_plugins` group:

   ```ruby
   group :jekyll_plugins do
     gem 'jekyll_plugin_support'
   end
   ```

2. Install the `jekyll_plugin_support` Ruby gem and mark it as a dependency of your project by typing:

   ```shell
   $ bundle
   ```

3. Copy the CSS from `demo/assets/css/styles.css` between the comments to your Jekyll project's CSS file:

   ```css
   blah blah blah

   /* Start of jekyll_plugin_support css */
   Copy these lines
   /* End of jekyll_plugin_support css */

   blah blah blah
   ```


## General Usage

Please see the [`demo/`](demo/) project for a well-documented set of demonstration Jekyll plugins that are built from `jekyll_plugin_support`.
Additional information is available [here](https://mslinn.com/jekyll/10200-jekyll-plugin-background.html) and the
[`jekyll_plugin_support`](https://www.mslinn.com/jekyll_plugins/jekyll_plugin_support.html) documentation.

`JekyllSupport::JekyllBlock` and `JekyllSupport::JekyllTag`
provide support for Jekyll block tags and Jekyll inline tags, respectively.
They are similar in construction and usage.

Instead of subclassing your Jekyll block tag class from `Liquid::Block`,
subclass from `JekyllSupport::JekyllBlock` instead.

Likewise, instead of subclassing your Jekyll inline tag class from `Liquid::Tag`,
subclass from `JekyllSupport::JekyllTag` instead.

Both `JekyllSupport` classes instantiate new instances of
[`PluginMetaLogger`](https://github.com/mslinn/jekyll_plugin_logger) (called `@logger`) and
[`JekyllPluginHelper`](lib/jekyll_plugin_helper.rb) (called `@helper`).


### Inline and Block Tag Plugin Implementation

Both `JekyllSupport` classes define a generic `initialize` method,
and your inline tag or block tag class should not override it.

Also, your inline tag or block tag class should not define a method called `render`,
because both `JekyllSupport` classes define this method.


Instead, define a method called `render_impl`.
For inline tags, `render_impl` does not accept any parameters.
For block tags, a single parameter is required, which contains any text enclosed within your block.


## Predefined Variables

`Jekyll_plugin_support` defines the following variables that you can use in your plugin&rsquo;s `render_impl` method:

* `@argument_string` Unparsed markup passed as a parameter to your block tag and inline tag.

* [`@attribution`](#subclass-attribution) Attribution markup

* [`@config`](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/about-github-pages-and-jekyll#configuring-jekyll-in-your-github-pages-site)
  [YAML](https://yaml.org/) Jekyll site configuration file

* `@envs` Undocumented Jekyll variable, can be insightful when exploring.

* [`@helper`](https://github.com/mslinn/jekyll_plugin_support/blob/master/lib/jekyll_plugin_helper.rb)
  `JekyllPluginHelper` instance for your plugin.

* [`@layout`](https://jekyllrb.com/docs/variables/#global-variables) Layout information

* [`@logger`](jekyll_plugin_logger) `jekyll_plugin_logger` instance for your Jekyll plugin.

* [`@mode`](https://jekyllrb.com/docs/configuration/environments/)
  Indicates `production` or `development` mode.

* [`@page`](https://jekyllrb.com/docs/variables/#page-variables) Page variables

* [`@paginator`](https://jekyllrb.com/docs/variables/#page-variables) Pagination variables

* [`@scopes`](https://jekyllrb.com/docs/variables/)
  See the [`jekyll_plugin_support` demo project](demo/variables.html)

* [`@site`](https://jekyllrb.com/docs/variables/#site-variables) Site variables

* [`@tag_death`](lib/jekyll_plugin_support_tag.rb)
  Contents of the section of `_config.yml` named after your plugin.

* `@tag_name` Name of your Jekyll block tag or inline tag plugin.

* [`@theme`](https://jekyllrb.com/docs/variables/#global-variables) Theme variables

* `text` Content provided to your block tag.


## Argument Parsing

Tag arguments can be obtained within `render_impl`.
Both keyword options and name/value parameters are supported.

Both `JekyllTag` and `JekyllBlock` use the standard Ruby mechanism for parsing command-line options:
[`shellwords`](https://ruby-doc.org/stdlib-2.5.1/libdoc/shellwords/rdoc/Shellwords.html) and
[`key_value_parser`](https://www.rubydoc.info/gems/key-value-parser).

All your code has to do is to specify the keywords to search for in the string
passed from the HTML page that your tag is embedded in.
The included `demo` website has examples;
both [`demo/_plugins/demo_inline_tag.rb`](demo/_plugins/demo_inline_tag.rb) and
[`demo/_plugins/demo_block_tag.rb`](demo/_plugins/demo_block_tag.rb) contain the following:

```ruby
@keyword1  = @helper.parameter_specified? 'keyword1'
@keyword2  = @helper.parameter_specified? 'keyword2'
@name1     = @helper.parameter_specified? 'name1'
@name2     = @helper.parameter_specified? 'name2'
```


### Example

[`demo/index.html`](demo/index.html), contains the following inline tag invocation:

```html
{% demo_inline_tag keyword1 name1='value1' unreferenced_key unreferenced_name="unreferenced_value" %}
```

The `demo/_plugins/demo_inline_tag.rb` plugin uses `@helper.parameter_specified?` provided by
`jekyll_support_plugin` to parse the string passed to the tag, which is
`keyword1 name1='value1' unreferenced_key unreferenced_name="unreferenced_value"`.

* Because `keyword1` was referenced by `@helper.parameter_specified?` above,
    that keyword option is removed from the argument string.
* Because the `name1` key/value parameter was referenced by `@helper.parameter_specified?` above,
    that name/value pair is removed from the argument string.
* The remainder of the argument string is now `unreferenced_key unreferenced_name="unreferenced_value"`.


### To Quote Or Not To Quote

Parameter values can be quoted.

If the value consists of only one token then quoting is optional.
The following name/value parameters all have the same result:

* `pay_tuesday="true"`
* `pay_tuesday='true'`
* `pay_tuesday=true`
* `pay_tuesday`

If the values consist of more than one token, quotes must be used.
The following examples both yield the same result:

* `pay_tuesday="maybe not"`
* `pay_tuesday='maybe not'`

## Remaining Markup

After your plugin has parsed all the keyword options and name/value parameters,
call `@helper.remaining_markup` to obtain the remaining markup that was passed to your plugin.


## Configuration Variable Definitions

Liquid variables may be defined in `_config.yml`, in a section called `plugin-vars`.
The following `_config.yml` fragment defines 3 variables called `var1`, `var2` and `var3`:

```yaml
plugin-vars:
  var1: value1
  var2: 'value 2'
  var3: value3
```

Variable references embedded in a webpage are expanded transparently.
They can be referenced like any other Liquid variable:

```html
This is the value of <code>var1</code>: {{var1}}
```

`Jekyll_plugin_support` expands all but one variable references before the values
of the [variables described above](#predefined-variables) are set.
The exception is `@argument_string`, which is not expanded.


### Variable Values Specific To Production And Development Modes

Liquid variables defined in `_config.yml` can have different values
when Jekyll is running in `development` and `production` modes.
When injecting variables into your Jekyll website, `Jekyll_plugin_support`
refers to definitions specific to the current environment,
and then refers to other definitions that are not overridden.

Here is an example:

```yaml
plugin-vars:
  development:
    var1: 'http://localhost:4444/demo_block_tag.html'
    var2: 'http://localhost:4444/demo_inline_tag.html'
  production:
    var1: 'https://github.com/django/django/blob/3.1.7'
    var2: 'https://github.com/django-oscar/django-oscar/blob/3.0.2'
  var3: 'https://github.com/mslinn'
```

For the above, the following variable values are set in `development` mode:

* `var1`: `http://localhost:4444/demo_block_tag.html`
* `var2`: `http://localhost:4444/demo_inline_tag.html`
* `var3`: `https://github.com/mslinn`

... and the following variable values are set in `production` mode:

* `var1`: `https://github.com/django/django/blob/3.1.7`
* `var2`: `https://github.com/django-oscar/django-oscar/blob/3.0.2`
* `var3`: `https://github.com/mslinn`


## `no_arg_parsing` Optimization

If your tag or block plugin only needs access to the raw arguments passed from the web page,
without tokenization, and you expect that the plugin might be invoked with large amounts of text,
derive your plugin from `JekyllBlockNoArgParsing` or `JekyllTagNoArgParsing`.


## Subclass Attribution

`JekyllTag` and `JekyllBlock` subclasses of `jekyll_plugin_support` can utilize the `attribution`
option if they are published as a gem.
`JekyllTagNoArgParsing` and `JekyllBlockNoArgParsing` subclasses cannot.
This feature is usually only desired for `JekyllBlock` subclasses.

* When used as a keyword option, a default value is used for the attribution string.
* When used as a name/value option, the attribution string can be specified.

Using the `attribution` option cause subclasses to replace their usual output with HTML that looks like:

```html
<div id="jps_attribute_12345" class="jps_attribute">
  <a href="https://github.com/mslinn/jekyll_outline">
    <b>Generated by <code>jekyll_outline</code>.
  </a>
</div>
```

The `id` attribute is in the sample HTML above is randomized so more than one attribution can appear on a page.


### Usage

Typical usage for the `attribution` tag is:

```html
{% my_block_tag attribution %}
  Content of my_block_tag.
{% endmy_block_tag %}
```

Normal processing of `my_block_tag` is augmented by interpolating the attribution format string,
which is a Ruby-compatible interpolated string.

The default attribution format string is:

```ruby
"Generated by the #{name} #{version} Jekyll plugin, written by #{author} #{date}."
```

Because `jekyll_plugin_suppprt` subclasses are `gem`s, their `gemfile`s define values for
`name`, `version`, `homepage`, and `authors`, as well as many other properties.
The `date` property is obtained from the plugin/gem publishing date.

An alternative attribution string can be specified properties can be output using any of the above properties:

```html
{% my_tag attribution="Generated by the #{name} #{version} Jekyll plugin, written by #{author} #{date}" %}
```

### Attribution Generation

You can decide where you want the attribution string for your Jekyll tag to appear by invoking `@helper.attribute`.
For example, this is how the
[`jekyll_outline` tag](https://github.com/mslinn/jekyll_outline/blob/v1.1.1/lib/outline_tag.rb#L32-L46) generates output:

```html
<<~HEREDOC
<div class="outer_posts">
#{make_entries(collection)&.join("\n")}
</div>
#{@helper.attribute if @helper.attribution}
HEREDOC
```


## Development

After checking out the repo, run `bin/setup` to install dependencies.

You can also run `bin/console` for an interactive prompt that will allow you to experiment.


To build and install this gem onto your local machine, run:

```shell
$ bundle exec rake install
jekyll_plugin_support 0.1.0 built to pkg/jekyll_plugin_support-0.1.0.gem.
jekyll_plugin_support (0.1.0) installed.
```

Examine the newly built gem:

```shell
$ gem info jekyll_plugin_support

*** LOCAL GEMS ***

jekyll_plugin_support (0.1.0)
    Author: Mike Slinn
    Homepage:
    https://github.com/mslinn/jekyll_plugin_support
    License: MIT
    Installed at: /home/mslinn/.gems

    Provides support for writing Jekyll plugins.
```


## Demo

A demo / test website is provided in the `demo` directory.
It can be used to debug the plugin or to run freely.


### Run Freely

 1. Run from the command line:

    ```shell
    $ demo/_bin/debug -r
    ```

 2. View the generated website,
    which might be at [`http://localhost:4444`](http://localhost:4444),
    depending on how you configured it.


### Plugin Debugging

 1. Set breakpoints in Visual Studio Code.

 2. Initiate a debug session from the command line by running the `demo/_bin/debug` script:

    ```shell
    $ demo/_bin/debug
    Fetching gem metadata from https://rubygems.org/..........
    Resolving dependencies...
    Fetching public_suffix 5.0.4
    Fetching nokogiri 1.15.5 (x86_64-linux)
    Installing public_suffix 5.0.4
    Installing nokogiri 1.15.5 (x86_64-linux)
    Bundle complete! 17 Gemfile dependencies, 96 gems now installed.
    Use `bundle info [gemname]` to see where a bundled gem is installed.

    INFO PluginMetaLogger: Loaded DraftFilter plugin.
    INFO PluginMetaLogger: Loaded outline_js v1.2.1 plugin.
    INFO PluginMetaLogger: Loaded outline v1.2.1 plugin.
    Configuration file: /mnt/f/jekyll_plugin_support/demo/_config.yml
              Cleaner: Removing /mnt/f/jekyll_plugin_support/demo/_site...
              Cleaner: Removing /mnt/f/jekyll_plugin_support/demo/.jekyll-metadata...
              Cleaner: Removing /mnt/f/jekyll_plugin_support/demo/.jekyll-cache...
              Cleaner: Nothing to do for .sass-cache.
    DEBUGGER: Debugger can attach via TCP/IP (127.0.0.1:37177)
    DEBUGGER: wait for debugger connection...
    ```

 3. Once the `DEBUGGER: wait for debugger connection...` message appears,
    run the Visual Studio Code launch configuration called `Attach with rdbg`.

 4. View the generated website,
    which might be at [`http://localhost:4444`](http://localhost:4444),
    depending on how you configured it.


### Build and Push to RubyGems

To release a new version:

  1. Update the version number in `version.rb`.
  2. Add an entry to `CHANGELOG.md` describing the changes since the previous version.
  3. Commit all changes to git;
     if you don't the next step might fail with an unexplainable error message.
  4. Run the following:

     ```shell
     $ bundle exec rake release
     ```

     The above creates a git tag for the version, commits the created tag,
     and pushes the new `.gem` file to [RubyGems.org](https://rubygems.org).


## Contributing

1. Fork the project
2. Create a descriptively named feature branch
3. Add your feature
4. Submit a pull request


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
