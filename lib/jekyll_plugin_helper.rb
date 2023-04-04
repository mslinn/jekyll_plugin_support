require 'facets/string/interpolate'
require 'key_value_parser'
require 'shellwords'
require_relative 'gem_support'

# Base class for all types of Jekyll plugin helpers
class JekyllPluginHelper # rubocop:disable Metrics/ClassLength
  attr_accessor :liquid_context
  attr_reader :argv, :attribution, :keys_values, :logger, :markup, :no_arg_parsing, :params, :tag_name,
              :argv_original, :keys_values_original, :params_original, :jpsh_subclass_caller

  # Expand an environment variable reference
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
             (klass.ancestors.include?(JekyllSupport::JekyllBlock) ||
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
  def initialize(tag_name, markup, logger, no_arg_parsing)
    @tag_name = tag_name
    @logger = logger
    @no_arg_parsing = no_arg_parsing
    reinitialize(markup.strip)

    @attribution = parameter_specified?('attribution') unless no_arg_parsing
    @logger.debug { "@keys_values='#{@keys_values}'" }
  rescue StandardError => e
    @logger.error { "#{self.class} died with a #{e.full_message}" }
  end

  def attribute
    return unless @gem_name

    <<~END_OUTPUT
      <div id="jps_attribute_#{rand(999_999)}" class="jps_attribute">
        <div>
          <a href="#{@homepage}" target="_blank" rel="nofollow">
            #{attribution_string}
          </a>
        </div>
      </div>
    END_OUTPUT
  end

  def default_attribution
    authors = @authors&.join(', ')
    result = "Generated by the \#{@name} v\#{@version} Jekyll plugin"
    result << ", written by #{authors}" if authors
    result << " \#{@published_date}" if @published_date
    result << '.'
    result
  end

  # Sets @current_gem if file points at a uniquely named file within a gem.
  # @param file must be a fully qualified file name in a gem, for example: __FILE__
  def gem_file(file)
    @current_gem = GemSupport.current_spec file
    @logger.debug "No gem found for '#{file} was found." unless @current_gem
    annotate_globals if @attribution && @current_gem
  end

  # @return if parameter was specified, removes it from the available tokens and returns value
  def parameter_specified?(name, delete_param: true)
    return false if @keys_values.empty?

    key = name
    key = name.to_sym if @keys_values.first.first.instance_of?(Symbol)
    value = @keys_values[key]
    delete_parameter(name) if delete_param
    value
  end

  def reinitialize(markup)
    # @keys_values was a Hash[Symbol, String|Boolean] but now it is Hash[String, String|Boolean]
    @markup = markup
    if @no_arg_parsing
      define_singleton_method(:argv) { warn_fetch :argv }
      define_singleton_method(:keys_values) { warn_fetch :keys_values }
      define_singleton_method(:params) { warn_fetch :params }
      define_singleton_method(:parameter_specified?) { |_name| warn_parse(:parameter_specified?) }
      define_singleton_method(:delete_parameter) { |_name| warn_parse(:delete_parameter) }
    else
      parse markup
    end
  end

  # Call this method to return the remaining markup after `parameter_specified?` has been invoked.
  def remaining_markup
    @argv.join(' ')
  end

  def remaining_markup_original
    @argv_original.join(' ')
  end

  def warn_fetch(variable)
    abort "Error: Argument parsing was suppressed, but an attempt to obtain the value of #{variable} was made"
  end

  def warn_parse(meth)
    abort "Error: Argument parsing was suppressed, but an attempt to invoke #{meth} was made"
  end

  private

  def attribution_string
    string = if @attribution == true
               default_attribution
             else
               @attribution
             end
    puts { "Interpolationg #{string}" }
    String.interpolate { string }
  end

  def annotate_globals
    return unless @current_gem

    @name           = @current_gem.name
    @authors        = @current_gem.authors
    @homepage       = @current_gem.homepage
    @published_date = @current_gem.date.to_date.to_s
    @version        = @current_gem.version
  end

  def delete_parameter(key)
    return if @keys_values.empty? || @params.nil?

    @params.delete(key)
    @argv.delete_if { |x| x == key or x.start_with?("#{key}=") }
    @keys_values.delete(key)

    @params_original.delete(key)
    @argv_original.delete_if { |x| x == key or x.start_with?("#{key}=") }
    @keys_values_original.delete(key)
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

  def lookup_variable(symbol)
    string = symbol.to_s
    return string unless string.start_with?('{{') && string.end_with?('}}')

    dereference_variable(string.delete_prefix('{{').delete_suffix('}}'))
  end

  def page
    @liquid_context.registers[:page]
  end

  # rubocop:disable Style/IfUnlessModifier
  def parse(markup)
    @argv_original = Shellwords.split(markup)
    @keys_values_original = KeyValueParser
      .new({}, { array_values: false, normalize_keys: false, separator: /=/ })
      .parse(@argv_original)
    unless respond_to?(:no_arg_parsing) && no_arg_parsing
      @params_original = @keys_values_original.map { |k, _v| lookup_variable(k) }
    end

    @argv = Shellwords.split(self.class.expand_env(markup))
    @keys_values = KeyValueParser
      .new({}, { array_values: false, normalize_keys: false, separator: /=/ })
      .parse(@argv)

    return if respond_to?(:no_arg_parsing) && no_arg_parsing

    @params = @keys_values.map { |k, _v| lookup_variable(k) }
  end
  # rubocop:enable Style/IfUnlessModifier
end
