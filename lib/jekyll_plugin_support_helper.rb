require 'shellwords'
require 'key_value_parser'

# Base class for all types of Jekyll plugin helpers
class JekyllPluginHelper
  attr_reader :argv, :keys_values, :liquid_context, :logger, :markup, :params, :tag_name

  # Expand a environment variable reference
  def self.expand_env(str, die_if_undefined: false)
    str.gsub(/\$([a-zA-Z_][a-zA-Z0-9_]*)|\${\g<1>}|%\g<1>%/) do
      envar = Regexp.last_match(1)
      raise HrefError, "jekyll_href error: #{envar} is undefined".red, [] \
        if !ENV.key?(envar) && die_if_undefined # Suppress stack trace

      ENV.fetch(envar, nil)
    end
  end

  def self.register(klass, name)
    abort("Error: The #{name} plugin does not define VERSION") \
      unless klass.const_defined?(:VERSION)

    version = klass.const_get(:VERSION)

    abort("Error: The #{name} plugin is not an instance of JekyllSupport::JekyllBlock or JekyllSupport::JekyllTag") \
      unless klass.instance_of?(Class) &&
             (klass.ancestors.include?(JekyllSupport::JekyllBlock) || \
              klass.ancestors.include?(JekyllSupport::JekyllTag))

    Liquid::Template.register_tag(name, klass)
    PluginMetaLogger.instance.info { "Loaded #{name} v#{version} plugin." }
  end

  # strip leading and trailing quotes if present
  def self.remove_quotes(string)
    string.strip.gsub(/\A'|\A"|'\Z|"\Z/, '').strip if string
  end

  # See https://github.com/Shopify/liquid/wiki/Liquid-for-Programmers#create-your-own-tags
  # @param tag_name [String] the name of the tag, which we already know.
  # @param argument_string [String] the arguments from the tag, as a single string.
  # @param parse_context [Liquid::ParseContext] hash that stores Liquid options.
  #        By default it has two keys: :locale and :line_numbers, the first is a Liquid::I18n object, and the second,
  #        a boolean parameter that determines if error messages should display the line number the error occurred.
  #        This argument is used mostly to display localized error messages on Liquid built-in Tags and Filters.
  #        See https://github.com/Shopify/liquid/wiki/Liquid-for-Programmers#create-your-own-tags
  # @return [void]
  def initialize(tag_name, markup, logger)
    @tag_name = tag_name
    @logger = logger
    @logger.debug { "@keys_values='#{@keys_values}'" }
    reinitialize(markup.strip)
  end

  def reinitialize(markup)
    # @keys_values was a Hash[Symbol, String|Boolean] but now it is Hash[String, String|Boolean]
    @markup = markup # Useful for debugging
    @argv = Shellwords.split(JekyllPluginHelper.expand_env(markup))
    @keys_values = KeyValueParser \
      .new({}, { array_values: false, normalize_keys: false, separator: /=/ }) \
      .parse(@argv)
  end

  def delete_parameter(key)
    return if @keys_values.empty? || @params.nil?

    @params.delete(key)
    @argv.delete_if { |x| x == key or x.start_with?("#{key}=") }
    @keys_values.delete(key)
  end

  # @return if parameter was specified, removes it from the available tokens and returns value
  def parameter_specified?(name)
    return false if @keys_values.empty?

    key = name
    key = name.to_sym if @keys_values.first.first.instance_of?(Symbol)
    value = @keys_values[key]
    delete_parameter(name)
    value
  end

  PREDEFINED_SCOPE_KEYS = %i[include page].freeze

  # Finds variables defined in an invoking include, or maybe somewhere else
  # @return variable value or nil
  def dereference_include_variable(name)
    @liquid_context.scopes.each do |scope|
      next if PREDEFINED_SCOPE_KEYS.include? scope.keys.first

      value = scope[name]
      return value if value
    end
    nil
  end

  # @return value of variable, or the empty string
  def dereference_variable(name)
    value = @liquid_context[name] # Finds variables named like 'include.my_variable', found in @liquid_context.scopes.first
    value ||= @page[name] if @page # Finds variables named like 'page.my_variable'
    value ||= dereference_include_variable(name)
    value ||= ''
    value
  end

  # Sets @params by replacing any Liquid variable names with their values
  def liquid_context=(context)
    @liquid_context = context
    @params = @keys_values.map { |k, _v| lookup_variable(k) }
  end

  def lookup_variable(symbol)
    string = symbol.to_s
    return string unless string.start_with?('{{') && string.end_with?('}}')

    dereference_variable(string.delete_prefix('{{').delete_suffix('}}'))
  end

  def page
    @liquid_context.registers[:page]
  end
end
