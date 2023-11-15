module JekyllSupport
  DISPLAYED_CALLS = 8

  def self.error_short_trace(logger, error)
    remaining = error.backtrace.length - DISPLAYED_CALLS
    logger.error do
      error.message + "\n" + # rubocop:disable Style/StringConcatenation
        error.backtrace.take(DISPLAYED_CALLS).join("\n") +
        "\n...Remaining #{remaining} call sites elided.\n"
    end
  end

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
  # Modifies liquid_context in caller
  # @return modified liquid_context
  def self.inject_vars(_logger, liquid_context)
    site = liquid_context.registers[:site]
    plugin_variables = site.config['plugin-vars']

    plugin_variables.each do |name, value|
      liquid_context.scopes.last[name] = value
    end
    # dump_vars(@logger, liquid_context)
    liquid_context
  end

  def self.lookup_liquid_variables(liquid_context, markup)
    liquid_context.scopes.each do |scope|
      scope.each do |name, value|
        markup.gsub!("{{#{name}}}", value)
      end
    end
    markup
  end

  def self.warn_short_trace(logger, error)
    remaining = error.backtrace.length - DISPLAYED_CALLS
    logger.warn do
      error.message + "\n" + # rubocop:disable Style/StringConcatenation
        error.backtrace.take(DISPLAYED_CALLS).join("\n") +
        "\n...Remaining #{remaining} call sites elided.\n"
    end
  end
end
