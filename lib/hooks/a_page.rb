require 'jekyll_draft'

module AllCollectionsHooks
  class APage
    attr_reader :content, :data, :date, :description, :destination, :draft, :excerpt, :ext, :extname, :href,
                :label, :last_modified, :layout, :origin, :path, :relative_path, :tags, :title, :type, :url

    # @param obj can be a `Jekyll::Document` or similar
    # @param origin values: 'collection', 'individual_page', and 'static_file'
    #               (See method AllCollectionsHooks.apages_from_objects)
    def initialize(obj, origin)
      @origin = origin
      obj_field_init obj
      data_field_init obj
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

    # Contructor for testing and jekyll_outline
    def self.apage_from( # rubocop:disable Metrics/ParameterLists
      date: nil,
      draft: false,
      last_modified: nil,
      collection_name: nil,
      order: nil,
      title: nil,
      url: nil
    )
      data = {
        collection:    { label: collection_name },
        date:          Date.parse(date),
        draft:         draft,
        last_modified: Date.parse(last_modified || date),
        order:         order,
        title:         title,
      }

      APage.new_attribute obj, :data, data
      APage.new_attribute obj, :draft, draft
      APage.new_attribute obj, :extname, '.html'
      APage.new_attribute obj, :logger, PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)
      APage.new_attribute obj, :title, title
      APage.new_attribute obj, :url, url

      APage.new obj, nil
    end

    # Defines a new attribute called `prop_name` in object `obj` and sets it to `prop_value`
    def self.new_attribute(obj, prop_name, prop_value)
      obj.class.module_eval { attr_accessor prop_name }
      obj.instance_variable_set :"@#{prop_name}", prop_value
    end

    def order
      data.key?('order') ? data['order'] || FIXNUM_MAX : FIXNUM_MAX
    end

    def to_s
      @label || @date.to_s
    end

    private

    # Sets instance attributes in APage from selected key/value pairs in  `obj.data`:
    # `categories`, `date`, `description`, `excerpt`, `ext`, `last_modified` or `last_modified_at`,
    # `layout`, and `tags`.
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

    # Sets instance attributes in APage from selected attributes in `obj` (when present):
    # `content`, `destination`, `ext` and `extname`, `label` from `collection.label`,
    # `path`, `relative_path`, `type`, and `url`.
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
      @url = if @url
               "#{@url}index.html" if @url.end_with? '/'
             else
               '/'
             end
    end
  end
end
