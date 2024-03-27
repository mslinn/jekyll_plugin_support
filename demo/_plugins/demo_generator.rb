require 'jekyll_plugin_support_generator'

class DemoGenerator < JekyllSupport::JekyllGenerator
  VERSION = '0.1.0'.freeze

  def generate_impl
    @logger.info { 'DemoGenerator is running.' }
  end

  register(self)
end
