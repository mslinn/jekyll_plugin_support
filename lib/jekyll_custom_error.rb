require 'facets/string/camelcase'
require 'facets/string/snakecase'

module Jekyll
  # Use like this:
  # CustomError.new(:MyError, 'blah', 'asdf')
  class CustomError < StandardError
    def self.factory(name)
      return if Object.const_defined? name

      puts "Defining #{name}".yellow
      eval "#{name} = Class.new Jekyll::CustomError" # rubocop:disable Style/EvalWithLocation, Security/Eval
    end

    def error_name
      self.class.name.split('::').last
    end

    def calling_file
      file_fq, _line_number, _extra = backtrace[0].split(':')
      file_fq
    end

    # @return HTML <div> tag with class set to the snake_case version of the error class name.
    def html_message
      shorten_backtrace
      line_number = self.class.class_variable_get :@@line_number
      path = self.class.class_variable_get :@@path
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
      line_number = self.class.class_variable_get :@@line_number
      path = self.class.class_variable_get :@@path
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
