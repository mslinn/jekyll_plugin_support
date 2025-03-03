Registers = Struct.new(:page, :site) unless defined?(Registers)

# Mock for Collections
class Collections
  def values
    []
  end
end

# Mock for Site
class SiteMock
  attr_reader :config

  def collections
    Collections.new
  end
end

# Mock for Liquid::ParseContent
class TestParseContext < Liquid::ParseContext
  attr_reader :line_number, :registers

  # rubocop:disable Layout/CommentIndentation
  # def initialize
    # super
    # @line_number = 123

    # @registers = Registers.new(
    #   { 'path' => 'https://feeds.soundcloud.com/users/soundcloud:users:7143896/sounds.rss' },
    #   SiteMock.new
    # )
  # end
  # rubocop:enable Layout/CommentIndentation
end
