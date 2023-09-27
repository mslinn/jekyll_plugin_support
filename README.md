# `jekyll_plugin_support` [![Gem Version](https://badge.fury.io/rb/jekyll_plugin_support.svg)](https://badge.fury.io/rb/jekyll_plugin_support)

`Jekyll_plugin_support` is a Ruby gem that facilitates writing and testing Jekyll plugins.
At present, only Jekyll tags and blocks are supported.


## Installation

`Jekyll_plugin_support` can be used to create simple Jekyll plugins in the `_plugins/` directory, or gem-based Jekyll plugins.

### Simple Plugins

For jekyll plugins defined in the `_plugins/` directory,
add this line to your Jekyll plugin's `Gemfile`:

```ruby
group :jekyll_plugins do
  gem 'jekyll_plugin_support'
end
```

And then execute:

```shell
$ bundle
```


### Gem-Based Plugins

Add this line to your Jekyll plugin's `.gemspec`:

```ruby
spec.add_dependency 'jekyll_plugin_support'
```

And then execute:

```shell
$ bundle
```


## General Usage

`JekyllSupport::JekyllBlock` and `JekyllSupport::JekyllTag`
provide support for Jekyll tag blocks and Jekyll tags, respectively.
They are very similar in construction and usage.

Instead of subclassing your Jekyll block tag class from `Liquid::Block`,
subclass from `JekyllSupport::JekyllBlock` instead.

Similarly, instead of subclassing your Jekyll tag class from `Liquid::Tag`,
subclass from `JekyllSupport::JekyllTag` instead.

Both `JekyllSupport` classes instantiate new instances of
[`PluginMetaLogger`](https://github.com/mslinn/jekyll_plugin_logger) (called `@logger`) and
[`JekyllPluginHelper`](lib/jekyll_plugin_helper.rb) (called `@helper`).

`JekyllPluginHelper` defines a generic `initialize` method,
and your tag or block tag class should not override it.
Also, your tag or block tag class should not define a method called `render`,
because `JekyllBlock.initialize` defines one, which creates variables called
[`@page`](https://jekyllrb.com/docs/variables/#page-variables) and
[`@site`](https://jekyllrb.com/docs/variables/#site-variables).

Instead, define a method called `render_impl`.
For tags, `render_impl` does not accept any parameters.
For block tags, a single parameter is required, which contains any text enclosed within your block.

Your implementation of `render_impl` can access `@page` and `@site`,
and can parse parameters passed to the tag / block tag, [as described here](https://mslinn.com/jekyll/10100-jekyll-plugin-background.html#params):

### For a tag:

```ruby
require 'jekyll_plugin_support'

module Jekyll
  class MyTag < JekyllSupport::JekyllTag
    VERSION = '0.1.0'.freeze

    def render_impl
      my_output = "<p>blah blah</p>"
      <<~END_OUTPUT
        #{my_output}
      END_OUTPUT
    end

    JekyllPluginHelper.register(self, 'demo_tag')
  end
end
```

### For a tag block:

```ruby
require 'jekyll_plugin_support'

module Jekyll
  class MyBlock < JekyllSupport::JekyllBlock
    VERSION = '0.1.0'.freeze

    def render_impl(content)
      @helper.gem_file __FILE__ # Enables attribution
      my_output = "<p>blah blah</p>"
      <<~END_OUTPUT
        #{my_output}
        #{@helper.attribute if @helper.attribution}
      END_OUTPUT
    end

    JekyllPluginHelper.register(self, 'demo_block')
  end
end
```

Note that each tag or tag block must define a constant called `VERSION`.
If your plugin is packaged as a gem, then you might need to include `version.rb` into the plugin class.
For example, if `lib/my_plugin/version.rb` looks like this:

```ruby
module MyPluginVersion
  VERSION = '0.5.1'.freeze
end
```

Then your plugin can incorporate the `VERSION` constant into your plugin like this:

```ruby
require 'jekyll_plugin_support'
require_relative 'my_block/version'

module Jekyll
  class MyBlock < JekyllSupport::JekyllBlock
    include MyPluginVersion

    def render_impl(text)
      @helper.gem_file __FILE__ # Enables attribution
      my_output = "<p>blah blah</p>"
      <<~END_OUTPUT
        #{my_output}
        #{@helper.attribute if @helper.attribution}
      END_OUTPUT
    end

    JekyllPluginHelper.register(self, 'demo_tag')
  end
end
```

### Argument Parsing

Tag arguments can be obtained within `render_impl`.
Both keyword options and name/value parameters are supported.

Both `JekyllTag` and `JekyllBlock` use the standard Ruby mechanism for parsing command-line options:
[`shellwords`](https://ruby-doc.org/stdlib-2.5.1/libdoc/shellwords/rdoc/Shellwords.html) and
[`key_value_parser`](https://www.rubydoc.info/gems/key-value-parser).

All your code has to do is to specify the keywords to search for in the string passed from the HTML page that your tag is embedded in.
The included `demo` website has examples; both [`demo/_plugins/demo_tag.rb`](demo/_plugins/demo_tag.rb) and
[`demo/_plugins/demo_block.rb`](demo/_plugins/demo_block.rb) contain the following:

```ruby
@keyword1  = @helper.parameter_specified? 'keyword1'
@keyword2  = @helper.parameter_specified? 'keyword2'
@name1  = @helper.parameter_specified? 'name1'
@name2  = @helper.parameter_specified? 'name2'
```

In [`demo/index.html`](demo/index.html), the following invoked the tag:

```html
{% demo_tag keyword1 name1='value1' unreferenced_key unreferenced_name="unreferenced_value" %}
```

The `demo/_plugins/demo_tag.rb` plugin uses `@helper.parameter_specified?` provided by
`jekyll_support_plugin` to parse the string passed to the tag, which is
`keyword1 name1='value1' unreferenced_key unreferenced_name="unreferenced_value"`.

* Because `keyword1` was referenced by `@helper.parameter_specified?` above,
    that keyword option is removed from the argument string.
* Because the `name1` key/value parameter was referenced by `@helper.parameter_specified?` above,
    that name/value pair is removed from the argument string.
* The remainder of the argument string is now `unreferenced_key unreferenced_name="unreferenced_value"`.

Name/value parameters can be quoted; if the value consists of only one token then it does not need to be quoted.
The following name/value parameters all have the same result:

* `pay_tuesday="true"`
* `pay_tuesday='true'`
* `pay_tuesday=true`
* `pay_tuesday`

The following also have the same result, however note that because the value has more than one token, quotes must be used:

* `pay_tuesday="maybe not"`
* `pay_tuesday='maybe not'`

#### Remaining Markup

After your plugin has parsed all the keyword options and name/value parameters,
call `@helper.remaining_markup` to obtain the remaining markup that was passed to your plugin.


### `no_arg_parsing` Optimization

If your tag or block plugin only needs access to the raw arguments passed from the web page,
without tokenization, and you expect that the plugin might be invoked with large amounts of text,
derive your plugin from `JekyllBlockNoArgParsing` or `JekyllTagNoArgParsing`.


## Subclass Attribution

`JekyllTag` and `JekyllBlock` subclasses of `jekyll_plugin_support` can utilize the `attribution` option IFF they are published as a gem.
`JekyllTagNoArgParsing` and `JekyllBlockNoArgParsing` subclasses cannot.

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
{% my_tag attribution %}
```

Normal processing of `my_tag` is augmented by interpolating the attribution format string,
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


## Additional Information

More information is available on
[Mike Slinn&rsquo;s website](https://www.mslinn.com/jekyll_plugins/jekyll_plugin_support.html).


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

 2. View the generated website at [`http://localhost:4444`](http://localhost:4444)

### Plugin Debugging

 1. Set breakpoints in Visual Studio Code.

 2. Initiate a debug session from the command line:

    ```shell
    $ demo/_bin/debug
    ```

 3. Once the `Fast Debugger` signon appears, launch the Visual Studio Code launch
     configuration called `Attach with rdbg`.

 4. View the generated website at [`http://localhost:4444`](http://localhost:4444)


### Build and Push to RubyGems

To release a new version,

  1. Update the version number in `version.rb`.
  2. Commit all changes to git; if you don't the next step might fail with an unexplainable error message.
  3. Run the following:

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
