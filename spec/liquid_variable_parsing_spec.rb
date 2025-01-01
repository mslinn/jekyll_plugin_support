require 'jekyll_plugin_logger'
require 'rspec/match_ignoring_whitespace'
require_relative '../lib/jekyll_plugin_support'
require_relative '../lib/jekyll_plugin_support_spec_support'

class LiquidVariableParsing
  # @return copy of str with references to defined variables replaced by the values of the variables
  def variable_replace(str, scopes)
    result = str.clone
    match_data_list = str.to_enum(:scan, /{{[a-z_][a-zA-Z_0-9]*}}/).map { Regexp.last_match }.reverse
    match_data_list&.each do |md|
      from = md.begin(0)
      to = md.end(0) - 1
      ref = str[from..to]
      name = ref[2..-3]
      scopes&.each do |scope|
        value = scope.key?(name) ? scope[name] : ref
        # puts "str=#{str}; from=#{from}; to=#{to}; name=#{name} value=#{value}"
        result[from..to] = value
      end
    end
    result
  end

  RSpec.describe JekyllPluginHelper do
    it 'substitutes variable references for values without recursion' do
      scopes = [{ 'a' => '{{', 'b' => 'asdf', 'c' => '}}' }]
      str = '{{a}}{{b}}{{c}} This should be unchanged: {{d}}'
      new_str = variable_replace(str, scopes)
      expect(str).to start_with('{{a}}')
      expect(new_str).to be('{{asdf}} This should be unchanged: {{d}}')
    end
  end
end
