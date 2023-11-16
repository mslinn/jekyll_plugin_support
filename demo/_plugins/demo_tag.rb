require 'cgi'
require 'jekyll_plugin_support'

CustomError = Class.new(Liquid::Error)

module Jekyll
  class DemoTag < JekyllSupport::JekyllTag
    VERSION = '0.1.2'.freeze

    def render_impl
      @boom     = @helper.parameter_specified? 'boom'
      @keyword1 = @helper.parameter_specified? 'keyword1'
      @keyword2 = @helper.parameter_specified? 'keyword2'
      @name1    = @helper.parameter_specified? 'name1'
      @name2    = @helper.parameter_specified? 'name2'

      config = @config['demo_tag']
      if config
        @die_on_custom_error = config['die_on_custom_error'] == true
        @die_on_run_error = config['die_on_run_error'] == true
      end

      raise CustomError, "#{@page['path']} #{@boom}".red, [] if @boom

      output
    rescue CustomError => e
      e.set_backtrace e.backtrace[0..9]
      @logger.error e.message
      raise e if @die_on_custom_error

      "<span class='demo_tag_error'>StandardError: #{e.full_message}</span>"
    rescue StandardError => e
      e.set_backtrace e.backtrace[0..9]
      msg = format_error_message e.full_message
      @logger.error msg
      raise e if @die_on_custom_error

      "<span class='demo_tag_error'>StandardError: #{msg}</span>"
    end

    private

    def output
      <<~END_OUTPUT
        <pre>@helper.tag_name=#{@helper.tag_name}

        @mode=#{@mode}

        # Passed into Liquid::Tag.initialize
        @argument_string="#{@argument_string}"

        @helper.argv=
          #{@helper.argv&.join("\n  ")}

        # Liquid variable name/value pairs
        @helper.params=
          #{@helper.params&.map { |k, v| "#{k}=#{v}" }&.join("\n  ")}

        @helper.keys_values=
          #{(@helper.keys_values&.map { |k, v| "#{k}=#{v}" })&.join("\n  ")}

        remaining_markup='#{@helper.remaining_markup}'

        @envs=#{@envs.keys.sort.join(', ')}

        @config['url']='#{@config['url']}'

        @site.collection_names=#{@site.collection_names&.sort&.join(', ')}

        @page['description']=#{@page['description']}

        @page['path']=#{@page['path']}

        @keyword1=#{@keyword1}

        @keyword2=#{@keyword2}

        @name1=#{@name1}

        @name2=#{@name2}</pre>
      END_OUTPUT
    end

    JekyllPluginHelper.register(self, 'demo_tag')
  end
end
