module Jekyll
  # Use like this:
  # CustomError.new(:MyError, 'blah', 'asdf')
  class CustomError < StandardError
    def to_html
      kaller = caller(1..1).first.class
      <<~END_MSG
        <div class='#{self.class.name.demodulize}_error'>
          #{self.class} raised in #{kaller} on line #{@@line_number} (after front matter) of #{@@path}
          #{@msg}
        </div>
      END_MSG
    end

    def to_s
      kaller = caller(1..1).first.class
      <<~END_MSG
        #{self.class} raised in #{kaller} on line #{@@line_number} (after front matter) of #{@@path}
          #{@msg}
      END_MSG
    end
  end
end
