require 'jekyll_plugin_support'

# Use the JekyllSupport module namespace so the self methods are automajically found
module JekyllSupport
  DemoInlineTagError = JekyllSupport.define_error

  class DemoTag < JekyllTag
    VERSION = '0.1.2'.freeze
    # JekyllSupport.redef_without_warning 'VERSION', '0.1.2'.freeze

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

      raise DemoInlineTagError, 'This DemoInlineTagError error is expected.' if @demo_tag_error
      raise StandardError, 'This StandardError error is expected.' if @standard_error

      # _infinity = 1 / 0 if @standard_error # Not required

      output
    rescue NoMethodError, DemoInlineTagError => e # jekyll_plugin_support handles StandardError
      @logger.error { e.logger_message }
      exit! 1 if (e.message != 'This DemoBlockTagError error is expected.') && @die_on_demo_block_error

      e.html_message
    end

    private

    def output
      <<~END_OUTPUT
        <pre># jekyll_plugin_support becomes able to perform variable substitution after this variable is defined.
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

        @raw_content=
          #{@raw_content ? "Length: #{@raw_content.length}, Type: #{@raw_content.class}, Preview: #{@raw_content[0..100].to_s.gsub("\n", '\n')}" : "Not available"}

        @highlighter_prefix='#{@highlighter_prefix}'

        @highlighter_suffix='#{@highlighter_suffix}'

        @layout='#{@layout}'
        @page.keys='#{@page.keys}'

        remaining_markup='#{@helper.remaining_markup}'

        @keyword1='#{@keyword1}'
        @keyword2='#{@keyword2}'
        @name1='#{@name1}'
        @name2='#{@name2}'</pre>
      END_OUTPUT
    end

    JekyllPluginHelper.register(self, 'demo_inline_tag')
  end
end
