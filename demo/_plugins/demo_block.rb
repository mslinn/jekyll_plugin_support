require 'jekyll_plugin_support'

module Jekyll
  class DemoBlock < JekyllSupport::JekyllBlock
    VERSION = '0.1.1'.freeze

    def render_impl(text)
      @keyword1  = @helper.parameter_specified? 'keyword1'
      @keyword2  = @helper.parameter_specified? 'keyword2'
      @name1  = @helper.parameter_specified? 'name1'
      @name2  = @helper.parameter_specified? 'name2'

      <<~END_OUTPUT
        #{@helper.attribute if @helper.attribution}
        <pre>@helper.tag_name=#{@helper.tag_name}

        @helper.attribution=#{@helper.attribution}
        @helper.attribute=#{@helper.attribute}

        @mode=#{@mode}

        # Passed into Liquid::Block.initialize
        @argument_string="#{@argument_string}"

        @helper.argv=
          #{@helper.argv.join("\n  ")}

        # Liquid variable name/value pairs
        @helper.params=
          #{@helper.params&.join(', ')}

        @helper.remaining_markup='#{@helper.remaining_markup}'

        @helper.keys_values=
        #{(@helper.keys_values.map { |k, v| "  #{k}=#{v}\n" })&.join("  \n")}

        @config['url']='#{@config['url']}'

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
