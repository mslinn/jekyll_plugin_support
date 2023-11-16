module JekyllSupport
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
    def initialize(tag_name, markup, parse_context)
      super
      @tag_name = tag_name
      @argument_string = markup.to_s
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
      raise error
    rescue StandardError => e
      file, line_number, caller = e.backtrace[caller_index].split(':')
      caller = caller.tr('`', "'")
      warn "#{error.msg} #{caller} on line #{line_number} (after front matter) of #{file}".red
      # Process.kill('HUP', Process.pid) # generates huge stack trace
      exec "echo ''"
    end

    def format_error_message(message)
      "#{message}  on line #{line_number} (after front matter) of #{@page['path']}"
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

      # @envs.keys are :content, :highlighter_prefix, :highlighter_suffix, :jekyll, :layout, :page, :paginator, :site, :theme
      @layout    = @envs[:layout]
      @paginator = @envs[:paginator]
      @theme     = @envs[:theme]

      @mode = @config['env']&.key?('JEKYLL_ENV') ? @config['env']['JEKYLL_ENV'] : 'development'

      @helper.reinitialize(@markup.strip)

      markup = JekyllSupport.lookup_liquid_variables liquid_context, @argument_string
      @helper.reinitialize markup

      render_impl
    rescue StandardError => e
      @logger.error { e.full_message }
      JekyllSupport.error_short_trace(@logger, e)
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
end
