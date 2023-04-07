# See https://stackoverflow.com/a/75890279/553865
module GemSupport
  # @param file must be a fully qualified file name that points to a file within a gem.
  # @return Gem::Specification of gem that file points into, or nil if not called from a gem
  def self.current_spec(file)
    return nil unless file.exist?

    searcher = if Gem::Specification.respond_to?(:find)
                 Gem::Specification
               elsif Gem.respond_to?(:searcher)
                 Gem.searcher.init_gemspecs
               end

    searcher&.find do |spec|
      file.start_with? spec.full_gem_path
    end
  end
end
