# Attempt #3: # Use instance_eval to create a StandardError subclass with extra attributes and methods

require 'facets/string/camelcase'
require 'facets/string/snakecase'

# Prototype StandardError subclass.
# It just needs to be created with the right class name
module M1
  class CustomError < StandardError
    # These attributes are stored in the class so instances to store Jekyll context.
    # The stored context allows subclasses to be created by any code,
    # without having to worry about how to obtain the values in the context.
    class << self
      attr_accessor :argument_string, :line_number, :path, :tag_name
      # attr_writer :name # So the name can be changed
    end

    # Instance attributes; will contain the same values as the class attributes
    attr_accessor :argument_string, :line_number, :path, :tag_name

    def self.factory(error_class_name)
      return if Object.const_defined? error_class_name

      puts "Defining #{error_class_name}"
      Class.new M1::CustomError do
        class_eval do
          Name = error_class_name
          puts name
        end
      end
    end

    # Make copies of the class attributes as instance variables
    def initialize(msg)
      super(msg)
      klass = self.class
      @argument_string = klass.argument_string
      @line_number = klass.line_number
      @path = klass.path
      @tag_name = klass.tag_name
    end
  end
end

# Application code that creates the StandardError subclass
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

# The point of the example is to be able to establish the error context before creating any instances.
# This would be called from JekyllTag.initialize
c.set_error_context('blah', 123, '/', 'my_tag')

# The following represents application code:
begin
  raise M2::CError, 'asdf'
rescue M2::CError => e
  puts "The class variables of #{e.class.name} are:"
  e.class.instance_variables.each do |name|
    puts "  #{name}=#{e.class.instance_variable_get name}"
  end
  puts "The instance variables of #{e.class.name} are:"
  e.instance_variables.each do |name|
    puts "  #{name}=#{e.instance_variable_get name}"
  end
  puts <<~END_MSG
    Caught an #{e.class.name} with message #{e.message}
  END_MSG
  # argument_string=#{e.argument_string}end
end
