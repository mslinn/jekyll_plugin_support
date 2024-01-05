# `jekyll_plugin_support` [![Gem Version](https://badge.fury.io/rb/jekyll_plugin_support.svg)](https://badge.fury.io/rb/jekyll_plugin_support)

`Jekyll_plugin_support` is a Ruby gem that provides a framework for writing and testing Jekyll plugins.

`Jekyll_plugin_support` can be used to create simple Jekyll plugins in
the `_plugins/` directory of your Jekyll project, or gem-based Jekyll plugins.

At present, only Jekyll tags and blocks are supported.

Plugins that use `jekyll_plugin_support` include:

<ul style="columns: 2">
  <li><a href='https://www.mslinn.com/jekyll_plugins/jekyll_all_collections'><code>jekyll_all_collections</code></a></li>
  <li><a href='https://www.mslinn.com/jekyll_plugins/jekyll_badge'><code>jekyll_badge</code></a></li>
  <li><a href='https://www.mslinn.com/jekyll_plugins/jekyll_emoji'><code>jekyll_emoji</code></a></li>
  <li><a href='https://www.mslinn.com/jekyll_plugins/jekyll_flexible_include.html'><code>jekyll_flexible_include</code></a></li>
  <li><a href='https://www.mslinn.com/jekyll_plugins/jekyll_href.html'><code>jekyll_href</code></a></li>
  <li><a href='https://www.mslinn.com/jekyll_plugins/jekyll_img.html'><code>jekyll_img</code></a></li>
  <li><a href='https://www.mslinn.com/jekyll_plugins/jekyll_plugin_template.html'><code>jekyll_plugin_template</code></a></li>
  <li><a href='https://www.mslinn.com/jekyll_plugins/jekyll_outline.html'><code>jekyll_outline</code></a></li>
  <li><a href='https://www.mslinn.com/jekyll_plugins/jekyll_pre.html'><code>jekyll_pre</code></a></li>
  <li><a href='https://www.mslinn.com/jekyll_plugins/jekyll_quote.html'><code>jekyll_quote</code></a></li>
</ul>

... and also the demonstration plugins in
[`jekyll_plugin_support`](https://github.com/mslinn/jekyll_plugin_support/tree/master/demo/_plugins)


## Installation

`Jekyll_plugin_support` is packaged as a Ruby gem.
If your project is a custom plugin that will reside in a Jekyll project’s `_plugins` directory,
add the following line to your Jekyll plugin’s `Gemfile`.

```ruby
group :jekyll_plugins do
  ...
  gem 'jekyll_plugin_support', '>= 0.8.0'
  ...
end
```

Otherwise, if your custom plugin will be packaged into a gem, add the following to your plugin’s `.gemspec`:

```ruby
Gem::Specification.new do |spec|
  ...
  spec.add_dependency 'jekyll_plugin_support', '>= 0.8.0'
  ...
end
```

Install the `jekyll_plugin_support` Ruby gem and mark it as a dependency of your project by typing:

  ```shell
  $ bundle
  ```

Copy the CSS classes from `demo/assets/css/jekyll_plugin_support.css` to your Jekyll project&rsquo;s CSS file.


## About `jekyll_plugin_support`

`JekyllSupport::JekyllBlock` and `JekyllSupport::JekyllTag`
provide support for [Jekyll tag block plugins](https://jekyllrb.com/docs/plugins/tags/#tag-blocks)
and [Jekyll inline tag plugins](https://jekyllrb.com/docs/plugins/tags/), respectively.
They are very similar in construction and usage.

Instead of subclassing your custom Jekyll block tag class from `Liquid::Block`,
subclass from `JekyllSupport::JekyllBlock`.
Similarly, instead of subclassing your custom Jekyll tag class from `Liquid::Tag`,
subclass from `JekyllSupport::JekyllTag`.

Both JekyllSupport classes instantiate new instances of
[`PluginMetaLogger`](https://github.com/mslinn/jekyll_plugin_logger) (called `@logger`) and
[`JekyllPluginHelper`](https://github.com/mslinn/jekyll_plugin_support/blob/master/lib/jekyll_plugin_support_helper.rb)
(called `@helper`).

`JekyllPluginHelper` defines a generic initialize method, and your tag or block tag class should not need to override it.
Also, your tag or block tag class should not define a method called render, because `jekyll_plugin_support` defines one.

Instead, define a method called `render_impl`.
For inline tags, `render_impl` does not accept any parameters.
For block tags, a single parameter is required, which contains text passed from your block in the page.

Your implementation of render_impl can parse parameters passed to the tag / block tag, as described in
[Tag Parameter Parsing](http://mslinn.com/jekyll/10100-jekyll-plugin-background.html#params).

The following variables are predefined within `render`.
See the [Jekyll documentation](https://jekyllrb.com/docs/variables/) for more information.

* `@argument_string` – Original unparsed string from the tag in the web page
* `@config` – Jekyll [configuration data](https://jekyllrb.com/docs/configuration/)
* `@layout` – Front matter specified in layouts
* `@mode` – [possible values](https://jekyllrb.com/docs/configuration/environments/)
  are `development`, `production`, or `test`
* `@page` – Jekyll [page variable](https://jekyllrb.com/docs/variables/#page-variables)
* `@paginator` – Only has a value when a paginator is active; they are only available in index files.
* `@site` – Jekyll [site variable](https://jekyllrb.com/docs/variables/#site-variables)
* `@tag_name` – Name of the inline tag or block plugin
* `@theme` – Theme variables (introduced in Jekyll 4.3.0)


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


## Predefined Plugin Variables

`Jekyll_plugin_support` defines the following Ruby variables that you can use in your plugin&rsquo;s `render_impl` method:

* `@argument_string` Unparsed markup passed as a parameter to your block tag and inline tag.

* [`@attribution`](#subclass-attribution) Attribution markup

* [`@config`](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/about-github-pages-and-jekyll#configuring-jekyll-in-your-github-pages-site)
  [YAML](https://yaml.org/) Jekyll site configuration file

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

* [`@tag_config`](lib/jekyll_plugin_support_tag.rb)
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

If an argument has a variable reference in it, the value of the variable is substituted for the reference.
For example, given:

* `_layouts/default.html` defines a variable called `var_layout` in its front matter.
* `index.html` defines a variable called `var_page` in its front matter.
* `index.html` assigns a variable called `x` via the liquid `assign` statement.

... then the following references in a page will be substituted for their values in arguments and in block tag bodies:

```html
{% my_block_tag param1="x={{x}}" param2="var_page={{page.var_page}}" param3="var_layout={{layout.var_layout}}" %}
Assigned variables do not need a namespace: x={{x}}
Page variables must be qualified with the 'page' namespace: var_page={{page.var_page}}
Layout variables must be qualified with the 'layout' namespace: var_layout={{layout.var_layout}}
{% endmy_block_tag %}
```

You can see similar code in [`demo/demo_inline_tag.html`](demo/demo_inline_tag.html).

The `page['excerpt']`, `page['next']` and `page['previous']` key/value pairs are
removed from processing because of recursion issues.
You cannot look up those values.


### Automatically Created Error Classes

`JekyllSupport::JekyllBlock` and `JekyllSupport::JekyllTag` subclasses
automatically create error classes, named after the subclass.

For example, if you create a `JekyllSupport::JekyllBlock` subclass called `DemoBlockTag`,
the automatically generated error class will be called `DemoBlockTagError`.

Although you could use it as you would any other error class, `JekyllPluginSupport` provides some helper methods.
These methods fill in the page path and line number that caused the error, shorten the stack trace,
log an error message, and can be used to return an HTML-friendly version of the message to the web page.

The following example is a shortened version of `demo/_plugins/demo_block_tag.rb`.
You might want to write similar code in your `rescue` blocks.

```ruby
class DemoBlock < JekyllSupport::JekyllBlock
  VERSION = '0.1.2'.freeze

  def render_impl(text)
    raise DemoBlockTagError, 'Fall down, go boom.'
  rescue DemoBlockTagError => e
    e.shorten_backtrace
    @logger.error e.logger_message
    raise e if @die_on_demo_block_error

    e.html_message
  end
end
```

Error class methods have been provided for standardized and convenient error handling:

* `shorten_backtrace` - most of the lines that spew from a Jekyll backtrace are uninteresting.
* `logger_message` - The message is constructed from the string provided when the error was raised,
   with the page path and line number added.
* `html_message` - The same as `logger_message`, but constructed with HTML.


### Self-Reporting Upon Registration

When each tag is registered, it self-reports, for example:

```text
INFO PluginMetaLogger: Loaded plugin demo_inline_tag v0.1.2. It has:
  Error class: DemoTagError
  CSS class for error messages: demo_tag_error

  _config.yml contains the following configuration for this plugin:
    {"die_on_demo_tag_error"=>false, "die_on_standard_error"=>false}


INFO PluginMetaLogger: Loaded plugin demo_inline_tag_no_arg v0.1.0. It has:
  Error class: DemoTagNoArgsError
  CSS class for error messages: demo_tag_no_args_error

  _config.yml does not contain configuration information for this plugin.
  You could add a section containing default values by specifying a section for the tag name,
  and an entry whose name starts with `die_on_`, followed by a snake_case version of the error name.

    demo_inline_tag_no_arg:
      die_on_demo_tag_no_args_error: false
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

### Remaining Markup

After your plugin has parsed all the keyword options and name/value parameters,
call `@helper.remaining_markup` to obtain the remaining markup that was passed to your plugin.


## Liquid Variable Definitions

`jekyll_plugin_support` provides support for
[Liquid variables](https://shopify.github.io/liquid/tags/variable/)
to be defined in `_config.yml`, in a section called `liquid-vars`.
The following `_config.yml` fragment defines 3 variables called `var1`, `var2` and `var3`:

```yaml
liquid-vars:
  var1: value1
  var2: 'value 2'
  var3: value3
```

Liquid variables defined in this manner are intended to be embedded in a webpage.
They are expanded transparently, and can be referenced like any other Liquid variable.
These Liquid variables can be passed as parameters to other plugins and includes.

In the following example web page, the Liquid variable called `var1` is expanded as part of the displayed page.
Liquid variables `var1` and `var2` are expanded and passed to the `my_plugin` plugin.

```html
This is the value of <code>var1</code>: {{var1}}.

{% my_plugin param1="{{var1}}" param2="{{var2}}" %}
```

`Jekyll_plugin_support` expands all but one of the
[plugin variables described above](#predefined-variables),
replacing Liquid variable references with their values.
The exception is `@argument_string`, which is not expanded.


### Liquid Variable Values Specific To Production And Development Modes

`jekyll_plugin_support` allows Liquid variables defined in `_config.yml` to have different values
when Jekyll is running in `development`, `production` and `test` modes.
When injecting variables into your Jekyll website, `Jekyll_plugin_support`
refers to definitions specific to the current environment,
and then refers to other definitions that are not overridden.

Here is an example:

```yaml
liquid-vars:
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

... and the following variable values are set in `production` and `test` modes:

* `var1`: `https://github.com/django/django/blob/3.1.7`
* `var2`: `https://github.com/django-oscar/django-oscar/blob/3.0.2`
* `var3`: `https://github.com/mslinn`


### Liquid Variables in `jekyll_plugin_support` Subclasses

You can define additional Liquid variables in plugins built using `jekyll_plugin_support`.
To do this, make entries in `_config.yml` under a key named after the value of `@tag_name`.

For example, let&rsquo;s imagine you create a plugin using `jekyll_plugin_support`,
and hou register it with the name `phonetic_alphabet`.
You could define Liquid variables that would be made available to content pages in web applications that
incorporate the `phonetic_alphabet` plugin.
The following section in `_config.yml` defines variables called `x`, `y` and `z`,
with values `xray`, `yankee` and `zulu`, respectively:

```yaml
phonetic_alphabet:
  x: xray
  y: yankee
  z: zulu
```

The above definitions allow you to write content pages that use those variables, like the following page containing markup:

```html
---
layout: default
title: Variable demo
---
The letter `x` is pronounced {{x}}.
Similarly, the letters `y` and `z` are pronounced {{y}} and {{z}}.
```


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

After checking out the `jekyll_plugin_suppprt` repository, run `bin/setup` to install dependencies.

`bin/console` provides an interactive prompt that allows you to experiment.


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


### Pry Breakpoint On StandardError

A `pry` breakpoint will be set in the `StandardError` handler if `pry_on_standard_error: true`
is set in variable configuration section of `_config.yml`.

For example, if your plugin is called `blah`, enable the breakpoint with the following section:

```yml
blah:
  pry_on_standard_error: true
```


## Demonstration Plugins and Website

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
