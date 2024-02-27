require 'pry'
require_relative 'jekyll_plugin_error_handling'

module JekyllSupport
  # Base class for Jekyll tags
  class JekyllTag < Liquid::Tag
    attr_reader :argument_string, :helper, :line_number, :logger, :page, :site

    include JekyllSupportErrorHandling
    extend JekyllSupportErrorHandling

    # See https://github.com/Shopify/liquid/wiki/Liquid-for-Programmers#create-your-own-tags
    # @param tag_name [String] the name of the tag, which we usually know.
    # @param argument_string [String] the arguments passed to the tag, as a single string.
    # @param parse_context [Liquid::ParseContext] hash that stores Liquid options.
    #        By default it has two keys: :locale and :line_numbers, the first is a Liquid::I18n object, and the second,
    #        a boolean parameter that determines if error messages should display the line number the error occurred.
    #        This argument is used mostly to display localized error messages on Liquid built-in Tags and Filters.
    #        See https://github.com/Shopify/liquid/wiki/Liquid-for-Programmers#create-your-own-tags
    # @return [void]
    def initialize(tag_name, markup, parse_context)
      super
      @tag_name = tag_name
      raise JekyllPluginSupportError, "markup is a #{markup.class} with value '#{markup}'." unless markup.instance_of? String

      @argument_string = markup
      @logger = PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)
      @logger.debug { "#{self.class}: respond_to?(:no_arg_parsing) #{respond_to?(:no_arg_parsing) ? 'yes' : 'no'}." }
      @helper = JekyllPluginHelper.new(tag_name, @argument_string, @logger, respond_to?(:no_arg_parsing))

      @error_name = "#{tag_name.camelcase(:upper)}Error"
      Jekyll::CustomError.factory @error_name
    end

    # Method prescribed by the Jekyll plugin lifecycle.
    def render(liquid_context)
      return if @helper.excerpt_caller

      @helper.liquid_context = JekyllSupport.inject_vars @logger, liquid_context

      @envs      = liquid_context.environments.first
      @page      = liquid_context.registers[:page]
      @scopes    = liquid_context.scopes
      @site      = liquid_context.registers[:site]

      @config = @site.config
      @tag_config = @config[@tag_name]
      @jps = @config['jekyll_plugin_support']
      @pry_on_standard_error = @jps['pry_on_standard_error'] || false if @jps

      set_error_context

      # @envs.keys are :content, :highlighter_prefix, :highlighter_suffix, :jekyll, :layout, :page, :paginator, :site, :theme
      @layout    = @envs[:layout]
      @paginator = @envs[:paginator]
      @theme     = @envs[:theme]

      @mode = @config['env']&.key?('JEKYLL_ENV') ? @config['env']['JEKYLL_ENV'] : 'development'

      markup = JekyllSupport.lookup_liquid_variables liquid_context, @argument_string
      @helper.reinitialize markup

      render_impl
    rescue StandardError => e
      e.shorten_backtrace
      file_name = e.backtrace[0]&.split(':')&.first
      of_file_name = "of #{file_name} " if file_name
      @logger.error { "#{e.class} on line #{@line_number} #{of_file_name}while processing #{tag_name} - #{e.message}" }
      binding.pry if @pry_on_standard_error # rubocop:disable Lint/Debugger
      raise e if @die_on_standard_error

      <<~END_MSG
        <div class='standard_error'>
          #{e.class} on line #{@line_number} of #{e.backtrace[0].split(':').first} while processing #{tag_name}: #{e.message}
        </div>
      END_MSG
    end

    # Jekyll plugins must override this method, not render, so their plugin can be tested more easily
    # The following variables are predefined:
    #   @argument_string, @config, @envs, @helper, @layout, @logger, @mode, @page, @paginator, @site, @tag_name and @theme
    def render_impl
      abort "#{self.class}.render_impl for tag #{@tag_name} must be overridden, but it was not."
    end

    def set_error_context
      return unless Object.const_defined? @error_name

      error_class = Object.const_get @error_name
      error_class.class_variable_set(:@@argument_string, @argument_string)
      error_class.class_variable_set(:@@line_number, @line_number)
      error_class.class_variable_set(:@@path, @page['path'])
      error_class.class_variable_set(:@@tag_name, @tag_name)
    end
  end
end
