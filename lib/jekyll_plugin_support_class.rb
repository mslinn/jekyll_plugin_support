# Monkey patch StandardError so a new method called shorten_backtrace is added.
class StandardError
  def shorten_backtrace(backtrace_element_count = 3)
    set_backtrace(backtrace[0..backtrace_element_count].map { |x| x.gsub(Dir.pwd + '/', './') })
  end
end

module JekyllSupport
  DISPLAYED_CALLS = 8

  def self.error_short_trace(logger, error)
    error.set_backtrace error.backtrace[0..DISPLAYED_CALLS]
    logger.error { error }
    error
  end

  # @return a new StandardError subclass containing the shorten_backtrace method
  def self.define_error
    Class.new StandardError
  end

  JekyllPluginSupportError = define_error

  def self.dump_vars(_logger, liquid_context)
    page = liquid_context.registers[:page]
    vars = liquid_context.scopes.map do |scope|
      scope.map { |name, value| "  #{name} = #{value}" }.join("\n")
    end.join("\n")
    puts <<~END_MSG
      #{page['name']} variables after injecting any defined in _config.yml:
      #{vars}
    END_MSG
  end

  # Add variable definitions from _config.yml to liquid_context
  # Modifies liquid_context in the caller (call by reference)
  # @return modified liquid_context
  # See README.md#configuration-variable-definitions
  # See demo/variables.html
  def self.inject_vars(_logger, liquid_context)
    site = liquid_context.registers[:site]
    plugin_variables = site.config['plugin-vars']
    scope = liquid_context.scopes.last

    env = site.config['env']
    mode = env&.key?('JEKYLL_ENV') ? env['JEKYLL_ENV'] : 'development'

    # Set default values
    plugin_variables&.each do |name, value|
      scope[name] = value if value.instance_of? String
    end

    # Set environment-specific values
    plugin_variables[mode]&.each do |name, value|
      scope[name] = value if value.instance_of? String
    end

    # dump_vars(@logger, liquid_context)
    liquid_context
  end

  def self.lookup_liquid_variables(liquid_context, markup)
    liquid_context.scopes.each do |scope|
      scope.each do |name, value|
        markup = markup.to_s.gsub("{{#{name}}}", value)
      end
    end
    markup
  end

  def self.maybe_reraise_error(error, throw: true)
    fmsg = format_error_message "#{error.class}: #{error.msg.strip}"
    @logger.error { fmsg }
    return "<span class='jekyll_plugin_support_error'>#{fmsg}</span>" unless throw

    error.set_backtrace error.backtrace[0..9]
    raise error
  end

  def self.warn_short_trace(logger, error)
    remaining = error.backtrace.length - DISPLAYED_CALLS
    logger.warn do
      error.msg + "\n" +
        error.backtrace.take(DISPLAYED_CALLS).join("\n") +
        "\n...Remaining #{remaining} call sites elided.\n"
    end
  end
end
