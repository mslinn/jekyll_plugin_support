require_relative '../error/jekyll_plugin_error_handling'

module JekyllSupport
  class JekyllBlockNoArgParsing < JekyllBlock
    attr_reader :argument_string, :helper, :line_number, :logger, :page, :site

    include JekyllSupportErrorHandling
    extend JekyllSupportErrorHandling

    def initialize(tag_name, argument_string, parse_context)
      class << self
        include NoArgParsing
      end

      super
      @logger.debug { "#{self.class}: respond_to?(:o_arg_parsing) #{respond_to?(:no_arg_parsing) ? 'yes' : 'no'}." }
    rescue StandardError => e
      e.shorten_backtrace
      @logger.error { e.full_message }
      JekyllSupport.error_short_trace(@logger, e)
    end

    # Liquid::Block subclasses do not render if there is no content within the tag
    # This override fixes that
    def blank?
      false
    end

    # Jekyll plugins must override this method, not render, so their plugin can be tested more easily
    # The following variables are predefined:
    #   @argument_string, @config, @envs, @helper, @layout, @logger, @mode, @page, @paginator, @site, @tag_name and @theme
    def render_impl
      abort "#{self.class}.render_impl for tag #{@tag_name} must be overridden, but it was not."
    end
  end
end
