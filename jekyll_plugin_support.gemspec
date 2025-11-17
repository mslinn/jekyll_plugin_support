require_relative 'lib/jekyll_plugin_support/version'

Gem::Specification.new do |spec|
  github = 'https://github.com/mslinn/jekyll_plugin_support'

  spec.bindir   = 'exe'
  spec.authors  = ['Mike Slinn']
  spec.email    = ['mslinn@mslinn.com']
  spec.files    = Dir['.rubocop.yml', 'LICENSE.*', 'Rakefile', '{lib,spec}/**/*', '*.gemspec', '*.md']
  spec.homepage = 'https://www.mslinn.com/jekyll_plugins/jekyll_plugin_support.html'
  spec.license  = 'MIT'
  spec.metadata = {
    'allowed_push_host' => 'https://rubygems.org',
    'bug_tracker_uri'   => "#{github}/issues",
    'changelog_uri'     => "#{github}/CHANGELOG.md",
    'homepage_uri'      => spec.homepage,
    'source_code_uri'   => github,
  }
  spec.name                 = 'jekyll_plugin_support'
  spec.platform             = Gem::Platform::RUBY
  spec.post_install_message = <<~END_MESSAGE

    Thanks for installing #{spec.name}!

  END_MESSAGE
  spec.require_paths         = ['lib']
  spec.required_ruby_version = '>= 3.4.0'
  spec.summary               = 'Provides a framework for writing and testing Jekyll plugins'
  spec.test_files            = spec.files.grep %r{^(test|spec|features)/}
  spec.version               = JekyllPluginSupportVersion::VERSION

  spec.add_dependency 'bigdecimal'
  spec.add_dependency 'facets'
  spec.add_dependency 'jekyll', '>= 4.4.1'
  spec.add_dependency 'jekyll_plugin_logger'
  spec.add_dependency 'key-value-parser'
  spec.add_dependency 'pry'
  spec.add_dependency 'sorted_set'
end
