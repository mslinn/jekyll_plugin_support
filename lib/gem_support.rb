module GemSupport
  # @param file must be a fully qualified file name, for example: __FILE__.
  # @return Gem::Specification of gem @ file, or nil if not called from a gem
  def self.current_spec(file)
    searcher = if Gem::Specification.respond_to?(:find)
                 Gem::Specification
               elsif Gem.respond_to?(:searcher)
                 Gem.searcher.init_gemspecs
               end

    searcher&.find do |spec|
      File.fnmatch(File.join(spec.full_gem_path, '**'), file)
      # spec.name == file.delete_suffix('.rb')
    end
  end
end
