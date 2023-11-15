module JekyllSupport
  class JekyllBlockNoArgParsing < JekyllBlock
    def initialize(tag_name, argument_string, parse_context)
      class << self
        include NoArgParsing
      end

      super
      @logger.debug { "#{self.class}: respond_to?(:o_arg_parsing) #{respond_to?(:no_arg_parsing) ? 'yes' : 'no'}." }
    rescue StandardError => e
      @logger.error { "#{self.class} died with a #{e.full_message}" }
      JekyllSupport.error_short_trace(@logger, e)
    end

    def warn_short_trace(error)
      JekyllSupport.warn_short_trace(@logger, error)
    end
  end
end
