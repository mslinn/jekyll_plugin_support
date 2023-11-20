# Monkey patch StandardError so a new method called shorten_backtrace is added.
class StandardError
  def shorten_backtrace(backtrace_element_count = 3)
    # self.backtrace = backtrace[0..backtrace_element_count].map do |x|
    #   raise JekyllPluginSupportError, "backtrace contains a #{x.class} with value '#{x}'." unless x.instance_of? String

    #   x.gsub(Dir.pwd + '/', './')
    # end
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
  def define_error
    Class.new StandardError
  end
  module_function :define_error

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

    plugin_variables = site.config['liquid-vars']
    return liquid_context unless plugin_variables

    scope = liquid_context.scopes.last

    env = site.config['env']
    mode = env&.key?('JEKYLL_ENV') ? env['JEKYLL_ENV'] : 'development'

    # Set default values
    plugin_variables&.each do |name, value|
      scope[name] = value if value.instance_of? String
    end

    # Override with environment-specific values
    plugin_variables[mode]&.each do |name, value|
      scope[name] = value if value.instance_of? String
    end

    liquid_context
  end

  def self.lookup_liquid_variables(liquid_context, markup)
    liquid_context.scopes.each do |scope|
      scope.each do |name, value|
        markup = markup.gsub("{{#{name}}}", value.to_s)
      end
    end
    markup
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
