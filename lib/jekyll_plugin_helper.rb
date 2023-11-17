require 'facets/string/interpolate'
require 'key_value_parser'
require 'shellwords'
require_relative 'jekyll_plugin_helper_class'
require_relative 'jekyll_plugin_helper_attribution'

class JekyllPluginHelper
  attr_accessor :liquid_context
  attr_reader :argv, :attribution, :keys_values, :logger, :markup, :no_arg_parsing, :params, :tag_name,
              :argv_original, :excerpt_caller, :keys_values_original, :params_original, :jpsh_subclass_caller

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
    @markup = markup
  rescue StandardError => e
    e.shorten_backtrace
    @logger.error { e.msg }
  end

  # @return undefined if parameter was specified, removes it from the available tokens and returns value
  def parameter_specified?(name, delete_param: true)
    return false if @keys_values.to_s.empty?

    key = name
    key = name.to_sym if @keys_values&.first&.first.instance_of?(Symbol)
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
      @attribution = false
    else
      parse markup
      @attribution = parameter_specified?('attribution') || false
      @logger.debug { "@keys_values='#{@keys_values}'" }
    end
  end

  # Call this method to return the remaining markup after `parameter_specified?` has been invoked.
  def remaining_markup
    @argv&.join(' ')
  end

  def remaining_markup_original
    @argv_original&.join(' ')
  end

  def warn_fetch(variable)
    abort "Error: Argument parsing was suppressed, but an attempt to obtain the value of #{variable} was made"
  end

  def warn_parse(meth)
    abort "Error: Argument parsing was suppressed, but an attempt to invoke #{meth} was made"
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

  private

  def page
    @liquid_context.registers[:page]
  end

  def parse(markup)
    @argv_original = Shellwords.split(markup)
    @keys_values_original = KeyValueParser
                            .new({}, { array_values: false, normalize_keys: false, separator: /=/ })
                            .parse(@argv_original)
    @params_original = @keys_values_original unless respond_to?(:no_arg_parsing) && no_arg_parsing

    @argv = Shellwords.split(self.class.expand_env(markup))
    @keys_values = KeyValueParser
                   .new({}, { array_values: false, normalize_keys: false, separator: /=/ })
                   .parse(@argv)

    return if respond_to?(:no_arg_parsing) && no_arg_parsing

    @params = @keys_values # TODO: @keys_values should be deleted
  end
end
