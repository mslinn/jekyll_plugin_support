require 'spec_helper'
require_relative '../lib/jekyll_plugin_support'

ENV['SystemDrive'] = 'C:'
ENV['os'] = 'Windows_NT'

RSpec.describe('Bash and Windows environment variables') do # rubocop:disable RSpec/DescribeClass
  it 'Expands bash environment variables only (no Windows expansion in expand_env)' do
    actual = JekyllSupport::JekyllPluginHelper.expand_env '$HOME'
    expect(actual).to eq(Dir.home)

    actual = JekyllSupport::JekyllPluginHelper.expand_env '$HOME/abc'
    expect(actual).to eq("#{Dir.home}/abc")

    actual = JekyllSupport::JekyllPluginHelper.expand_env 'abc/$HOME/def'
    expect(actual).to eq("abc/#{Dir.home}/def")

    actual = JekyllSupport::JekyllPluginHelper.expand_env 'abc/$HOME/def'
    expect(actual).to eq("abc/#{Dir.home}/def")

    actual = JekyllSupport::JekyllPluginHelper.expand_env 'abc/$HOME/def/$HOST'
    expect(actual).to eq("abc/#{Dir.home}/def/#{ENV.fetch('HOST', nil)}")
  end

  it 'Does NOT expand Windows environment variables in expand_env (only Bash)' do
    # Windows environment variables should NOT be expanded by expand_env
    actual = JekyllSupport::JekyllPluginHelper.expand_env '%SystemDrive%'
    expect(actual).to eq('%SystemDrive%') # Should remain unchanged

    actual = JekyllSupport::JekyllPluginHelper.expand_env '%SystemDrive%/abc'
    expect(actual).to eq('%SystemDrive%/abc') # Should remain unchanged

    actual = JekyllSupport::JekyllPluginHelper.expand_env 'abc/%SystemDrive%/def'
    expect(actual).to eq('abc/%SystemDrive%/def') # Should remain unchanged

    actual = JekyllSupport::JekyllPluginHelper.expand_env 'abc/%SystemDrive%/def/%os%'
    expect(actual).to eq('abc/%SystemDrive%/def/%os%') # Should remain unchanged
  end

  it 'expands Windows environment variables when env_var_expand_windows is called directly' do
    actual = JekyllSupport::JekyllPluginHelper.env_var_expand_windows '%SystemDrive%'
    expect(actual).to eq('C:')

    actual = JekyllSupport::JekyllPluginHelper.env_var_expand_windows '%SystemDrive%/abc'
    expect(actual).to eq('C:/abc')

    actual = JekyllSupport::JekyllPluginHelper.env_var_expand_windows 'abc/%SystemDrive%/def'
    expect(actual).to eq('abc/C:/def')

    actual = JekyllSupport::JekyllPluginHelper.env_var_expand_windows 'abc/%SystemDrive%/def/%os%'
    expect(actual).to eq('abc/C:/def/Windows_NT')
  end

  it 'expands Windows environment variables when env_var_expand_windows is called directly with use_wslvar: false' do
    actual = JekyllSupport::JekyllPluginHelper.env_var_expand_windows '%SystemDrive%', use_wslvar: false
    expect(actual).to eq('C:')

    actual = JekyllSupport::JekyllPluginHelper.env_var_expand_windows '%SystemDrive%/abc', use_wslvar: false
    expect(actual).to eq('C:/abc')

    actual = JekyllSupport::JekyllPluginHelper.env_var_expand_windows 'abc/%SystemDrive%/def', use_wslvar: false
    expect(actual).to eq('abc/C:/def')

    actual = JekyllSupport::JekyllPluginHelper.env_var_expand_windows 'abc/%SystemDrive%/def/%os%', use_wslvar: false
    expect(actual).to eq('abc/C:/def/Windows_NT')
  end
end
