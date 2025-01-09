# `jekyll_plugin_support` [![Gem Version](https://badge.fury.io/rb/jekyll_plugin_support.svg)](https://badge.fury.io/rb/jekyll_plugin_support)

After writing over two dozen Jekyll plugins, I distilled the common code into `Jekyll_plugin_support`.
This F/OSS Ruby gem facilitates writing and testing Jekyll plugins and handles the standard housekeeping that every Jekyll
inline and block tag plugin requires.
Logging, parsing arguments, obtaining references to site and page objects, etc. are all handled.
The result is faster Jekyll plugin writing with fewer bugs.

`Jekyll_plugin_support` can be used to create simple Jekyll plugins in
the `_plugins/` directory of your Jekyll project, or gem-based Jekyll plugins.

At present, only Jekyll tags and blocks are supported.

Public plugins that use `jekyll_plugin_support` include:

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


## Features

Jekyll plugin tags created from `jekyll_plugin_support` framework automatically have the following features:

1. Boilerplate is removed, so you can focus on the required logic and output.
2. Arguments are parsed for keywords and name/value parameters.
3. Single or double quotes can be used for arguments and parameters.
4. Important variables are predefined.
5. Error handling is standardized, and includes an automatically defined error type
   and corresponding CSS tag for each Jekyll tag.
6. Jekyll and Liquid variables, including `layout`, `page` and `include` variables,
   can be passed as parameters to tags, and used in the body of block tags.
7. Plugin registration is integrated, and important configuration details are reported during registration.
8. A custom logger is created for each tag, independent of the default Jekyll logger.
9. Variables can be defined in `_config.yml`, and optionally have different values for debug mode,
   production mode and test mode.
10. An attribution message is available.
11. Draft pages are automatically detected.
12. A demonstration website is provided for easy testing of every plugin.
13. Visual Studio Code debugging is set up for the plugin code and the demo website.
14. Plugins can be subclassed.
15. [`Nugem`](https://mslinn.com/ruby/6800-nugem.html) can create working scaffolding for new plugins built
    using `jekyll_plugin_support`.


## Installation

### For A Jekyll Website

`Jekyll_plugin_support` is packaged as a Ruby gem.
If you want to write a custom Jekyll plugin that will reside in a Jekyll project’s `_plugins` directory,
add the following line to your Jekyll plugin’s `Gemfile`.

```ruby
group :jekyll_plugins do
  # ...
  gem 'jekyll_plugin_support', '>= 1.1.0'
  # ...
end
```

Run the standard `jekyll_plugin_support` setup procedure:

```shell
$ bin/setup
```


### As a Gem Dependency

If your custom plugin will be packaged into a gem, add the following to your plugin’s `.gemspec`:

```ruby
Gem::Specification.new do |spec|
  # ...
  spec.add_dependency 'jekyll_plugin_support', '>= 1.1.0'
  # ...
end
```

Install the `jekyll_plugin_support` gem into your plugin project in the usual manner:

```shell
$ bundle
```

Copy the CSS classes from
[`demo/assets/css/jekyll_plugin_support.css`](demo/assets/css/jekyll_plugin_support.css)
to your Jekyll project&rsquo;s CSS file.




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

Your implementation of render_impl can parse parameters passed to your tag, as described in
[Tag Parameter Parsing](http://mslinn.com/jekyll/10100-jekyll-plugin-background.html#params).

In addition, within <code>render_impl</code>,
the arguments passed to the tag will have been tokenized and parsed,
with Jekyll and Liquid variables substituted for their values,
and all the public Jekyll variables will be available as instance variables.
Error handling will also have been set up,
and access to your tag's entry within <code>_config.yml</code> will have been set up.



## General Usage

Please see the [`demo/`](demo/) project for a well-documented set of demonstration Jekyll plugins built from `jekyll_plugin_support`.
Additional information is available [here](https://mslinn.com/jekyll/10200-jekyll-plugin-background.html) and the
[`jekyll_plugin_support`](https://www.mslinn.com/jekyll_plugins/jekyll_plugin_support.html) documentation.

[`JekyllSupport::JekyllBlock`](https://github.com/mslinn/jekyll_plugin_support/blob/master/lib/jekyll_plugin_support_block.rb) and
[`JekyllSupport::JekyllTag`](https://github.com/mslinn/jekyll_plugin_support/blob/master/lib/jekyll_plugin_support_tag.rb) provide
support for Jekyll block tags and Jekyll inline tags, respectively.
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
For block tags, a single parameter is required, which receives any text enclosed within your block by the website author.


## Predefined Plugin Variables

`Jekyll_plugin_support` defines the following Ruby variables that you can use in your plugin&rsquo;s `render_impl` method:

* `@argument_string` Unparsed markup passed as a parameter to your block tag and inline tag.

* `@argv` returns any remaining tokens after `parameter_specified?` has been invoked.

* [`@attribution`](#subclass-attribution) Attribution markup

* [`@config`](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/about-github-pages-and-jekyll#configuring-jekyll-in-your-github-pages-site)
  The [YAML](https://yaml.org/) Jekyll site configuration file

* [`@helper`](https://github.com/mslinn/jekyll_plugin_support/blob/master/lib/jekyll_plugin_helper.rb)
  `JekyllPluginHelper` instance for your plugin.

* [`@layout`](https://jekyllrb.com/docs/variables/#global-variables) Layout information

* `@logger` [`jekyll_plugin_logger`](https://github.com/mslinn/jekyll_plugin_logger) instance for your Jekyll plugin.

* [`@mode`](https://jekyllrb.com/docs/configuration/environments/)
  Indicates `production`, `test` or `development` mode.

* [`@page`](https://jekyllrb.com/docs/variables/#page-variables) `Jekyll::Page` variables

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
{% my_block_tag
  param1="x={{x}}"
  param2="var_page={{page.var_page}}"
  param3="var_layout={{layout.var_layout}}"
%}

Assigned variables do not need a namespace: x={{x}}

Page variables must be qualified with the 'page' namespace:
  var_page={{page.var_page}}

Layout variables must be qualified with the 'layout' namespace:
  var_layout={{layout.var_layout}}
{% endmy_block_tag %}
```

You can see similar code in [`demo/demo_inline_tag.html`](demo/demo_inline_tag.html).

The `page['excerpt']` and `page['output']` key/value pairs are removed from processing because of recursion issues.
You cannot look up those values from a `jekyll_plugin_support` plugin.


### Keyword Options

For all keyword options, values specified in the document _may_ be provided.
If a value is not provided, the value `true` is assumed.
Otherwise, if a value is provided, it _must_ be wrapped in single or double quotes.


### Examples

The following examples use the `die_if_error` keyword option for the
[`pre`](https://www.mslinn.com/jekyll_plugins/jekyll_pre.html#tag) and
[`exec`](https://www.mslinn.com/jekyll_plugins/jekyll_pre.html#tag_exec)
tags from the [`jekyll_pre`](https://www.mslinn.com/jekyll_plugins/jekyll_pre.html) plugin %}.


#### Specifying Tag Option Values

The following sets `die_if_error` `true`:

```html
{% pre die_if_error %} ... {% endpre %}
```

The above is the same as writing:

```html
{% pre die_if_error='true' %} ... {% endpre %}
```

Or writing:

```html
{% pre die_if_error="true" %} ... {% endpre %}
```

Neglecting to provide surrounding quotes around the provided value causes the parser to not recognize the option.
Instead, what you had intended to be the keyword/value pair will be parsed as part of the command.
For the `pre` tag, this means the erroneous string becomes part of the `label` value,
unless `label` is explicitly specified.
For the `exec` tag, this means the erroneous string becomes part of the command to execute.
The following demonstrates the error.

```html
{% pre die_if_error=false %} ... {% endpre %}
```

The above causes the label to be `die_if_error=false`.

```html
{% exec die_if_error=false ls %} ... {% endpre %}
```

The above causes the command to be executed to be `die_if_error=false ls` instead of `ls`.


### Quoting

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


## Configuration Variables

`jekyll_plugin_support` provides support for
[Liquid variables](https://shopify.github.io/liquid/tags/variable/)
to be defined in `_config.yml`, in a section called `liquid_vars`.
These variables behave exactly like Liquid variables defined by `assign` and `capture` expressions,
except they are global in scope; these variables are available in every Jekyll web page.

The following `_config.yml` fragment defines 3 variables called `var1`, `var2` and `var3`:

```yaml
liquid-vars:
  var1: value1
  var2: 'value 2'
  var3: value3
```

Liquid variables defined in this manner are intended to be embedded in a webpage.
They are can be used like any other Liquid variable.


## Variable Expansion

Jekyll expands Liquid variable references during the page rendering process.
Jekyll does not expand Liquid variable references passes as parameters to tag and block plugins, however.
However, plugins made from `jekyll_plugin_support` automatically
expand all types of variable references passed as parameters and in block tag bodies.

`Jekyll_plugin_support` tag and block plugins expand the following types of variables:

* Jekyll_plugin_support configuration variables, discussed above.
* Jekyll [page](https://jekyllrb.com/docs/variables/#page-variables) and
  [layout](https://jekyllrb.com/docs/layouts/#variables) variables.
* Inline Liquid variables (defined in [assign](https://shopify.dev/docs/api/liquid/tags/assign) and [capture](https://shopify.dev/docs/api/liquid/tags/capture) statements).

In the following example web page, Jekyll expands the `var1` reference within the `<p></p>` tag,
but not the `var1` or `var2` references passed to `my_plugin`.

```html
<p>This is the value of var1: {{var1}}.</p>

{% my_plugin param1="{{var1}}" param2="{{var2}}" %}
```

Assuming that `my_plugin` was written as a `jekyll_plugin_support` plugin,
all variable references in its parameters are expanded.
Thus, the above is interpreted as follows when `my_plugin` is evaluated during the Jekyll rendering process:
</p>

```html
<p>This is the value of var1: value1.</p>

{% my_plugin param1="value1" param2="value 2" %}
```


`Jekyll_plugin_support` expands most of the [plugin variables described above](#predefined-variables),
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


### Evaluating Include Variables

This information is only useful if a plugin might be executed from within an included file.

While Liquid handles regular variables, Jekyll has special handling for variables defined by include parameters.
For example, the following defines a variable in the `include` scope called `var1`
when processing the body of an included file:

```html
{% include myfile.html var1='value1' %}
```

You can obtain the value of this variable from the `render_impl` method of a
`JekyllSupport::JekyllTag` or `JekyllSupport::JekyllBlock` subclass as follows:

```ruby
  @var1 = @scopes.first['include']&.[]('var1')
```


## Automatically Created Error Classes

`JekyllSupport::JekyllBlock` and `JekyllSupport::JekyllTag` subclasses
automatically create error classes, named after the subclass.

For example, if you create a `JekyllSupport::JekyllBlock` subclass called `DemoBlockTag`,
the automatically generated error class will be called `DemoBlockTagError`.

Although you could use it as you would any other error class, `JekyllPluginSupport`
provides additional helper methods.
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
    @logger.error e.logger_message
    exit! 1 if @die_on_demo_block_error

    e.html_message
  end
end
```

Error class methods have been provided for standardized and convenient error handling:

* `shorten_backtrace` - most of the lines that spew from a Jekyll backtrace are uninteresting.
* `logger_message` - The message is constructed from the string provided when the error was raised,
   with the page path and line number added.
* `html_message` - The same as `logger_message`, but constructed with HTML.


## Self-Reporting Upon Registration

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


## `no_arg_parsing` Optimization

If your tag or block plugin only needs access to the raw arguments passed from the web page,
without tokenization, and you expect that the plugin might be invoked with large amounts of text,
derive your plugin from `JekyllBlockNoArgParsing` or `JekyllTagNoArgParsing`.

## Writing Plugins

The following minimal examples define `VERSION`,
which is important because `JekyllPluginHelper.register` logs that value when registering the plugin.

This is how you would define plugins in the `_plugins` directory

**Boilerplate for an inline tag plugin**

```ruby
require 'jekyll_plugin_support'

module Jekyll
  class DemoTag < JekyllSupport::JekyllTag
    VERSION = '0.1.0'.freeze

    def render_impl
      @helper.gem_file __FILE__ # Enables attribution; only works when plugin is a gem
      # Your Jekyll plugin logic goes here
    end

    JekyllPluginHelper.register(self, 'demo_tag')
  end
end
```

**Boilerplate for a tag block plugin**

```ruby
require 'jekyll_plugin_support'

module Jekyll
  class DemoBlock < JekyllSupport::JekyllBlock
    VERSION = '0.1.0'.freeze

    def render_impl(text)
      @helper.gem_file __FILE__ # Enables attribution; only works when plugin is a gem
      # Your Jekyll plugin logic goes here
    end

    JekyllPluginHelper.register(self, 'demo_block')
  end
end
```

If your plugin is packaged as a gem, then you might need to include `version.rb` into the plugin class.
For example, if your version module looks like this:

**lib/my_plugin/version.rb**:

```ruby
module MyPluginVersion
  VERSION = '0.5.0'.freeze
end
```

Then your plugin can incorporate the VERSION constant into your plugin like this:

**lib/my_plugin.rb**:

```ruby
require 'jekyll_plugin_support'
require_relative 'my_plugin/version'

module Jekyll
  class MyBlock < JekyllSupport::JekyllBlock
    include MyPluginVersion

    def render_impl(text)
      @helper.gem_file __FILE__ # Enables attribution; only works when plugin is a gem
      # Your code here
    end

    JekyllPluginHelper.register(self, 'demo_block')
  end
end
```

## Attribution

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


### Usage

Typical usage for the `attribution` tag is:

```html
{% my_block_tag attribution %}
  Content of my_block_tag.
{% endmy_block_tag %}
```

The normal processing of `my_block_tag` is augmented by interpolating the attribution format string,
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

## Subclassing Plugins

Jekyll plugins created using `jekyll_plugin_support` are implemented as Ruby classes.
If you would like to create a version of an existing Jekyll plugin, you will need to subclass the plugin.
In order to do that, you will need to override the plugin name and version, which are defined as constants.

`Jekyll_plugin_support` provides a method that allows
a constant to be redefined, called `redef_without_warning`.
Use it in a subclass like this:

```ruby
redef_without_warning :PLUGIN_NAME, 'my_plugin'.freeze
redef_without_warning :VERSION, '0.1.0'.freeze
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

A demo / test website is provided in the [`demo`](demo) directory.
It can be used to debug the plugin or to run freely.

### Examining the Demo Plugins

The following example plugins use
[Ruby’s squiggly heredoc operator](https://ruby-doc.org/core-2.5.0/doc/syntax/literals_rdoc.html#label-Here+Documents) (`<<~`).
The squiggly heredoc operator removes the outermost indentation.
This provides easy-to-read multiline text literals.

**demo/_plugins/demo_tag.rb**:

```ruby
require 'jekyll_plugin_support'

# Use the JekyllSupport module namespace so the self methods are automajically found
module JekyllSupport
  DemoInlineTagError = JekyllSupport.define_error

  class DemoTag < JekyllTag
    VERSION = '0.1.2'.freeze
    # JekyllSupport.redef_without_warning 'VERSION', '0.1.2'.freeze

    def render_impl
      @demo_tag_error = @helper.parameter_specified? 'raise_demo_tag_error'
      @keyword1       = @helper.parameter_specified? 'keyword1'
      @keyword2       = @helper.parameter_specified? 'keyword2'
      @name1          = @helper.parameter_specified? 'name1'
      @name2          = @helper.parameter_specified? 'name2'
      @standard_error = @helper.parameter_specified? 'raise_standard_error'

      if @tag_config
        @die_on_demo_tag_error = @tag_config['die_on_demo_tag_error'] == true
        @die_on_standard_error = @tag_config['die_on_standard_error'] == true
      end

      raise DemoInlineTagError, 'This DemoInlineTagError error is expected.' if @demo_tag_error
      raise StandardError, 'This StandardError error is expected.' if @standard_error

      # _infinity = 1 / 0 if @standard_error # Not required

      output
    rescue DemoInlineTagError => e # jekyll_plugin_support handles StandardError
      @logger.error { e.logger_message }
      exit! 1 if @die_on_demo_tag_error

      e.html_message
    end

    private

    def output
      <<~END_OUTPUT
        <pre># jekyll_plugin_support becomes able to perform variable substitution after this variable is defined.
        # The value could be updated at a later stage, but no need to add that complexity unless there is a use case.
        @argument_string="#{@argument_string}"

        @helper.argv=
          #{@helper.argv&.join("\n  ")}

        # Liquid variable name/value pairs
        @helper.params=
          #{@helper.params&.map { |k, v| "#{k}=#{v}" }&.join("\n  ")}

        # The keys_values property serves no purpose any more, consider it deprecated
        @helper.keys_values=
          #{(@helper.keys_values&.map { |k, v| "#{k}=#{v}" })&.join("\n  ")}

        @layout='#{@layout}'
        @page.keys='#{@page.keys}'

        remaining_markup='#{@helper.remaining_markup}'

        @keyword1='#{@keyword1}'
        @keyword2='#{@keyword2}'
        @name1='#{@name1}'
        @name2='#{@name2}'</pre>
      END_OUTPUT
    end

    JekyllPluginHelper.register(self, 'demo_inline_tag')
  end
end
```

**demo/_plugins/demo_block.rb**:

```ruby
require 'cgi'
require 'jekyll_plugin_support'

# Use the JekyllSupport module namespace so the self methods are automajically found
module JekyllSupport
  DemoBlockError = JekyllSupport.define_error

  class DemoBlock < JekyllBlock
    VERSION = '0.1.2'.freeze

    def render_impl(text)
      @demo_block_error = @helper.parameter_specified? 'raise_demo_block_error'
      @keyword1         = @helper.parameter_specified? 'keyword1'
      @keyword2         = @helper.parameter_specified? 'keyword2'
      @name1            = @helper.parameter_specified? 'name1'
      @name2            = @helper.parameter_specified? 'name2'
      @standard_error   = @helper.parameter_specified? 'raise_standard_error'

      if @tag_config
        @die_on_demo_block_error = @tag_config['die_on_demo_block_error'] == true
        @die_on_standard_error   = @tag_config['die_on_standard_error'] == true
      end

      raise DemoBlockTagError, 'This DemoBlockTagError error is expected.' if @demo_block_error
      raise StandardError, 'This StandardError error is expected.' if @standard_error

      # _infinity = 1 / 0 if @standard_error # Not required

      output text
    rescue DemoBlockTagError => e # jekyll_plugin_support handles StandardError
      @logger.error { e.logger_message }
      exit! 1 if @die_on_demo_block_error

      e.html_message
    end

    private

    def output(text)
      <<~END_OUTPUT
        <pre>@helper.tag_name=#{@helper.tag_name}

        @mode=#{@mode}

        # jekyll_plugin_support becomes able to perform variable substitution after this variable is defined.
        # The value could be updated at a later stage, but no need to add that complexity unless there is a use case.
        @argument_string="#{@argument_string}"

        @helper.argv=
          #{@helper.argv&.join("\n  ")}

        # Liquid variable name/value pairs
        @helper.params=
          #{@helper.params&.map { |k, v| "#{k}=#{v}" }&.join("\n  ")}

        # The keys_values property serves no purpose any more, consider it deprecated
        @helper.keys_values=
          #{(@helper.keys_values&.map { |k, v| "#{k}=#{v}" })&.join("\n  ")}

        @helper.remaining_markup='#{@helper.remaining_markup}'

        @envs=#{@envs.keys.sort.join(', ')}

        @config['url']='#{@config['url']}'

        @site.collection_names=#{@site.collection_names&.sort&.join(', ')}

        @page['description']=#{@page['description']}

        @page['path']=#{@page['path']}

        @keyword1=#{@keyword1}

        @keyword2=#{@keyword2}

        @name1=#{@name1}

        @name2=#{@name2}

        text=#{text}</pre>
      END_OUTPUT
    end

    JekyllPluginHelper.register(self, 'demo_block_tag')
  end
end
```

The following is an example of no_arg_parsing optimization.

```ruby
require 'jekyll_plugin_support'

# Use the JekyllSupport module namespace so the self methods are automajically found
module JekyllSupport
  class DemoTagNoArgs < JekyllTagNoArgParsing
    VERSION = '0.1.0'.freeze

    def render_impl
      <<~END_OUTPUT
        The raw arguments passed to this <code>DemoTagNoArgs</code> instance are:<br>
        <code>#{@argument_string}</code>
      END_OUTPUT
    end

    JekyllPluginHelper.register(self, 'demo_inline_tag_no_arg')
  end
end
```

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

 2. Run the **Debug Demo** lauch configuration.

Alternatively, you can:

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
    run the Visual Studio Code launch configuration called **Attach with rdbg**.

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
