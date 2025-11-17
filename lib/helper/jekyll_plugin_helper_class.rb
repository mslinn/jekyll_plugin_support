require 'facets/string/camelcase'
require 'facets/string/snakecase'
require 'yaml'

module JekyllSupport
  # Class methods for JekyllPluginHelper
  class JekyllPluginHelper
    # Case-insensitive search for a Bash environment variable name
    # # @param name [String] name of environment variable to search for
    # @return matching variable value, or nil if not found
    def self.env_var_case_insensitive(name)
      candidate = ENV.fetch(name, nil) # exact match first
      return candidate if candidate

      candidates = ENV.select do |key, _value| # case-insensitive search
        key.casecmp?(name)
      end.keys
      case candidates.size
      when 0
        msg = "Environment variable #{name} is undefined, even with a case-insensitive search."
        if Jekyll.logger
          Jekyll.logger.warn msg
        else
          puts "jekyll_plugin_support warning: #{msg}".red
        end
        nil
      when 1
        candidates.first
      else
        msg = "Multiple case-insensitive matches found for environment variable #{name}: #{candidates.join(', ')}"
        raise JekyllPluginSupportError, msg.red, []
      end
    end

    # Expand an environment variable reference;
    #  - first expand bash environment variables,
    #  - then expand windows environment vars
    def self.expand_env(str, logger = nil, die_if_undefined: false, use_wslvar: true)
      x = JekyllPluginHelper.env_var_expand_bash(str, logger, die_if_undefined: die_if_undefined)
      JekyllPluginHelper.env_var_expand_windows(x, logger, die_if_undefined: die_if_undefined, use_wslvar: use_wslvar)
    end

    # If a Windows-style env var is evaluated on a non-Windows machine,
    # then a Bash environment variable of the same name is searched for and used, if found.
    # - If an exact case-sensitive match is found, it is used.
    #   A debug-level log message is emitted stating what happened.
    # - If a case-insensitive match is found, it is used, and a warning is issued.
    # - If more than one case-insensitive match is found, Jekyll is shut down.
    def self.env_var_expand_bash(str, logger = nil, die_if_undefined: false)
      str&.gsub(/\$([a-zA-Z_][a-zA-Z0-9_]*)|\${\g<1>}/) do
        envar = Regexp.last_match 1
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

    # Called for Linux, MacOS, and Windows (with WSL)
    #
    def self.find_windows_envar(envar, use_wslvar: true)
      if use_wslvar
        wslvar_path = `which wslvar 2> /dev/null`.chomp
        if wslvar_path.empty?
          warn "jekyll_plugin_support warning: wslvar not found in PATH; will attempt to find $#{envar} in the bash environment variables."
        end

        return `wslvar #{envar} &2> /dev/null`.chomp
      end
      env_var_case_insensitive(envar)
    end

    # Detect if Jekyll is running under WSL
    def self.wsl_detected? = File.read('/proc/version').include?('-WSL')

    def self.env_var_expand_windows(str, logger = nil, die_if_undefined: false, use_wslvar: true)
      # Only expand %VAR% if str is not nil and contains a %
      if str&.include?('%')
        str.gsub(/%([a-zA-Z_][a-zA-Z0-9_]*)%|{\g<1>}/) do
          envar = Regexp.last_match 1
          value = find_windows_envar(envar, use_wslvar: use_wslvar)
          if value.to_s.empty?
            msg = "jekyll_plugin_support error: Windows environment variable %#{envar}% is undefined"
            raise JekyllPluginSupportError, msg.red, [] if die_if_undefined

            if logger
              logger.warn msg
            else
              puts msg.red
            end
          end
          value
        end
      else
        str
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

    # @param klass [Class] class instance to register
    # @param tag_name [String] name of plugin defined by klass to register as
    # @param quiet [Boolean] suppress registration message if truthy
    def self.register(klass, tag_name, quiet: false)
      abort("Error: The #{tag_name} plugin does not define VERSION") \
        unless klass.const_defined?(:VERSION)

      version = klass.const_get(:VERSION)

      abort("Error: The #{tag_name} plugin is not an instance of JekyllSupport::JekyllBlock or JekyllSupport::JekyllTag") \
        unless klass.instance_of?(Class) &&
               (klass.ancestors.include?(::JekyllSupport::JekyllBlock) ||
                klass.ancestors.include?(::JekyllSupport::JekyllTag))

      Liquid::Template.register_tag(tag_name, klass)
      return if quiet

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
