require 'jekyll_plugin_logger'
# require 'rspec/match_ignoring_whitespace'
require_relative '../lib/jekyll_plugin_support'
require_relative '../lib/jekyll_plugin_support_spec_support'

# Lets get this party started
class MyTest
  RSpec.describe JekyllSupport::JekyllTag do
    let(:logger) do
      PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)
    end

    let(:parse_context) { TestParseContext.new }

    # Example for plugin authors to refer to:
    #
    # let(:helper) do
    #   JekyllTagHelper.new(
    #     'quote',
    #     "cite='This is a citation' url='https://blah.com' This is the quoted text.",
    #     logger
    #   )
    # end
    #
    # fit 'is created properly' do
    #   command_line = "cite='This is a citation' url='https://blah.com' This is the quoted text.".dup
    #   quote = Jekyll::Quote.send(
    #     :new,
    #     'quote',
    #     command_line,
    #     parse_context
    #   )
    #   result = quote.send(:render_impl, command_line)
    #   expect(result).to match_ignoring_whitespace <<-END_RESULT
    #     <div class='quote'>
    #       This is the quoted text.
    #     </div>
    #   END_RESULT
    # end
  end
end
