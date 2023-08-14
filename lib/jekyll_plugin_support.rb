require 'colorator'
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
  DISPLAYED_CALLS = 8

  def self.error_short_trace(logger, error)
    remaining = e.backtrace.length - DISPLAYED_CALLS
    logger.error do
      error.message + "\n" + # rubocop:disable Style/StringConcatenation
        error.backtrace.take(DISPLAYED_CALLS).join("\n") +
        "\n...Remaining #{remaining} call sites elided.\n"
    end
  end

  def self.warn_short_trace(logger, error)
    remaining = e.backtrace.length - DISPLAYED_CALLS
    logger.warn do
      error.message + "\n" + # rubocop:disable Style/StringConcatenation
        error.backtrace.take(DISPLAYED_CALLS).join("\n") +
        "\n...Remaining #{remaining} call sites elided.\n"
    end
  end

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
      @helper = JekyllPluginHelper.new tag_name, argument_string, @logger, respond_to?(:no_arg_parsing)
    end

    # @return line number where tag or block was found, relative to the start of the page
    def jekyll_line_number
      @page['front_matter'].count("\n") + @line_number
    end

    # Method prescribed by the Jekyll plugin lifecycle.
    # Defines @config, @envs, @mode, @page and @site
    # @return [String]
    def render(liquid_context)
      text = super
      @helper.liquid_context = liquid_context

      @page = liquid_context.registers[:page] # hash
      @site = liquid_context.registers[:site]
      @config = @site.config
      @envs = liquid_context.environments.first

      @layout    = @envs[:layout]
      @paginator = @envs[:paginator]
      @theme     = @envs[:theme]

      config = @config['plugin_suppport']
      @enable_stack_dump = config['enable_stack_dump'] if config
      @logger.info { 'Stack dumps are ' + (@enable_stack_dump ? 'enabled' : 'disabled') }

      @mode = @config['env']&.key?('JEKYLL_ENV') ? @config['env']['JEKYLL_ENV'] : 'development'

      @config['x']['y']

      render_impl text
    rescue StandardError => e
      raise(e) if @enable_stack_dump

      # exit_without_stack_trace(e)

      @logger.error { "#{self.class} died with a #{e.full_message}" }
      e.set_backtrace []
      raise e
    end

    # Jekyll plugins should override this method, not render,
    # so they can be tested more easily.
    # The following variables are predefined:
    #   @argument_string, @config, @envs, @helper, @layout, @logger, @mode, @page, @paginator, @site, @tag_name and @theme
    # @return [String] The result to be rendered to the invoking page
    def render_impl(text)
      text
    end

    def warn_short_trace(error)
      JekyllSupport.warn_short_trace(@logger, error)
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
      @logger.error { "#{self.class} died with a #{e.full_message}" }
      exit 2
    end

    def warn_short_trace(error)
      JekyllSupport.warn_short_trace(@logger, error)
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

    # If a Jekyll plugin needs to crash exit, and stop Jekyll, call this method.
    # It does not generate a stack trace.
    # This method does not return because the process is abruptly terminated.
    #
    # @param error StandardError or a subclass of StandardError is required
    #
    # Do not raise the error before calling this method, just create it via 'new', like this:
    # exit_without_stack_trace StandardError.new('This is my error message')
    #
    # If you want to call this method from a handler method, the default index for the backtrace array must be specified.
    # The default backtrace index is 1, which means the calling method.
    # To specify the calling method's caller, pass in 2, like this:
    # exit_without_stack_trace StandardError.new('This is my error message'), 2
    def exit_without_stack_trace(error, caller_index = 1)
      puts 'asdfasdfasefa'
      return

      raise error
    rescue StandardError => e
      file, line_number, caller = e.backtrace[caller_index].split(':')
      caller = caller.tr('`', "'")
      warn "#{self.class} died with a '#{error.message}' #{caller} on line #{line_number} of #{file}".red
      # Process.kill('HUP', Process.pid) # generates huge stack trace
      exec "echo ''"
    end

    # @return line number where tag or block was found, relative to the start of the page
    def jekyll_line_number
      @page['front_matter'].count("\n") + @line_number
    end

    # Method prescribed by the Jekyll plugin lifecycle.
    def render(liquid_context)
      return if @helper.excerpt_caller

      @helper.liquid_context = liquid_context

      @envs      = liquid_context.environments.first

      @layout    = @envs[:layout]
      @paginator = @envs[:paginator]
      @theme     = @envs[:theme]

      @page      = liquid_context.registers[:page]
      @site      = liquid_context.registers[:site]

      @config = @site.config

      config = @config['plugin_suppport']
      @enable_stack_dump = config['enable_stack_dump'] == true if config
      @logger.info { 'Stack dumps are ' + (@enable_stack_dump ? 'enabled' : 'disabled') }

      @mode = @config['env']&.key?('JEKYLL_ENV') ? @config['env']['JEKYLL_ENV'] : 'development'

      render_impl
    rescue StandardError => e
      exit_without_stack_trace(e) unless @enable_stack_dump
      raise e
    end

    # Jekyll plugins must override this method, not render, so their plugin can be tested more easily
    # The following variables are predefined:
    #   @argument_string, @config, @envs, @helper, @layout, @logger, @mode, @page, @paginator, @site, @tag_name and @theme
    def render_impl
      abort "#{self.class}.render_impl for tag #{@tag_name} must be overridden, but it was not."
    end

    def warn_short_trace(error)
      JekyllSupport.warn_short_trace(@logger, error)
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
