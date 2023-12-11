# Now the problem:

require 'facets/string/camelcase'
require 'facets/string/snakecase'

module M1
  class CustomError < StandardError
    class << self
      attr_accessor :argument_string, :line_number, :path, :tag_name
    end

    def self.factory(name)
      return if Object.const_defined? name

      puts "Defining #{name}"
      eval "#{name} = Class.new M1::CustomError" # rubocop:disable Style/EvalWithLocation, Security/Eval
    end
  end
end

module M2
  class C
    def initialize
      @error_name = "#{self.class.name.camelcase(:upper)}Error" # => CError
      M1::CustomError.factory @error_name
    end

    def set_error_context(argument_string, line_number, path, tag_name)
      error_class = Object.const_get @error_name
      error_class.argument_string = argument_string
      error_class.line_number = line_number
      error_class.path = path
      error_class.tag_name = tag_name
    end
  end
end

c = M2::C.new                  # => Defining M2::CError
puts "c is an #{c.class.name}" # => c is an M2::C
puts "defined? M2::CError                => #{defined? M2::CError}"                # => "constant"
puts "Object.const_defined? 'M2::CError' => #{Object.const_defined? 'M2::CError'}" # => true

c.set_error_context('blah', 123, '/', 'my_tag')

begin
  raise M2::CError, 'asdf'
rescue M2::CError => e
  puts "The class variables of #{e.class.name} are:"
  e.class.instance_variables.each do |name|
    puts "  #{name}=#{e.class.instance_variable_get name}"
  end
  puts <<~END_MSG
    Caught an #{e.class.name} with message #{e.message}
  END_MSG
  # argument_string=#{e.argument_string}end
end
