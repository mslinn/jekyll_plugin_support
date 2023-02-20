require 'jekyll_plugin_logger'
require 'rspec/match_ignoring_whitespace'
require_relative '../lib/jekyll_plugin_support'
require_relative '../lib/jekyll_plugin_support_spec_support'

class MyTest
  RSpec.describe JekyllSupport::JekyllBlock do
    it 'has a bogus test' do
      result = "<div class='quote'> This is the quoted text. </div>".dup
      expect(result).to match_ignoring_whitespace <<~END_RESULT
        <div class='quote'>
          This is the quoted text.
        </div>
      END_RESULT
    end
  end
end
