require 'jekyll_plugin_logger'
require 'rspec/match_ignoring_whitespace'
require_relative '../lib/jekyll_plugin_support'
require_relative '../lib/jekyll_plugin_support_spec_support'

class JekyllPluginHelperCallTest
  RSpec.describe JekyllPluginHelper do
    it 'might not return jpsh_subclass_caller value' do
      jpsh_subclass_caller = CallChain.jpsh_subclass_caller
      expect(jpsh_subclass_caller).to be_nil
    end

    it 'asf' do
      logger = PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)
      jph = described_class.new('my_tag', 'attribution', logger, false)
      actual = jph.jpsh_subclass_caller
      expected = [__FILE__, 15, 'new'] # The 2nd element value depends on the line # of two lines up
      expect(actual).to match_array(expected)
    end
  end
end
