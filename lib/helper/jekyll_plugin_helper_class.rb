require 'facets/string/camelcase'
require 'facets/string/snakecase'
require 'yaml'

module JekyllSupport
  # Class methods for JekyllPluginHelper
  class JekyllPluginHelper
    # Expand an environment variable reference
    def self.expand_env(str, logger = nil, die_if_undefined: false)
      str&.gsub(/\$([a-zA-Z_][a-zA-Z0-9_]*)|\${\g<1>}/) do
        envar = Regexp.last_match(1)
        unless ENV.key? envar
          msg = "jekyll_plugin_support error: environment variable #{envar} is undefined"
          raise JekyllPluginSupportError, msg.red, [] if die_if_undefined

          if logger
            logger.warn msg
          else
            puts msg.red
          end
        end
        ENV.fetch(envar, nil)
      end
    end

    def self.generate_message(klass, tag_name, version)
      error_name_stub = klass.name.include?('::') ? klass.name.split('::')[1] : klass.name
      error_ruby_class_name = "#{error_name_stub.camelcase(:upper)}Error"
      config_die_key = "die_on_#{error_ruby_class_name.snakecase}"
      error_css_class_name = error_ruby_class_name.split('::').last.snakecase
      config = YAML.load_file('_config.yml')
      tag_config = config[tag_name]
      tag_config_msg = if tag_config.nil?
                         <<~END_MSG
                           _config.yml does not contain configuration information for this plugin.
                             You could add a section containing default values by specifying a section for the tag name,
                             and an entry whose name starts with `die_on_`, followed by a snake_case version of the error name.

                               #{tag_name}:
                                 #{config_die_key}: false
                         END_MSG
                       else
                         <<~END_MSG
                           _config.yml contains the following configuration for this plugin:
                             #{tag_config}
                         END_MSG
                       end

      <<~END_MSG
        Loaded plugin #{tag_name} v#{version}. It has:
          Error class: #{error_ruby_class_name}
          CSS class for error messages: #{error_css_class_name}

          #{tag_config_msg}
      END_MSG
    end

    def self.register(klass, tag_name)
      abort("Error: The #{tag_name} plugin does not define VERSION") \
        unless klass.const_defined?(:VERSION)

      version = klass.const_get(:VERSION)

      abort("Error: The #{tag_name} plugin is not an instance of JekyllSupport::JekyllBlock or JekyllSupport::JekyllTag") \
        unless klass.instance_of?(Class) &&
               (klass.ancestors.include?(JekyllSupport::JekyllBlock) ||
                klass.ancestors.include?(JekyllSupport::JekyllTag))

      Liquid::Template.register_tag(tag_name, klass)
      msg = generate_message(klass, tag_name, version)
      PluginMetaLogger.instance.info { msg }
    end

    def self.remove_html_tags(string)
      string.gsub(/<[^>]*>/, '').strip
    end

    # strip leading and trailing quotes if present
    def self.remove_quotes(string)
      string.strip.gsub(/\A'|\A"|'\Z|"\Z/, '').strip if string
    end
  end
end
