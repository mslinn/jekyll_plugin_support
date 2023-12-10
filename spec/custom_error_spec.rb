require_relative '../lib/jekyll_custom_error'
require_relative '../lib/jekyll_plugin_support_class'

class JekyllCustomErrorTest
  @tag_name = 'test_tag'
  @argument_string = 'This is the argument string'
  AnError = JekyllSupport.define_error
  AnError.class_variable_set(:@@tag_name, @tag_name) # rubocop:disable Style/ClassVars
  AnError.class_variable_set(:@@argument_string, @argument_string) # rubocop:disable Style/ClassVars

  puts "AnError is a #{AnError.class}; StandardError is a #{StandardError.class}"
  begin
    raise AnError, 'Oops'
  rescue AnError => e
    puts "Caught AnError: #{e.message}"
  rescue Jekyll::CustomError => e
    puts "Caught CustomError: #{e.message}"
  end

  RSpec.describe Jekyll::CustomError do
    it 'can create custom errors' do
      expect { raise AnError, 'Oops' }.to raise_error(AnError)
    end
  end
end
