require 'jekyll'
require_relative 'jekyll_plugin_error_handling'

module JekyllSupport
  # Base class for Jekyll block tags
  class JekyllGenerator < Jekyll::Generator
    attr_reader :helper, :line_number, :logger, :site

    include JekyllSupportErrorHandling
    extend JekyllSupportErrorHandling

    # Method prescribed by the Jekyll plugin lifecycle.
    # Defines @config, @envs, @mode and @site
    # @return [void]
    def generate(site)
      @logger ||= PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)

      @error_name = "#{self.class.name}Error"
      # Jekyll::CustomError.factory @error_name

      @site   = site
      @config = @site.config
      @envs   = site.config['env']
      @theme  = @site.theme

      @mode = ENV['JEKYLL_ENV'] || 'development'

      # set_error_context(self.class)
    rescue StandardError => e
      e.shorten_backtrace
      @logger.error { "#{e.class} on line #{@line_number} of #{e.backtrace[0].split(':').first} by #{self.class.name} - #{e.message}" }
      binding.pry if @pry_on_standard_error # rubocop:disable Lint/Debugger
      raise e if @die_on_standard_error

      <<~END_MSG
        <div class='standard_error'>
          #{e.class} on line #{@line_number} of #{e.backtrace[0].split(':').first} by #{self.class.name}: #{e.message}
        </div>
      END_MSG
    end

    # Jekyll plugins should override this method, not `generate`, so they can be tested more easily.
    # The following variables are predefined:
    #   @config, @envs, @helper, @logger, @mode, @paginator, @site and @theme
    # @return [void]
    def generate_impl; end

    def self.register(klass)
      abort("Error: The #{klass.name} plugin does not define VERSION") \
        unless klass.const_defined?(:VERSION)

      version = klass.const_get(:VERSION)
      error_name_stub = klass.name.include?('::') ? klass.name.split('::')[1] : klass.name
      error_ruby_class_name = "#{error_name_stub.camelcase(:upper)}Error"
      error_css_class_name = error_ruby_class_name.split('::').last.snakecase
      msg = <<~END_MSG
        Loaded generator plugin #{klass.name} v#{version}. It has:
          Error class: #{@error_name}
          CSS class for error messages: #{error_css_class_name}
      END_MSG

      PluginMetaLogger.instance.info { msg }
    end

    def set_error_context(klass)
      return unless Object.const_defined? @error_name

      error_class = Object.const_get @error_name
      error_class.class_variable_set(:@@argument_string, @argument_string)
      error_class.class_variable_set(:@@line_number, @line_number)
      error_class.class_variable_set(:@@path, @page['path'])
      error_class.class_variable_set(:@@tag_name, klass.name)
    end
  end
end
