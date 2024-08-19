require 'facets/string/camelcase'
require 'facets/string/snakecase'

module JekyllSupport
  # Use like this:
  # CustomError.new(:MyError, 'blah', 'asdf')
  class CustomError < StandardError
    def self.factory(error_class_name)
      return if Object.const_defined? "::#{error_class_name}"

      Object.const_set error_class_name, Class.new(CustomError)
    end

    def error_name
      self.class.name.split('::').last
    end

    def calling_file
      file_fq, _line_number, _extra = backtrace[0]&.split(':')
      file_fq
    end

    # @return HTML <div> tag with class set to the snake_case version of the error class name.
    def html_message
      shorten_backtrace
      path, line_number, _caller = backtrace[1]&.split(':')
      <<~END_MSG
        <div class='#{error_name.snakecase}'>
          #{self.class} raised in #{calling_file} while processing line #{line_number} (after front matter) of #{path}
          #{message}
        </div>
      END_MSG
    end

    def logger_message
      shorten_backtrace
      kaller = caller(1..1).first
      path, line_number, _caller = backtrace[1]&.split(':')
      <<~END_MSG
        #{error_name} raised in #{kaller} while processing line #{line_number} (after front matter) of #{path}
          #{message}
      END_MSG
    end

    def shorten_backtrace(backtrace_element_count = 3)
      b = backtrace[0..backtrace_element_count - 1].map do |x|
        x.gsub(Dir.pwd + '/', './')
      end
      set_backtrace b
    end
  end
end
