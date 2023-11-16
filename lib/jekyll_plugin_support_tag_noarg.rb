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
  end
end
