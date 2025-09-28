require 'spec_helper'
require_relative '../lib/jekyll_plugin_support'

ENV['SystemDrive'] = 'C:'
ENV['os'] = 'Windows_NT'

RSpec.describe('Bash and Windows environment variables') do # rubocop:disable RSpec/DescribeClass
  it 'Expands bash environment variables' do
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

  it 'Expands Windows environment variables' do
    actual = JekyllSupport::JekyllPluginHelper.expand_env '%SystemDrive%'
    expect(actual).to eq('C:')

    actual = JekyllSupport::JekyllPluginHelper.expand_env '%SystemDrive%/abc'
    expect(actual).to eq('C:/abc')

    actual = JekyllSupport::JekyllPluginHelper.expand_env 'abc/%SystemDrive%/def'
    expect(actual).to eq('abc/C:/def')

    actual = JekyllSupport::JekyllPluginHelper.expand_env 'abc/%SystemDrive%/def'
    expect(actual).to eq('abc/C:/def')

    actual = JekyllSupport::JekyllPluginHelper.expand_env 'abc/%SystemDrive%/def/%os%'
    expect(actual).to eq('abc/C:/def/Windows_NT')
  end

  it 'Expands Linux environment variables instead of Windows environment variables' do
    actual = JekyllSupport::JekyllPluginHelper.expand_env '%SystemDrive%', use_wslvar: false
    expect(actual).to eq('C:')

    actual = JekyllSupport::JekyllPluginHelper.expand_env '%SystemDrive%/abc', use_wslvar: false
    expect(actual).to eq('C:/abc')

    actual = JekyllSupport::JekyllPluginHelper.expand_env 'abc/%SystemDrive%/def', use_wslvar: false
    expect(actual).to eq('abc/C:/def')

    actual = JekyllSupport::JekyllPluginHelper.expand_env 'abc/%SystemDrive%/def', use_wslvar: false
    expect(actual).to eq('abc/C:/def')

    actual = JekyllSupport::JekyllPluginHelper.expand_env 'abc/%SystemDrive%/def/%os%', use_wslvar: false
    expect(actual).to eq('abc/C:/def/Windows_NT')
  end
end
