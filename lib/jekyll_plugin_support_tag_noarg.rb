module JekyllSupport
  class JekyllTagNoArgParsing < JekyllTag
    def initialize(tag_name, argument_string, parse_context)
      class << self
        include NoArgParsing
      end

      super
      @logger.debug { "#{self.class}: respond_to?(:no_arg_parsing) #{respond_to?(:no_arg_parsing) ? 'yes' : 'no'}." }
    end

    def format_error_message(message)
      "on line #{line_number} (after front matter) of #{@page['path']}.\n#{message}"
    end

    def maybe_reraise_error(error, throw_error: true)
      fmsg = format_error_message "#{error.class}: #{error.message.strip}"
      @logger.error { fmsg }
      return "<span class='jekyll_plugin_support_error'>#{fmsg}</span>" unless throw_error

      error.set_backtrace error.backtrace[0..9]
      raise error
    end
  end
end
