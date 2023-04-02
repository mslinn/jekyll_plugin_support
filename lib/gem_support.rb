module GemSupport
  # @return Gem::Specification of gem @ file, or nil if not called from a gem
  def self.current_spec(file)
    searcher = if Gem::Specification.respond_to?(:find)
                 Gem::Specification
               elsif Gem.respond_to?(:searcher)
                 Gem.searcher.init_gemspecs
               end

    searcher&.find do |spec|
      spec.name == file
    end
  end
end
