require 'jekyll'
require 'jekyll_plugin_logger'
require_relative 'jekyll_plugin_helper'
require_relative 'jekyll_plugin_support/version'

# @author Copyright 2022 Michael Slinn
# @license SPDX-License-Identifier: Apache-2.0``
module NoArgParsing
  attr_accessor :no_arg_parsing

  @no_arg_parsing = true
end

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
      @argument_string = argument_string
      @logger = PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)
      @logger.debug { "#{self.class}: respond_to?(:no_arg_parsing) #{respond_to?(:no_arg_parsing) ? 'yes' : 'no'}." }
      @helper = JekyllPluginHelper.new(tag_name, argument_string, @logger, respond_to?(:no_arg_parsing))
    end

    # Method prescribed by the Jekyll plugin lifecycle.
    # @return [String]
    def render(liquid_context)
      text = super
      @helper.liquid_context = liquid_context

      @page = liquid_context.registers[:page] # Type Jekyll::Drops::DocumentDrop
      @site = liquid_context.registers[:site]
      @config = @site.config
      @envs = liquid_context.environments.first
      @mode = @config['env']['JEKYLL_ENV'] || 'development'

      render_impl text
    rescue StandardError => e
      @logger.error { "#{self.class} died with a #{e.message}" }
      # raise SystemExit, 3, []
      e.set_backtrace []
      raise e
    end

    # Jekyll plugins should override this method, not render, so their plugin can be tested more easily
    # @page and @site are available
    # @return [String]
    def render_impl(text)
      text
    end
  end

  class JekyllBlockNoArgParsing < JekyllBlock
    def initialize(tag_name, argument_string, parse_context)
      class << self
        include NoArgParsing
      end

      super
      @logger.debug { "#{self.class}: respond_to?(:o_arg_parsing) #{respond_to?(:no_arg_parsing) ? 'yes' : 'no'}." }
    rescue StandardError => e
      @logger.error { "#{self.class} died with a #{e.message}" }
      exit 2
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
      @argument_string = argument_string
      @logger = PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)
      @logger.debug { "#{self.class}: respond_to?(:no_arg_parsing) #{respond_to?(:no_arg_parsing) ? 'yes' : 'no'}." }
      @helper = JekyllPluginHelper.new(tag_name, argument_string, @logger, respond_to?(:no_arg_parsing))
    end

    # Method prescribed by the Jekyll plugin lifecycle.
    def render(liquid_context)
      @helper.liquid_context = liquid_context

      @envs      = liquid_context.environments.first

      @layout    = @envs[:layout]
      @paginator = @envs[:paginator]
      @theme     = @envs[:theme]

      @page      = liquid_context.registers[:page]
      @site      = liquid_context.registers[:site]

      @config = @site.config
      @mode = @config['env']['JEKYLL_ENV'] || 'development'

      render_impl
    rescue StandardError => e
      @logger.error { "#{self.class} died with a #{e.message}" }
      exit 3
    end

    # Jekyll plugins must override this method, not render, so their plugin can be tested more easily
    # @page and @site are available
    def render_impl
      abort "#{self.class}.render_impl for tag #{@tag_name} must be overridden, but it was not."
    end
  end

  class JekyllTagNoArgParsing < JekyllTag
    def initialize(tag_name, argument_string, parse_context)
      class << self
        include NoArgParsing
      end

      super
      @logger.debug { "#{self.class}: respond_to?(:no_arg_parsing) #{respond_to?(:no_arg_parsing) ? 'yes' : 'no'}." }
    end
  end
end
