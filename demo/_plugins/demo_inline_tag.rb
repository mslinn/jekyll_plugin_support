require 'jekyll_plugin_support'

module Jekyll
  DemoTagError = JekyllSupport.define_error

  class DemoTag < JekyllSupport::JekyllTag
    VERSION = '0.1.2'.freeze

    def render_impl
      @demo_tag_error = @helper.parameter_specified? 'raise_demo_tag_error'
      @keyword1       = @helper.parameter_specified? 'keyword1'
      @keyword2       = @helper.parameter_specified? 'keyword2'
      @name1          = @helper.parameter_specified? 'name1'
      @name2          = @helper.parameter_specified? 'name2'
      @standard_error = @helper.parameter_specified? 'raise_standard_error'

      if @tag_config
        @die_on_demo_tag_error = @tag_config['die_on_demo_tag_error'] == true
        @die_on_standard_error = @tag_config['die_on_standard_error'] == true
      end

      raise DemoTagError, 'Fall down, go boom.' if @demo_tag_error

      _infinity = 1 / 0 if @standard_error

      output
    rescue DemoTagError => e # jekyll_plugin_support handles StandardError
      e.shorten_backtrace
      msg = format_error_message e.message
      @logger.error "#{e.class} raised #{msg}"
      raise e if @die_on_demo_tag_error

      "<div class='demo_tag_error'>#{e.class} raised in #{self.class};\n#{msg}</div>"
    end

    private

    def output
      <<~END_OUTPUT
        <pre>@helper.tag_name=#{@helper.tag_name}

        @mode=#{@mode}

        # jekyll_plugin_support becomes able to perform variable substitution after this variable is defined.
        # The value could be updated at a later stage, but no need to add that complexity unless there is a use case.
        @argument_string="#{@argument_string}"

        @helper.argv=
          #{@helper.argv&.join("\n  ")}

        # Liquid variable name/value pairs
        @helper.params=
          #{@helper.params&.map { |k, v| "#{k}=#{v}" }&.join("\n  ")}

        # The keys_values property serves no purpose any more, consider it deprecated
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

    JekyllPluginHelper.register(self, 'demo_inline_tag')
  end
end
