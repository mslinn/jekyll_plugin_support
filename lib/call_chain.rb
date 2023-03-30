# See https://stackoverflow.com/a/23363883/553865
module CallChain
  def self.caller_method(depth = 1)
    parse_caller(caller(depth + 1).first).last
  end

  def self.parse_caller(at)
    return unless /^(.+?):(\d+)(?::in `(.*)')?/ =~ at

    file   = Regexp.last_match[1]
    line   = Regexp.last_match[2].to_i
    method = Regexp.last_match[3]
    [file, line, method]
  end
end

if __FILE__ == $PROGRAM_NAME
  caller = CallChain.caller_method
  puts caller
end
