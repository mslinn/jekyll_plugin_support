require 'colorator'
require 'jekyll'
require 'jekyll_plugin_logger'
require_relative 'jekyll_plugin_helper'
require_relative 'jekyll_plugin_support/version'

module NoArgParsing
  attr_accessor :no_arg_parsing

  @no_arg_parsing = true
end

require_relative 'jekyll_plugin_support_class'
require_relative 'jekyll_plugin_support_block'
require_relative 'jekyll_plugin_support_block_noarg'
require_relative 'jekyll_plugin_support_tag'
require_relative 'jekyll_plugin_support_tag_noarg'
require_relative 'jekyll_custom_error'
