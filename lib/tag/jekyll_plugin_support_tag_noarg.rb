require_relative '../error/jekyll_plugin_error_handling'

module JekyllSupport
  class JekyllTagNoArgParsing < JekyllTag
    attr_reader :argument_string, :helper, :line_number, :logger, :page, :site

    def initialize(tag_name, argument_string, parse_context)
      class << self
        include NoArgParsing
      end

      super
      @logger.debug { "#{self.class}: respond_to?(:no_arg_parsing) #{respond_to?(:no_arg_parsing) ? 'yes' : 'no'}." }
    end

    # Jekyll plugins must override this method, not render, so their plugin can be tested more easily
    # The following variables are predefined:
    #   @argument_string, @config, @envs, @helper, @layout, @logger, @mode, @page, @paginator, @site, @tag_name and @theme
    def render_impl
      abort "#{self.class}.render_impl for tag #{@tag_name} must be overridden, but it was not."
    end
  end
end
