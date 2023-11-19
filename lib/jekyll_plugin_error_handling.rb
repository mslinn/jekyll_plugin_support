module JekyllSupportErrorHandling
  attr_reader :logger, :page

  # If a Jekyll plugin needs to crash exit, and stop Jekyll, call this method.
  # It does not generate a stack trace.
  # This method does not return because the process is abruptly terminated.
  #
  # @param error StandardError or a subclass of StandardError is required
  #
  # Do not raise the error before calling this method, just create it via 'new', like this:
  # exit_without_stack_trace StandardError.new('This is my error message')
  #
  # If you want to call this method from a handler method, the default index for the backtrace array must be specified.
  # The default backtrace index is 1, which means the calling method.
  # To specify the calling method's caller, pass in 2, like this:
  # exit_without_stack_trace StandardError.new('This is my error message'), 2
  def exit_without_stack_trace(error, caller_index = 1)
    raise error
  rescue StandardError => e
    file, line_number, caller = e.backtrace[caller_index].split(':')
    caller = caller.tr('`', "'")
    warn "#{error.msg} #{caller} on line #{line_number} (after front matter) of #{file}".red
    # Process.kill('HUP', Process.pid) # generates huge stack trace
    exec "echo ''"
  end

  def format_error_message(message)
    page = " of #{@page['path']}" if @page
    remove_ansi_color "on line #{line_number} (after front matter)#{page}.\n#{message}"
  end

  def remove_ansi_color(string)
    string.gsub(/\e\[([;\d]+)?m/, '')
  end

  def maybe_reraise_error(error, throw_error: true)
    fmsg = format_error_message "#{error.class}: #{error.message.strip}"
    @logger.error { fmsg }
    return "<span class='jekyll_plugin_support_error'>#{fmsg}</span>" unless throw_error

    error.set_backtrace error.backtrace[0..9]
    raise error
  end

  def warn_short_trace(error)
    JekyllSupport.warn_short_trace(@logger, error)
  end
end
