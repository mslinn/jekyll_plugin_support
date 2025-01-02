require_relative '../error/jekyll_plugin_error_handling'

module JekyllSupport
  # Base class for Jekyll block tags
  class JekyllBlock < Liquid::Block
    attr_reader :argument_string, :helper, :line_number, :logger, :page, :site, :text

    # See https://github.com/Shopify/liquid/wiki/Liquid-for-Programmers#create-your-own-tags
    # @param tag_name [String] the name of the tag, which we usually know.
    # @param argument_string [String] the arguments passed to the tag, as a single string.
    # @param parse_context [Liquid::ParseContext] contains the following attributes:
    #        @depth might have the value 0
    #        @error_mode might have the value `:strict`
    #        @line_number duplicates @ptions[:line_number]
    #        @locale duplicates @ptions[:locale]
    #        @options is a hash with the following two keys that holds Liquid options:
    #          :locale is a Liquid::I18n object, used to display localized error messages on Liquid built-in tags and filters.
    #          :line_number is the line number containing the plugin invocation.
    #          See https://github.com/Shopify/liquid/wiki/Liquid-for-Programmers#create-your-own-tags
    #        @partial Boolean, unclear what this indicates
    #        @template_options Replicates @options
    #        @trim_whitespace might have the value `false`
    #        @warnings array
    # @return [void]
    def initialize(tag_name, markup, parse_context)
      super
      @tag_name = tag_name
      raise JekyllPluginSupportError, "markup is a #{markup.class} with value '#{markup}'." unless markup.instance_of? String

      @argument_string = markup # Replace variable names with values in markup in render because site and config are not available here
      @logger = PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)
      @logger.debug { "#{self.class}: respond_to?(:no_arg_parsing) #{respond_to?(:no_arg_parsing) ? 'yes' : 'no'}." }
      @helper = JekyllPluginHelper.new tag_name, markup, @logger, respond_to?(:no_arg_parsing)

      @error_name = "#{tag_name.camelcase(:upper)}Error"
      JekyllSupport::CustomError.factory @error_name
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
      @helper.liquid_context = JekyllSupport.inject_config_vars liquid_context # modifies liquid_context
      text = super # Liquid variable values in content are looked up and substituted

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

      env = @config['env']
      @mode = env&.key?('JEKYLL_ENV') ? env['JEKYLL_ENV'] : 'development'

      @argument_string = JekyllSupport.lookup_liquid_variables @logger, liquid_context, @argument_string.to_s.strip
      @helper.reinitialize @argument_string.strip

      @attribution = @helper.parameter_specified?('attribution') || false unless @no_arg_parsing
      @logger.debug { "@keys_values='#{@keys_values}'" }

      @argument_string = JekyllSupport.lookup_liquid_variables @logger, liquid_context, @argument_string
      @argument_string.strip!
      @helper.reinitialize @argument_string

      render_impl(text)
    rescue StandardError => e
      e.shorten_backtrace
      file_name = e.backtrace[0]&.split(':')&.first
      in_file_name = "in '#{file_name}' " if file_name
      of_page = "of '#{@page['path']}'" if @page
      @logger.error { "#{e.class} on line #{@line_number} #{of_page} while processing #{tag_name} #{in_file_name}- #{e.message}" }
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
