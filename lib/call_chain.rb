# TODO: File not used, delete

# See https://stackoverflow.com/a/23363883/553865
module CallChain
  ACaller = Struct.new(:filepath, :line, :method_name)

  def self.caller_method(depth = 1)
    parse_caller(caller(depth + 1).first).method_name
  end

  def self.parse_caller(at)
    return unless /^(.+?):(\d+)(?::in `(.*)')?/ =~ at

    last_match = Regexp.last_match.to_a
    ACaller.new(
      last_match[1],
      last_match[2].to_i,
      last_match[3]
    )
  end

  # Return ACaller prior to jekyll_plugin_support
  def self.jpsh_subclass_caller
    state = :nothing_found
    call_sequence = caller
    call_sequence.each do |caller_|
      parsed_caller = parse_caller caller_
      filepath = parsed_caller.filepath
      dirname = File.dirname filepath
      jpsh = dirname.match? %r{jekyll_plugin_support[.0-9-]*/lib\z}
      liquid = dirname.match? %r{liquid[.0-9-]*/lib/\z}
      case state
      when :nothing_found
        state = :jpsh_found if jpsh
      when :jpsh_found
        # puts "Called from #{parsed_caller.filepath}, on line #{parsed_caller.line}, by method '#{parsed_caller.method_name}'" unless jpsh
        return parsed_caller unless jpsh || liquid
      end
    end
    nil
  end
end
