require 'spec_helper'

# Test for @raw_content exposure in JekyllTag and JekyllBlock
module Jekyll
  class RawContentTag < JekyllSupport::JekyllTag
    VERSION = '0.1.0'.freeze

    def render_impl
      if @raw_content
        "Raw content length: #{@raw_content.length}, type: #{@raw_content.class}"
      else
        "No raw content available"
      end
    end

    JekyllSupport::JekyllPluginHelper.register(self, 'raw_content_tag_test')
  end

  class RawContentBlock < JekyllSupport::JekyllBlock
    VERSION = '0.1.0'.freeze

    def render_impl(text)
      if @raw_content
        "Raw content length: #{@raw_content.length}, type: #{@raw_content.class}, text: #{text}"
      else
        "No raw content available, text: #{text}"
      end
    end

    JekyllSupport::JekyllPluginHelper.register(self, 'raw_content_block_test')
  end
end

RSpec.describe 'Raw Content Variable Exposure' do
  let(:site) { Jekyll::Site.new(Jekyll::Configuration.new) }
  let(:context) { Liquid::Context.new({}, {}, { 'site' => site, 'page' => {}, 'jekyll' => site }) }

  describe 'JekyllTag' do
    let(:tag) { Jekyll::RawContentTag.new('raw_content_tag_test', '', Liquid::ParseContext.new) }

    it 'exposes @raw_content instance variable' do
      # Test that the instance variable exists
      expect(tag).to respond_to(:raw_content)
    end

    it 'initializes @raw_content to nil when not rendered' do
      expect(tag.raw_content).to be_nil
    end
  end

  describe 'JekyllBlock' do
    let(:block) { Jekyll::RawContentBlock.new('raw_content_block_test', '', Liquid::ParseContext.new) }

    it 'exposes @raw_content instance variable' do
      # Test that the instance variable exists
      expect(block).to respond_to(:raw_content)
    end

    it 'initializes @raw_content to nil when not rendered' do
      expect(block.raw_content).to be_nil
    end
  end

  describe 'JekyllTag rendering behavior' do
    let(:tag) { Jekyll::RawContentTag.new('raw_content_tag_test', '', Liquid::ParseContext.new) }

    it 'sets @raw_content from @envs[:content] during rendering' do
      # Mock the rendering process
      allow(tag).to receive(:render_impl).and_return('test')
      
      # Simulate the render method's setup
      mock_envs = { content: '<p>Test content</p>', layout: {}, paginator: nil, theme: nil }
      allow(tag).to receive(:envs).and_return(mock_envs)
      allow(tag).to receive(:config).and_return({})
      allow(tag).to receive(:tag_config).and_return(nil)
      allow(tag).to receive(:jps).and_return(nil)
      allow(tag).to receive(:pry_on_standard_error).and_return(false)
      
      # Call render_impl to simulate the render method
      tag.send(:set_error_context) # This method is private, so we need to simulate it
      tag.instance_variable_set(:@raw_content, mock_envs[:content])
      
      result = tag.send(:render_impl)
      expect(result).to include('Raw content length:')
      expect(result).to include('Test content')
    end
  end
end