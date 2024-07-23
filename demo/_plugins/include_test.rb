require 'cgi'
require 'jekyll_plugin_support'

# Use the JekyllSupport module namespace so the self methods are automajically found
module JekyllSupport
  class IncludeTestTag < JekyllTag
    VERSION = '0.1.2'.freeze

    def render_impl
      str = @scopes.map { |scope| show_scope scope }.join
      "include_test_plugin: scopes=#{@scopes}#{str}".strip
    end

    private

    def show_scope(scope)
      scope.map { |k, v| "<br>  #{k}=#{v}" }.join
    end

    JekyllPluginHelper.register(self, 'include_test_plugin')
  end
end
