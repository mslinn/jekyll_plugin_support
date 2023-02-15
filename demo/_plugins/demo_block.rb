require 'jekyll_plugin_support'

module Jekyll
  class DemoBlock < JekyllSupport::JekyllBlock
    VERSION = '0.1.0'

    def render_impl(text)
      @keyword1  = @helper.parameter_specified? 'keyword1'
      @keyword2  = @helper.parameter_specified? 'keyword2'
      @name1  = @helper.parameter_specified? 'name1'
      @name2  = @helper.parameter_specified? 'name2'

      <<~END_OUTPUT
        <pre>@helper.tag_name=#{@helper.tag_name}

        @mode=#{@mode}

        # Passed into Liquid::Block.initialize
        @argument_string="#{@argument_string}"

        @helper.argv=
          #{@helper.argv.join("\n  ")}

        # Liquid variable name/value pairs
        @helper.params=
          #{@helper.params.join(', ')}

        @config['url']='#{@config['url']}'

        @helper.keys_values=
        #{(@helper.keys_values.map { |k, v| "  #{k}=#{v}\n" }).join("  \n")}

        @site.url=# {@site.url}

        @page['description']=#{@page['description']}

        @page['path']=#{@page['path']}

        @keyword1=#{@keyword1}

        @keyword2=#{@keyword2}

        @name1=#{@name1}

        @name2=#{@name2}

        text='#{text}'

        @envs=#{@envs.keys.join(' ')}</pre>
      END_OUTPUT
    end

    JekyllPluginHelper.register(self, 'demo_block')
  end
end
