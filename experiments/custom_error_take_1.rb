# Attempt #1: Use eval to create a StandardError subclass without any extra attributes or methods

name = 'MyError'
eval "#{name} = Class.new StandardError" # rubocop:disable Style/EvalWithLocation, Security/Eval

puts "defined? name                  => #{defined? name}"                  # => "local-variable"
puts "defined? MyError               => #{defined? MyError}"               # => "constant"
puts "defined? StandardError         => #{defined? StandardError}"         # => "constant"

puts "Object.const_defined? name     => #{Object.const_defined? name}"      # => true
puts "Object.const_defined? :MyError => #{Object.const_defined? :MyError}"  # => true
puts "Object.const_defined? :MyError => #{Object.const_defined? :MyError}" # => true

begin
  raise MyError, 'Oops'
rescue MyError => e
  puts "Got #{e.class.name} with message #{e.message}"
end
# => Got MyError with message Oops
