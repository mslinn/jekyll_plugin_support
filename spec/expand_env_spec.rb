require 'spec_helper'
require_relative '../lib/jekyll_plugin_support'

RSpec.describe(Obj) do
  it 'Expands bash environment variables' do
    actual = JekyllSupport::JekyllPluginHelper.expand_env '$HOME'
    expect(actual).to eq(Dir.home)

    actual = JekyllSupport::JekyllPluginHelper.expand_env '$HOME/abc'
    expect(actual).to eq("#{Dir.home}/abc")

    actual = JekyllSupport::JekyllPluginHelper.expand_env 'abc/$HOME/def'
    expect(actual).to eq("abc/#{Dir.home}/def")

    actual = JekyllSupport::JekyllPluginHelper.expand_env 'abc/$HOME/def'
    expect(actual).to eq("abc/#{Dir.home}/def")

    actual = JekyllSupport::JekyllPluginHelper.expand_env 'abc/$HOME/def/$UID'
    expect(actual).to eq("abc/#{Dir.home}/def/#{ENV.fetch('UID', nil)}")
  end
end
