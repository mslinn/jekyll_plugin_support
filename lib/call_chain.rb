require 'pathname'

# See https://stackoverflow.com/a/23363883/553865
module CallChain
  ACaller = Struct.new(:filepath, :line, :method_name)

  def self.caller_file_match(filename)
    parse_caller(caller(depth + 1).first).file
  end

  def self.caller_method(depth = 1)
    parse_caller(caller(depth + 1).first).method_name
  end

  # Return ACaller prior to jekyll_plugin_support
  def self.callers
    state = :nothing_found
    caller.each_with_index do |caller_, i|
      parsed_caller = parse_caller(caller_)
      filepath = parsed_caller.filepath
      jpsh = File.dirname(filepath).end_with?('jekyll_plugin_support/lib') && \
             File.basename(filepath) == 'jekyll_plugin_support_helper.rb'
      case state
      when :nothing_found
        state = :jpsh_found if jpsh
      when :jpsh_found
        puts "#{parsed_caller.filepath} line #{parsed_caller.line} #{parsed_caller.method_name}" unless jpsh
        return parsed_caller unless jpsh
      end
    end
  end

  def self.parse_caller(at)
    return unless /^(.+?):(\d+)(?::in `(.*)')?/ =~ at

    ACaller.new(
      Regexp.last_match[1],
      Regexp.last_match[2].to_i,
      Regexp.last_match[3]
    )
  end
end

if __FILE__ == $PROGRAM_NAME
  caller = CallChain.caller_method
  puts caller
end
