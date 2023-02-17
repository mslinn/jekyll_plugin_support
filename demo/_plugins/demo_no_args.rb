require 'jekyll_plugin_support'

module Jekyll
  class DemoTagNoArgs < JekyllSupport::JekyllTagNoArgParsing
    VERSION = '0.1.0'.freeze

    def render_impl
      <<~END_OUTPUT
        The raw arguments passed to this DemoTagNoArgs instance are:
        '#{@argument_string}'
      END_OUTPUT
    end

    JekyllPluginHelper.register(self, 'demo_tag_no_arg')
  end
end
