require 'jekyll_plugin_logger'
require 'rspec/match_ignoring_whitespace'
require_relative '../lib/jekyll_plugin_support'
require_relative '../lib/jekyll_plugin_support_spec_support'

class MyTest
  RSpec.describe JekyllPluginHelper do
    logger = PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)

    it 'parses string options' do
      helper = described_class.new('my_tag', "color='blue' blah ick", logger, false)
      _x = helper.keys_values.keys
      expect(helper.keys_values.keys).to eq(%w[color blah ick])

      color = helper.parameter_specified? 'color'
      expect(color).to eq('blue')

      expect(helper.keys_values.keys).to eq(%w[blah ick])
    end

    it 'parses booleans' do
      helper = described_class.new('my_tag', "bool='true' blah ick", logger, false)
      expect(helper.keys_values.keys).to eq(%w[bool blah ick])

      bool = helper.parameter_specified? 'bool'
      expect(bool).to be true

      expect(helper.keys_values.keys).to eq(%w[blah ick])
    end
  end
end
