# Class methods for JekyllPluginHelper
class JekyllPluginHelper
  # Expand an environment variable reference
  def self.expand_env(str, die_if_undefined: false)
    str&.gsub(/\$([a-zA-Z_][a-zA-Z0-9_]*)|\${\g<1>}|%\g<1>%/) do
      envar = Regexp.last_match(1)
      raise JekyllPluginSupportError, "jekyll_plugin_support error: #{envar} is undefined".red, [] \
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
end
