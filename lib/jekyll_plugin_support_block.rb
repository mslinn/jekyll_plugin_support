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
    def initialize(tag_name, markup, parse_context)
      super
      @tag_name = tag_name
      @argument_string = markup.to_s # Vars in plugin parameters cannot be replaced yet
      @logger = PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)
      @logger.debug { "#{self.class}: respond_to?(:no_arg_parsing) #{respond_to?(:no_arg_parsing) ? 'yes' : 'no'}." }
      @helper = JekyllPluginHelper.new tag_name, markup, @logger, respond_to?(:no_arg_parsing)
    end

    def format_error_message(message)
      "on line #{line_number} (after front matter) of #{@page['path']}.\n#{message}"
    end

    # Method prescribed by the Jekyll plugin lifecycle.
    # Defines @config, @envs, @mode, @page and @site
    # @return [String]
    def render(liquid_context)
      @helper.liquid_context = JekyllSupport.inject_vars @logger, liquid_context
      text = super # Liquid variable values in content are looked up and substituted

      @envs      = liquid_context.environments.first
      @page      = liquid_context.registers[:page] # hash
      @scopes    = liquid_context.scopes
      @site      = liquid_context.registers[:site]

      @config    = @site.config

      @layout    = @envs[:layout]
      @paginator = @envs[:paginator]
      @theme     = @envs[:theme]

      @mode = @config['env']&.key?('JEKYLL_ENV') ? @config['env']['JEKYLL_ENV'] : 'development'

      @helper.reinitialize(@markup.strip)

      @attribution = @helper.parameter_specified?('attribution') || false unless @no_arg_parsing
      @logger.debug { "@keys_values='#{@keys_values}'" }

      markup = JekyllSupport.lookup_liquid_variables liquid_context, @argument_string
      @helper.reinitialize markup

      render_impl text
    rescue StandardError => e
      e.backtrace = e.backtrace[0..3].map { |x| x.gsub(Dir.pwd + '/', './') }
      msg = format_error_message e.full_message
      @logger.error msg
      raise e if @die_on_standard_error

      "<div class='standard_error'>#{e.class}: #{msg}</div>"
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
end
