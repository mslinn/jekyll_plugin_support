module AllCollectionsHooks
  class APage
    attr_reader :content, :data, :date, :description, :destination, :draft, :excerpt, :ext, :extname, :href,
                :label, :last_modified, :layout, :origin, :path, :relative_path, :tags, :title, :type, :url

    def initialize(obj, origin)
      @origin = origin
      data_field_init obj
      obj_field_init obj
      @draft = Jekyll::Draft.draft? obj
      @href = @url if @href.nil?
      # @href = "/#{@href}" if @origin == 'individual_page'
      @href = "#{@href}index.html" if @href.end_with? '/'
      @name = File.basename(@href)
      @title = if @data&.key?('title')
                 @data['title']
               elsif obj.respond_to?(:title)
                 obj.title
               else
                 "<code>#{@href}</code>"
               end
    rescue StandardError => e
      JekyllSupport.error_short_trace(@logger, e)
      # JekyllSupport.warn_short_trace(@logger, e)
    end

    def to_s
      @label || @date.to_s
    end

    private

    def data_field_init(obj)
      return unless obj.respond_to? :data

      @data = obj.data

      @categories = @data['categories'] if @data.key? 'categories'
      @date = (@data['date'].to_date if @data&.key?('date')) || Date.today
      @description = @data['description'] if @data.key? 'description'
      @excerpt = @data['excerpt'] if @data.key? 'excerpt'
      @ext ||= @data['ext'] if @data.key? 'ext'
      @last_modified = @data['last_modified'] || @data['last_modified_at'] || @date
      @last_modified_field = case @data
                             when @data.key?('last_modified')
                               'last_modified'
                             when @data.key?('last_modified_at')
                               'last_modified_at'
                             end
      @layout = @data['layout'] if @data.key? 'layout'
      @tags = @data['tags'] if @data.key? 'tags'
    end

    def obj_field_init(obj)
      @content = obj.content if obj.respond_to? :content

      # TODO: What _config.yml setting should be passed to destination()?
      @destination = obj.destination('') if obj.respond_to? :destination
      @ext = obj.extname
      @extname = @ext # For compatibility with previous versions of all_collections
      @label = obj.collection.label if obj.respond_to?(:collection) && obj.collection.respond_to?(:label)
      @path = obj.path if obj.respond_to? :path
      @relative_path = obj.relative_path if obj.respond_to? :relative_path
      @type = obj.type if obj.respond_to? :type
      @url = obj.url
      @url = "#{@url}index.html" if @url.end_with? '/'
    end
  end
end
