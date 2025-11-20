# Monkey patch StandardError so a new method called shorten_backtrace is added.
class StandardError
  def shorten_backtrace(backtrace_element_count = 5)
    set_backtrace backtrace[0..backtrace_element_count]
    # self.backtrace = backtrace[0..backtrace_element_count].map do |x|
    #   raise JekyllPluginSupportError, "backtrace contains a #{x.class} with value '#{x}'." unless x.instance_of? String

    #   x.gsub(Dir.pwd + '/', './')
    # end
  end
end

module JekyllSupport
  DISPLAYED_CALLS = 8 unless defined?(DISPLAYED_CALLS)

  def self.error_short_trace(logger, error)
    error.set_backtrace error.backtrace[0..DISPLAYED_CALLS]
    logger.error { error.full_message } # Are error and logger.error defined?
    error
  end

  # @return a new StandardError subclass containing the shorten_backtrace method
  def define_error
    Class.new ::JekyllSupport::CustomError
  end
  module_function :define_error

  JekyllPluginSupportError = define_error unless defined?(JekyllPluginSupportError)

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

  # Inject variable definitions from _config.yml into liquid_context
  # Modifies liquid_context.scopes in the caller
  # (call by object reference, see https://stackoverflow.com/a/1872159/553865)
  # @return modified liquid_context
  # See README.md#configuration-variable-definitions
  # See demo/variables.html
  def self.inject_config_vars(liquid_context)
    site = liquid_context.registers[:site]

    plugin_variables = site.config['liquid_vars']

    scope = liquid_context.scopes.last

    # Support multiple environment variable keys and fall back to Jekyll's environment
    env = site.config['env']
    @mode = env&.[]('JEKYLL_ENV') || 
            env&.[]('JEKYLL_ENVIRONMENT') || 
            site.config['JEKYLL_ENV'] || 
            site.config['JEKYLL_ENVIRONMENT'] || 
            'development'

    # Set default values (support multiple data types)
    plugin_variables&.each do |name, value|
      scope[name] = value
    end

    # Override with environment-specific values
    plugin_variables&.[](@mode)&.each do |name, value|
      scope[name] = value
    end

    liquid_context
  end

  def self.dump_stack(stack, cycles, interval)
    stack_depth = stack.length
    puts "Stack depth is #{stack_depth}"
    num_entries = cycles * interval
    return unless stack_depth > interval * 5

    stack.last(num_entries).each_with_index do |x, i|
      msg = "  #{i}: #{x}"
      (i % interval).zero? ? puts(msg.yellow) : puts(msg)
    end
  end

  # Modifies a clone of markup_original so variable references are replaced by their values
  # @param markup_original to be cloned
  # @return modified markup_original
  def self.lookup_liquid_variables(logger, liquid_context, markup_original)
    markup = markup_original.clone
    page   = liquid_context.registers[:page]
    envs   = liquid_context.environments.first
    layout = envs[:layout]
    jekyll = envs[:jekyll]

    # Process variables in Jekyll's actual priority order:
    # 1. Page variables (registers[:page])
    # 2. Layout variables (environments.first[:layout])
    # 3. Jekyll global variables (environments.first[:jekyll])
    # 4. Include variables (scopes)
    # 5. Liquid variables (scopes)
    markup = process_page_variables logger, page, markup
    markup = process_layout_variables logger, layout, markup
    markup = process_jekyll_variables logger, jekyll, markup
    liquid_context.scopes&.each do |scope|
      markup = process_included_variables logger, scope, markup
      markup = process_liquid_variables logger, scope, markup
    end
    markup
  rescue StandardError => e
    logger.error { e.full_message }
  end

  def self.process_included_variables(logger, scope, markup)
    scope['include']&.each do |name, value|
      raise JekyllPluginSupportError, "include.#{name} is undefined." if name.nil?
      raise JekyllPluginSupportError, "include.#{name} is a #{name.class}, not a String." unless name.instance_of?(String)
      raise JekyllPluginSupportError, "include.#{name} has an undefined value." if value.nil?

      # Sanitize variable name to prevent regex injection
      sanitized_name = sanitize_variable_name(name)
      markup.gsub!("{{include.#{sanitized_name}}}", value.to_s)
    end
    markup
  rescue StandardError => e
    logger.error { e.full_message }
  end

  def self.process_layout_variables(logger, layout, markup)
    layout&.each do |name, value|
      if value.nil?
        value = ''
        logger.warn { "layout.#{value} is undefined." }
      end
      markup.gsub!("{{layout.#{name}}}", value.to_s)
    end
    markup
  rescue StandardError => e
    logger.error { e.full_message }
  end

  # Process assigned, captured and injected variables
  def self.process_liquid_variables(logger, scope, markup)
    unless markup.instance_of?(String)
      logger.warn { "markup is a #{markup.class}, not a String" }
      return markup
    end
    scope&.each do |name, value|
      next if name.nil?

      value = '' if value.nil?
      markup.gsub!("{{#{name}}}", value&.to_s)
    end
    markup
  rescue StandardError => e
    logger.error { e.full_message }
  end

  def self.process_page_variables(logger, page, markup)
    page&.each_key do |key|
      next if %w[content excerpt next previous output].include? key # Skip problem attributes

      markup.gsub!("{{page.#{key}}}", page[key].to_s)
    end
    markup
  rescue StandardError => e
    logger.error { e.full_message }
  end

  def self.process_jekyll_variables(logger, jekyll, markup)
    jekyll&.each do |name, value|
      value = '' if value.nil?
      markup.gsub!("{{jekyll.#{name}}}", value.to_s)
    end
    markup
  rescue StandardError => e
    logger.error { e.full_message }
  end

  # Sanitizes variable names to prevent regex injection attacks
  # @param name [String] the variable name to sanitize
  # @return [String] sanitized variable name
  def self.sanitize_variable_name(name)
    # Allow only alphanumeric characters, underscores, and hyphens
    name.to_s.gsub(/[^a-zA-Z0-9_-]/, '')
  end

  def self.warn_short_trace(logger, error)
    remaining = error.backtrace.length - DISPLAYED_CALLS
    logger.warn do
      error.message + "\n" +
        error.backtrace.take(DISPLAYED_CALLS).join("\n") +
        "\n...Remaining #{remaining} call sites elided.\n"
    end
  end
end
