require_relative '../lib/error/jekyll_custom_error'
require_relative '../lib/jekyll_plugin_support/jekyll_plugin_support_class'
require_relative '../lib/helper/jekyll_plugin_helper'

class Dummy
  def just_for_testing; end
end

class CustomErrorSpec
  tag_name = 'test_tag'
  argument_string = 'This is the argument string'
  AnError = ::JekyllSupport.define_error
  AnError.class_variable_set(:@@tag_name, tag_name)
  AnError.class_variable_set(:@@argument_string, argument_string)

  puts "AnError is a #{AnError.class}; StandardError is a #{StandardError.class}"
  begin
    raise AnError, 'This error is expected'
  rescue AnError => e
    puts "Caught AnError: #{e.message}"
  rescue ::JekyllSupport::CustomError => e
    puts "Caught CustomError: #{e.message}"
  end

  RSpec.describe ::JekyllSupport::JekyllPluginHelper do
    it 'generates messages' do
      msg = described_class.generate_message(Dummy, tag_name, '0.1.0')
      puts msg
      expect(msg).to include('Error class: DummyError')
      expect(msg).to include('CSS class for error messages: dummy_error')
      expect(msg).to include('die_on_dummy_error: false')
    end
  end

  RSpec.describe ::JekyllSupport::CustomError do
    it 'can create custom errors' do
      expect { raise AnError, 'Oops' }.to raise_error(AnError)
    end
  end
end
