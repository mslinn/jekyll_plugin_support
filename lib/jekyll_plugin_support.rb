def require_directory(dir)
  Dir[File.join(dir, '*.rb')]&.sort&.each do |file|
    require file unless file == __FILE__
  end
end

require 'colorator'
require 'jekyll'
require 'jekyll_plugin_logger'
require 'pry'
require 'sorted_set'

# require_directory __dir__
require_directory "#{__dir__}/util"
require_directory "#{__dir__}/error"
require_directory "#{__dir__}/block"
require_directory "#{__dir__}/generator"
require_directory "#{__dir__}/helper"
require_directory "#{__dir__}/jekyll_plugin_support"
require_directory "#{__dir__}/tag"
require_directory "#{__dir__}/jekyll_all_collections"
require_directory "#{__dir__}/hooks"

module JekyllSupport
  def self.redef_without_warning(const, value)
    send(:remove_const, const) if const_defined?(const)
    const_set const, value
  end
end

module NoArgParsing
  attr_accessor :no_arg_parsing

  @no_arg_parsing = true
end

module JekyllSupport
  class JekyllTag
    include JekyllSupportError
  end

  class JekyllTagNoArgParsing
    include JekyllSupportError
  end

  class JekyllBlock
    include JekyllSupportError
  end

  class JekyllBlockNoArgParsing
    include JekyllSupportError
  end
end
