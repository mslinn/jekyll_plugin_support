require_relative 'demo_inline_tag'

# Use the JekyllSupport module namespace so the self methods are automajically found
module JekyllSupport
  redef_without_warning 'VERSION', '0.1.0'.freeze

  class SubclassTag < JekyllSupport::DemoTag
    def render_impl
      @magic_word = @helper.parameter_specified? 'magic_word'
      @demo_tag_error = @helper.parameter_specified? 'raise_subclass_demo_tag_error'
      @standard_error = @helper.parameter_specified? 'raise_standard_error'

      if @tag_config
        @die_on_demo_tag_error = @tag_config['die_on_demo_tag_error'] == true
        @die_on_standard_error = @tag_config['die_on_standard_error'] == true
      end

      raise SubclassDemoInlineTagError, 'Fall down, go boom.' if @demo_tag_error

      _infinity = 1 / 0 if @standard_error

      output
    rescue SubclassDemoInlineTagError => e
      e.shorten_backtrace
      @logger.error e.logger_message
      raise e if @die_on_subclass_demo_tag_error

      e.html_message
    end

    private

    def output
      <<~END_OUTPUT
        <p>
          The magic word for <code>subclass_demo_inline_tag</code> version #{VERSION} is <b>#{@magic_word}</b>.
        </p>
      END_OUTPUT
    end

    JekyllPluginHelper.register(self, 'subclass_demo_inline_tag')
  end
end
