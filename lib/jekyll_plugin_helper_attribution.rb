# Attribution aspect of JekyllPluginHelper
class JekyllPluginHelper
  # @param file must be a fully qualified file name that points to a file within a gem.
  # @return Gem::Specification of gem that file points into, or nil if not called from a gem
  # See https://stackoverflow.com/a/75890279/553865
  def self.current_spec(file)
    abort 'JekyllPluginHelper::current_spec: file is nil' if file.nil?
    return nil unless File.exist?(file)

    searcher = if Gem::Specification.respond_to?(:find)
                 Gem::Specification
               elsif Gem.respond_to?(:searcher)
                 Gem.searcher.init_gemspecs
               end

    searcher&.find do |spec|
      file.start_with? spec.full_gem_path
    end
  end

  def attribute
    return unless @current_gem

    <<~END_OUTPUT
      <div id="jps_attribute_#{rand(999_999)}" class="jps_attribute">
        <div>
          <a href="#{@homepage}" target="_blank" rel="nofollow">
            #{attribution_string}
          </a>
        </div>
      </div>
    END_OUTPUT
  end

  def default_attribution
    authors = @authors&.join(', ')
    result = "Generated by the \#{@name} v\#{@version} Jekyll plugin"
    result << ", written by #{authors}" if authors
    result << " \#{@published_date}" if @published_date
    result << '.'
    result
  end

  # Sets @current_gem if file points at a uniquely named file within a gem.
  # @param file must be a fully qualified file name in a gem, for example: __FILE__
  def gem_file(file)
    @current_gem = JekyllPluginHelper.current_spec file
    @logger.debug "No gem found for '#{file} was found." unless @current_gem
    annotate_globals if @attribution && @current_gem
  end

  private

  def annotate_globals
    return unless @current_gem

    @name           = @current_gem.name
    @authors        = @current_gem.authors
    @homepage       = @current_gem.homepage
    @published_date = @current_gem.date.to_date.to_s
    @version        = @current_gem.version
  end

  def attribution_string
    string = if @attribution == true
               default_attribution
             else
               @attribution
             end
    String.interpolate { string }
  end
end