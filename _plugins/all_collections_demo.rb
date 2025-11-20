require 'cgi'
require 'jekyll_plugin_logger'

# @author Copyright 2020 Michael Slinn
# @license SPDX-License-Identifier: Apache-2.0
module AllCollectionsDemoModule
  PLUGIN_NAME = 'all_collections_demo'.freeze
  VERSION = '0.3.0'.freeze

  # This tag is just used for 2020-10-03-i-prefer-to-write-jekyll-plugins-instead-of-includes.html
  class AllCollectionsDemo < Liquid::Tag
    # Constructor.
    # @param tag_name [String] is the name of the tag, which we already know.
    # @param command_line [Hash, String, Liquid::Tag::Parser] the arguments from the web page.
    # @param tokens [Liquid::ParseContext] tokenized command line
    # @return [void]
    def initialize(tag_name, command_line, tokens)
      super
      @command_line = command_line.strip
      @logger = PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)
    end

    # Method prescribed by the Jekyll plugin lifecycle.
    # @return [String]
    def render(liquid_context)
      site = liquid_context.registers[:site]
      result = site.everything.map do |entry|
        lines = []
        entry.instance_variables
             .reject { |name| name == :@excerpt }
             .sort
             .each do |name|
          value = entry.instance_variable_get(name).to_s.strip
          lines << "<b>#{name.to_s.delete_prefix '@'}</b>=#{CGI.escapeHTML(value)}\n"
        end
        "<pre>#{lines.join}</pre>\n"
      end
      result.join("<br>\n")
    end
  end
end

Liquid::Template.register_tag(AllCollectionsDemoModule::PLUGIN_NAME, AllCollectionsDemoModule::AllCollectionsDemo)
PluginMetaLogger.instance.info { "Loaded #{AllCollectionsDemoModule::PLUGIN_NAME} v#{AllCollectionsDemoModule::VERSION} tag plugin." }
