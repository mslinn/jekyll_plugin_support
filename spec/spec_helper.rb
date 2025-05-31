require 'jekyll'
require_relative '../lib/jekyll_plugin_support'

Jekyll.logger.log_level = :info

RSpec.configure do |config|
  config.color = true

  # See https://relishapp.com/rspec/rspec-core/docs/command-line/only-failures
  config.example_status_persistence_file_path = 'spec/status_persistence.txt'

  config.filter_run_when_matching focus:
                                         config.formatter = :documentation # :progress, :html, :json, CustomFormatterClass
  # config.order = 'random'

  # See https://www.rubydoc.info/github/rspec/rspec-core/RSpec%2FCore%2FConfiguration:pending_failure_output
  config.pending_failure_output = :skip

  config.tty = true
end
