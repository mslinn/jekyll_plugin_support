require_relative '../error/jekyll_plugin_error_handling'

module JekyllSupport
  # Base class for Jekyll block tags
  class JekyllBlock < Liquid::Block
    attr_reader :argument_string, :helper, :line_number, :logger, :page, :site, :text

    include JekyllSupportErrorHandling
    extend JekyllSupportErrorHandling

    def self.redef_without_warning(const, value)
      send(:remove_const, const) if const_defined?(const)
      const_set const, value
    end

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

      @error_name = "#{tag_name.camelcase(:upper)}Error"
      Jekyll::CustomError.factory @error_name
    end

    # Liquid::Block subclasses do not render if there is no content within the tag
    # This override fixes that
    def blank?
      false
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

      @config = @site.config
      @tag_config = @config[@tag_name]
      @jps = @config['jekyll_plugin_support']
      @pry_on_standard_error = @jps['pry_on_standard_error'] || false if @jps

      set_error_context

      @layout    = @envs[:layout]
      @paginator = @envs[:paginator]
      @theme     = @envs[:theme]

      env = @config['env']
      @mode = env&.key?('JEKYLL_ENV') ? env['JEKYLL_ENV'] : 'development'

      @helper.reinitialize @markup.strip

      @attribution = @helper.parameter_specified?('attribution') || false unless @no_arg_parsing
      @logger.debug { "@keys_values='#{@keys_values}'" }

      markup = JekyllSupport.lookup_liquid_variables liquid_context, @argument_string
      @helper.reinitialize markup

      render_impl(text)
    rescue StandardError => e
      e.shorten_backtrace
      @logger.error { "#{e.class} on line #{@line_number} of #{e.backtrace[0].split(':').first} by #{@tag_name} - #{e.message}" }
      binding.pry if @pry_on_standard_error # rubocop:disable Lint/Debugger
      raise e if @die_on_standard_error

      <<~END_MSG
        <div class='standard_error'>
          #{e.class} on line #{@line_number} of #{e.backtrace[0].split(':').first} by #{@tag_name}: #{e.message}
        </div>
      END_MSG
    end

    # Jekyll plugins should override this method, not render,
    # so they can be tested more easily.
    # The following variables are predefined:
    #   @argument_string, @config, @envs, @helper, @layout, @logger, @mode, @page, @paginator, @site, @tag_name and @theme
    # @return [String] The result to be rendered to the invoking page
    def render_impl(text)
      text
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
