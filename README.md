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

### For a tag:
```ruby
require 'jekyll_plugin_support'

module Jekyll
  class MyTag < JekyllSupport::JekyllTag
    VERSION = '0.1.0'.freeze

    def render_impl
      # Your code here
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

    def render_impl(text)
      # Your code here
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
      # Your code here
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

  - Because `keyword1` was referenced by `@helper.parameter_specified?` above,
    that keyword option is removed from the argument string.
  - Because the `name1` key/value parameter was referenced by `@helper.parameter_specified?` above,
    that name/value pair is removed from the argument string.
  - The remainder of the argument string is now `unreferenced_key unreferenced_name="unreferenced_value"`.

Name/value parameters can be quoted; if the value consists of only one token then it does not need to be quoted.
The following name/value parameters all have the same result:

  - `pay_tuesday="true"`
  - `pay_tuesday='true'`
  - `pay_tuesday=true`
  - `pay_tuesday`

The following also have the same result, however note that because the value has more than one token, quotes must be used:

  - `pay_tuesday="maybe not"`
  - `pay_tuesday='maybe not'`

#### Remaining Markup
After your plugin has parsed all the keyword options and name/value parameters,
call `@helper.remaining_markup` to obtain the remaining markup that was passed to your plugin.


### `no_arg_parsing` Optimization
If your tag or block plugin only needs access to the raw arguments passed from the web page,
without tokenization, and you expect that the plugin might be invoked with large amounts of text,
derive your plugin from `JekyllBlockNoArgParsing` or `JekyllTagNoArgParsing`.


## Attribution
The following public methods are available for the attribution string:

`to_yaml, full_name, conflicts, remote=, dependencies, platform, name=, specification_version, date, summary, authors, autorequire, cert_chain, description, email, extensions, extra_rdoc_files, homepage, licenses, metadata, post_install_message, rdoc_options, required_ruby_version, required_rubygems_version, signing_key, <=>, test_files, ==, relative_loaded_from, rg_full_gem_path, rg_loaded_from, location, load_paths, rg_required_ruby_version=, git_version, rg_extension_dir, nondevelopment_dependencies, to_gemfile, to_spec, deleted_gem?, eql?, removed_method_calls, add_bindir, authors=, email=, license=, metadata=, homepage=, licenses=, author=, platform=, signing_key=, bindir=, activated=, autorequire=, rubygems_version=, require_paths=, original_platform=, add_development_dependency, _deprecated_has_rdoc=, _deprecated_default_executable=, add_runtime_dependency, _deprecated_default_executable, installed_by_version, installed_by_version=, method_missing, required_ruby_version=, _deprecated_validate_permissions, required_rubygems_version=, _deprecated_validate_metadata, _deprecated_validate_dependencies, test_files=, activated, default_executable, default_executable=, _deprecated_has_rdoc, original_platform, _deprecated_has_rdoc?, location=, gems_dir, relative_loaded_from=, source=, to_s, inspect, groups, activated?, activate, name, version, traverse, requirements, has_conflicts?, conficts_when_loaded_with?, bin_file, executables, reset_nil_attributes_to_default, bindir, loaded_from, hash, date=, sort_obj, raise_if_conflicts, activate_dependencies, add_self_to_load_path, runtime_dependencies, files, spec_file, abbreviate, files=, rdoc_options=, extra_rdoc_files=, cert_chain=, sanitize, summary=, sanitize_string, description=, post_install_message=, add_dependency, author, bin_dir, build_args, build_info_file, build_extensions, build_info_dir, cache_dir, cache_file, satisfies_requirement?, _dump, default_value, dependent_gems, dependent_specs, development_dependencies, doc_dir, encode_with, mark_version, executable, executable=, executables=, extensions=, file_name, for_cache, rubygems_version, has_rdoc, has_rdoc=, has_rdoc?, has_unit_tests?, has_test_suite?, init_with, yaml_initialize, version=, lib_files, license, internal_init, missing_extensions?, name_tuple, pretty_print, original_name, require_path, require_path=, requirements=, ri_dir, spec_dir, spec_name, test_file, test_file=, to_ruby, raw_require_paths, source, to_ruby_for_cache, validate, keep_only_files_and_directories, validate_metadata, validate_dependencies, validate_permissions, stubbed?, specification_version=, extension_dir, full_gem_path, remote, base_dir, gem_dir, normalize, match_platform, matches_current_rubygems?, matches_current_ruby?, plugins, source_paths, datadir, lib_dirs_glob, base_dir=, extension_dir=, ignored=, full_gem_path=, require_paths, this, contains_requirable_file?, matches_for_glob, default_gem?, full_require_paths, gem_build_complete_path, loaded_from=, extensions_dir, to_fullpath, to_json, pretty_print_instance_variables, pretty_print_cycle, pretty_print_inspect, singleton_class, dup, itself, taint, tainted?, untaint, untrust, untrusted?, trust, methods, singleton_methods, protected_methods, private_methods, public_methods, instance_variables, instance_variable_get, instance_variable_set, instance_variable_defined?, remove_instance_variable, instance_of?, kind_of?, is_a?, display, public_send, class, frozen?, tap, then, extend, yield_self, clone, method, public_method, singleton_method, ===, define_singleton_method, =~, !~, nil?, respond_to?, freeze, object_id, gem, send, to_enum, enum_for, pretty_inspect, __send__, !, __id__, instance_eval, instance_exec, !=, equal?`

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

    Provides support for writing Jekyll plugins.
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
