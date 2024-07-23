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
