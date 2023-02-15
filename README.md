`jekyll_plugin_support`
[![Gem Version](https://badge.fury.io/rb/jekyll_plugin_support.svg)](https://badge.fury.io/rb/jekyll_plugin_support)
===========

`Jekyll_plugin_support` is a Ruby gem that facilitates writing and testing Jekyll plugins.
At present, only Jekyll tags and blocks are supported.

## Installation

Add this line to your Jekyll plugin's Gemfile:

```ruby
group :jekyll_plugins do
  gem 'jekyll_plugin_support'
end
```

And then execute:

    $ bundle install

## Usage
`JekyllSupport::JekyllBlock` and `JekyllSupport::JekyllTag`
provide support for Jekyll tag blocks and Jekyll tags, respectively.
They are very similar in construction and usage.

Instead of subclassing your Jekyll block tag class from `Liquid::Block`,
subclass from `JekyllSupport::JekyllBlock` instead.
Similarly, instead of subclassing your Jekyll tag class from `Liquid::Tag`,
subclass from `JekyllSupport::JekyllTag` instead.

Both `JekyllSupport` classes instantiate new instances of
[`PluginMetaLogger`](https://github.com/mslinn/jekyll_plugin_logger) (called `@logger`) and
[`JekyllPluginHelper`](lib/jekyll_plugin_support_helper.rb) (called `@helper`).

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

```ruby
# For a tag:
module Jekyll
  class Quote < JekyllSupport::JekyllTag
    VERSION = '0.1.0'

    def render_impl
      # Your code here
    end
  end
end
```

```ruby
# For a tag block:
module Jekyll
  class Quote < JekyllSupport::JekyllBlock
    VERSION = '0.1.0'

    def render_impl(text)
      # Your code here
    end
  end
end
```

Note that each tag or tag block must define a constant called `VERSION`.
If your plugin is packaged as a gem, then you might need to include `version.rb` into the plugin class:

```ruby
include 'my_plugin/version'
```

## Additional Information
More information is available on
[Mike Slinn&rsquo;s website](https://www.mslinn.com/blog/2020/10/03/jekyll-plugins.html).


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

    Generates Jekyll logger with colored output.
```


## Test
A test website is provided in the `demo` directory.
 1. Set breakpoints.

 2. Initiate a debug session from the command line:
    ```shell
    $ bin/attach demo
    ```

  3. Once the `Fast Debugger` signon appears, launch the Visual Studio Code launch configuration called `Attach rdebug-ide`.

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
