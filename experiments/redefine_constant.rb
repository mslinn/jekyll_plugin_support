puts "Using Ruby #{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"

puts "Object.const_defined?(:PLUGIN_NAME) = #{Object.const_defined?(:PLUGIN_NAME)}"

module ModuleExploration
  PLUGIN_NAME = 'OldValue'.freeze
  puts '*** Exploration ***'
  puts "PLUGIN_NAME = #{PLUGIN_NAME}"
  puts "self        = #{self}"
  puts "self.class  = #{self.class}"
  puts
  puts "const_defined?(:PLUGIN_NAME) = #{const_defined?(:PLUGIN_NAME)}"
  puts "self.class.const_defined?(:PLUGIN_NAME) = #{self.class.const_defined?(:PLUGIN_NAME)}"
  puts "Module.nesting&.any? { |m| m.const_defined?(:PLUGIN_NAME) } = #{Module.nesting&.any? { |m| m.const_defined?(:PLUGIN_NAME) }}"
  puts "Object.const_defined?(:PLUGIN_NAME) = #{Object.const_defined?(:PLUGIN_NAME)}"
  puts

  def redef_without_warning(const, value)
    puts "const_defined?(#{const})       = #{const_defined?(const)}"
    puts "self.const_defined?(:PLUGIN_NAME) = #{const_defined?(:PLUGIN_NAME)}"
    puts "self.class.const_defined?(:PLUGIN_NAME) = #{self.class.const_defined?(:PLUGIN_NAME)}"
    send(:remove_const, const) if const_defined?(const)
    const_set(const, value)
  end

  module_function :redef_without_warning

  redef_without_warning :PLUGIN_NAME, 'NewValue'.freeze
  puts "\nPLUGIN_NAME = #{PLUGIN_NAME}"
end

module ModuleSolution
  PLUGIN_NAME = 'OldValue'.freeze

  def redef_without_warning(const, value)
    send(:remove_const, const) if const_defined?(const)
    const_set const, value
  end

  module_function :redef_without_warning

  puts "\nOld value for module PLUGIN_NAME = '#{PLUGIN_NAME}'"
  redef_without_warning :PLUGIN_NAME, 'NewValue'.freeze
  puts "Redefined value for module PLUGIN_NAME = '#{PLUGIN_NAME}'"
end

class ClassSolution
  PLUGIN_NAME = 'OldValue'.freeze

  def initialize
    puts "\nOld value for class PLUGIN_NAME = '#{PLUGIN_NAME}'"
    redef_without_warning :PLUGIN_NAME, 'NewValue'.freeze
    puts "Redefined value for class PLUGIN_NAME = '#{PLUGIN_NAME}'"
  end

  def redef_without_warning(const, value)
    send(:remove_const, const) if Object.constants.include?(const)
    self.class.const_set const, value
  end
end

ClassSolution.new
