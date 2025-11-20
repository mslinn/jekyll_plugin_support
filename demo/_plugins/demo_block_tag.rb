require 'cgi'
require 'jekyll_plugin_support'

# Use the JekyllSupport module namespace so the self methods are automajically found
module JekyllSupport
  DemoBlockError = JekyllSupport.define_error

  class DemoBlock < JekyllBlock
    VERSION = '0.1.2'.freeze

    def render_impl(text)
      @demo_block_error = @helper.parameter_specified? 'raise_demo_block_error'
      @keyword1         = @helper.parameter_specified? 'keyword1'
      @keyword2         = @helper.parameter_specified? 'keyword2'
      @name1            = @helper.parameter_specified? 'name1'
      @name2            = @helper.parameter_specified? 'name2'
      @standard_error   = @helper.parameter_specified? 'raise_standard_error'

      if @tag_config
        @die_on_demo_block_error = @tag_config['die_on_demo_block_error'] == true
        @die_on_standard_error   = @tag_config['die_on_standard_error'] == true
      end

      raise DemoBlockTagError, 'This DemoBlockTagError error is expected.' if @demo_block_error
      raise StandardError, 'This StandardError error is expected.' if @standard_error

      # _infinity = 1 / 0 if @standard_error # Not required

      output text
    rescue DemoBlockTagError => e # jekyll_plugin_support handles StandardError
      @logger.error { e.logger_message }
      exit! 1 if (e.message != 'This DemoBlockTagError error is expected.') && @die_on_demo_block_error
      e.html_message
    end

    private

    def output(text)
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

        @helper.remaining_markup='#{@helper.remaining_markup}'

        @envs=#{@envs.keys.sort.join(', ')}

        @raw_content=
          #{@raw_content ? "Length: #{@raw_content.length}, Type: #{@raw_content.class}, Preview: #{CGI.escapeHTML(@raw_content[0..100])}" : "Not available"}

        @highlighter_prefix='#{@highlighter_prefix}'

        @highlighter_suffix='#{@highlighter_suffix}'

        @config['url']='#{@config['url']}'

        @site.collection_names=#{@site.collection_names&.sort&.join(', ')}

        @page['description']=#{@page['description']}

        @page['path']=#{@page['path']}

        @keyword1=#{@keyword1}

        @keyword2=#{@keyword2}

        @name1=#{@name1}

        @name2=#{@name2}

        text=#{text}</pre>
      END_OUTPUT
    end

    JekyllPluginHelper.register(self, 'demo_block_tag')
  end
end
