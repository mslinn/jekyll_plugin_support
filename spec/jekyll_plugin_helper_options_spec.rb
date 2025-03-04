require 'jekyll_plugin_logger'
# require 'rspec/match_ignoring_whitespace'
require_relative '../lib/jekyll_plugin_support'
require_relative '../lib/jekyll_plugin_support/jekyll_plugin_support_spec_support'

class JekyllPluginHelperOptionsTest
  RSpec.describe ::JekyllSupport::JekyllPluginHelper do
    logger = PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)

    it 'parses quoted string options' do
      helper = described_class.new('my_tag', "colors='blue or green' blah ick", logger, false)
      helper.reinitialize helper.argument_string
      expect(helper.keys_values.keys).to eq(%w[colors blah ick])

      colors = helper.parameter_specified? 'colors'
      expect(colors).to eq('blue or green')

      expect(helper.keys_values.keys).to eq(%w[blah ick])
    end

    it 'parses unquoted string options' do
      helper = described_class.new('my_tag', 'color=blue blah ick', logger, false)
      expect(helper.keys_values.keys).to eq(%w[color blah ick])

      color = helper.parameter_specified? 'color'
      expect(color).to eq('blue')

      expect(helper.keys_values.keys).to eq(%w[blah ick])
    end

    it 'parses quoted booleans' do
      helper = described_class.new('my_tag', "bool1='true' bool2='false' blah ick", logger, false)
      expect(helper.keys_values.keys).to eq(%w[bool1 bool2 blah ick])

      bool1 = helper.parameter_specified? 'bool1'
      expect(bool1).to be true

      bool2 = helper.parameter_specified? 'bool2'
      expect(bool2).to be false

      expect(helper.keys_values.keys).to eq(%w[blah ick])

      expect(helper.remaining_markup).to eq('blah ick')
    end

    it 'parses unquoted booleans' do
      helper = described_class.new('my_tag', 'bool1=true bool2=false blah ick', logger, false)
      expect(helper.keys_values.keys).to eq(%w[bool1 bool2 blah ick])

      bool1 = helper.parameter_specified? 'bool1'
      expect(bool1).to be true

      bool2 = helper.parameter_specified? 'bool2'
      expect(bool2).to be false

      expect(helper.keys_values.keys).to eq(%w[blah ick])

      expect(helper.remaining_markup).to eq('blah ick')
    end
  end
end
