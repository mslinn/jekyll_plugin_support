require 'jekyll_plugin_support'

module Jekyll
  class DemoTag < JekyllSupport::JekyllTag
    VERSION = '0.1.1'.freeze

    def render_impl
      @keyword1  = @helper.parameter_specified? 'keyword1'
      @keyword2  = @helper.parameter_specified? 'keyword2'
      @name1  = @helper.parameter_specified? 'name1'
      @name2  = @helper.parameter_specified? 'name2'

      <<~END_OUTPUT
        <pre>@helper.tag_name=#{@helper.tag_name}

        @mode=#{@mode}

        # Passed into Liquid::Tag.initialize
        @argument_string="#{@argument_string}"

        @helper.argv=
          #{@helper.argv.join("\n  ")}

        # Liquid variable name/value pairs
        @helper.params=
          #{@helper.params.join(', ')}

        @config['url']='#{@config['url']}'

        @helper.keys_values=
        #{(@helper.keys_values.map { |k, v| "  #{k}=#{v}\n" }).join("  \n")}

        @site=#{@site}

        @page['description']=#{@page['description']}

        @page['path']=#{@page['path']}

        @keyword1=#{@keyword1}

        @keyword2=#{@keyword2}

        @name1=#{@name1}

        @name2=#{@name2}

        @envs=#{@envs.keys.join(' ')}</pre>
      END_OUTPUT
    end

    JekyllPluginHelper.register(self, 'demo_tag')
  end
end
