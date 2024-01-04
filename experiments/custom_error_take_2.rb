# Attempt #2: # Use eval to create a StandardError subclass with extra attributes and methods

require 'facets/string/camelcase'
require 'facets/string/snakecase'

# Prototype StandardError subclass.
# It just needs to be created with the right class name
class CustomError < StandardError
  # These attributes are stored in the class so instances can be created with these values.
  # The stored context allows instances to be created from anywhere,
  # without having to worry about how to obtain the values in the context.
  class << self
    attr_accessor :argument_string, :line_number, :path, :tag_name
  end

  # Instance attributes; will contain the same values as the class attributes
  attr_accessor :argument_string, :line_number, :path, :tag_name

  # Creates a CustomError subclass, with the given name
  def self.factory(error_class_name)
    return if Object.const_defined? error_class_name

    Object.const_set error_class_name, Class.new(CustomError)
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

# Application code that creates the StandardError subclass with class-level context
module M2
  class C
    # Creates a CustomError subclass, not scoped within a module, with the given name
    def initialize
      @error_name = "#{self.class.name.split('::').last.camelcase(:upper)}Error" # => CError
      CustomError.factory @error_name
      # puts Object.const_defined?(:CError)
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
puts "defined? CError                => #{defined? CError}" # => "constant"
puts "Object.const_defined? 'CError' => #{Object.const_defined? :CError}" # => true

# The point of the example is to be able to establish the error context before creating any instances.
# The following would be called from JekyllTag.initialize:
c.set_error_context('blah', 123, '/', 'my_tag')

# The following represents application code.
# Creating the error copies the class-level context to the instance.
# This allows the new error class instance to behave just like any other StandardError subclass.
begin
  raise CError, 'asdf'
rescue CError => e
  puts "The class variables of #{e.class.name} are:"
  e.class.instance_variables.each do |name|
    puts "  #{name}=#{e.class.instance_variable_get name}"
  end
  puts "The instance variables of #{e.class.name} are:"
  e.instance_variables.each do |name|
    puts "  #{name}=#{e.instance_variable_get name}"
  end
  puts <<~END_MSG
    Caught a #{e.class.name} with message #{e.message}
  END_MSG
end
