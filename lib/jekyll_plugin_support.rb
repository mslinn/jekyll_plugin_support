require 'jekyll'
require 'jekyll_plugin_logger'
require_relative 'jekyll_plugin_support_helper'
require_relative 'jekyll_plugin_support/version'

# @author Copyright 2022 Michael Slinn
# @license SPDX-License-Identifier: Apache-2.0``
module JekyllSupport
  # Base class for Jekyll block tags
  class JekyllBlock < Liquid::Block
    attr_reader :argument_string, :helper, :line_number, :logger, :page, :site, :text

    # See https://github.com/Shopify/liquid/wiki/Liquid-for-Programmers#create-your-own-tags
    # @param tag_name [String] the name of the tag, which we usually know.
    # @param argument_string [String] the arguments passed to the tag, as a single string.
    # @param parse_context [Liquid::ParseContext] hash that stores Liquid options.
    #        By default it has two keys: :locale and :line_numbers, the first is a Liquid::I18n object, and the second,
    #        a boolean parameter that determines if error messages should display the line number the error occurred.
    #        This argument is used mostly to display localized error messages on Liquid built-in Tags and Filters.
    #        See https://github.com/Shopify/liquid/wiki/Liquid-for-Programmers#create-your-own-tags
    # @return [void]
    def initialize(tag_name, argument_string, parse_context)
      super
      @tag_name = tag_name
      @logger = PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)
      @helper = JekyllPluginHelper.new(tag_name, argument_string, @logger)
      @argument_string = argument_string
    end

    # Method prescribed by the Jekyll plugin lifecycle.
    # @return [String]
    def render(liquid_context)
      text = super
      @liquid_context = liquid_context

      # The names of front matter variables are hash keys for @page
      @page = liquid_context.registers[:page] # Jekyll::Drops::DocumentDrop
      @site = liquid_context.registers[:site]
      @config = @site.config
      @envs = liquid_context.environments.first
      @mode = @config['env']['JEKYLL_ENV'] || 'development'

      render_impl text
    end

    # Jekyll plugins should override this method, not render, so their plugin can be tested more easily
    # @page and @site are available
    # @return [String]
    def render_impl(text)
      text
    end
  end

  # Base class for Jekyll tags
  class JekyllTag < Liquid::Tag
    attr_reader :argument_string, :helper, :line_number, :logger, :page, :site

    # See https://github.com/Shopify/liquid/wiki/Liquid-for-Programmers#create-your-own-tags
    # @param tag_name [String] the name of the tag, which we usually know.
    # @param argument_string [String] the arguments passed to the tag, as a single string.
    # @param parse_context [Liquid::ParseContext] hash that stores Liquid options.
    #        By default it has two keys: :locale and :line_numbers, the first is a Liquid::I18n object, and the second,
    #        a boolean parameter that determines if error messages should display the line number the error occurred.
    #        This argument is used mostly to display localized error messages on Liquid built-in Tags and Filters.
    #        See https://github.com/Shopify/liquid/wiki/Liquid-for-Programmers#create-your-own-tags
    # @return [void]
    def initialize(tag_name, argument_string, parse_context)
      super
      @tag_name = tag_name
      @logger = PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)
      @helper = JekyllPluginHelper.new(tag_name, argument_string, @logger)
      @argument_string = argument_string
    end

    # Method prescribed by the Jekyll plugin lifecycle.
    def render(liquid_context)
      @page = liquid_context.registers[:page]
      @site = liquid_context.registers[:site]
      render_impl
    end

    # Jekyll plugins must override this method, not render, so their plugin can be tested more easily
    # @page and @site are available
    def render_impl
      abort "JekyllTag render_impl for tag #{@tag_name} must be overridden, but it was not."
    end
  end
end
