require 'jekyll_draft'

module JekyllSupport
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
    date = Date.parse(date) if date.instance_of?(String)
    last_modified = if last_modified.nil? || last_modified == ''
                      date
                    elsif last_modified.instance_of?(String)
                      Date.parse(last_modified)
                    end
    data = {
      collection:    { label: collection_name },
      date:          date,
      draft:         draft,
      last_modified: last_modified,
      order:         order,
      title:         title,
    }
    obj = {}
    JekyllSupport.new_attribute obj, :data, data
    JekyllSupport.new_attribute obj, :draft, draft
    JekyllSupport.new_attribute obj, :extname, '.html'
    JekyllSupport.new_attribute obj, :logger, PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)
    JekyllSupport.new_attribute obj, :title, title
    JekyllSupport.new_attribute obj, :url, url

    AllCollectionsHooks::APage.new obj, nil
  rescue StandardError => e
    puts e.full_message
  end

  # Defines a new attribute called `prop_name` in object `obj` and sets it to `prop_value`
  def self.new_attribute(obj, prop_name, prop_value)
    obj.class.module_eval { attr_accessor prop_name }
    obj.instance_variable_set :"@#{prop_name}", prop_value
  end
end

# TODO: move APage to module JekyllSupport
module AllCollectionsHooks
  FIXNUM_MAX = (2**((0.size * 8) - 2)) - 1
  END_OF_DAYS = 1_000_000_000_000 # One trillion years in the future
  # Date.new is -4712-01-01

  class APage
    attr_reader :content, :data, :date, :description, :destination, :draft, :excerpt, :ext, :extname, :href,
                :label, :last_modified, :layout, :origin, :path, :relative_path, :tags, :title, :type, :url

    # @param obj can be a `Jekyll::Document` or similar
    # @param origin values: 'collection', 'individual_page', and 'static_file'
    #               (See method AllCollectionsHooks.apages_from_objects)
    def initialize(obj, origin)
      @origin = origin
      data_field_init obj # data attributes have 1st priority
      obj_field_init obj # object attributes have 2nd priority
      @data = obj.respond_to?(:data) ? obj.data : {}
      @draft   = Jekyll::Draft.draft? obj
      @url   ||= obj.url

      # @href  = "/#{@href}" if @origin == 'individual_page'
      @href  ||= obj.url || @url
      @href    = "#{@href}index.html" if @href&.end_with? '/'

      @name  ||= File.basename(@href)
      @title ||= "<code>#{@href}</code>"
    rescue StandardError => e
      ::JekyllSupport.error_short_trace(@logger, e)
    end

    # Look within @data (if the property exists), then self for the given key as a symbol or a string
    # @param key must be a symbol
    # @return value of data[key] if key exists as a string or a symbol, else nil
    def field(obj, key)
      if obj.respond_to? :data
        return obj.data[key] if obj.data.key? key

        obj.data[key.to_s] if obj.data.key? key.to_s
      else
        return obj.key if obj.respond_to? key

        return obj.call(key.to_s) if obj.respond_to? key.to_s

        return obj[key] if obj.key? key

        obj[key.to_s] if obj.key? key.to_s
      end
    end

    def order
      if data.key?('order') || data.key?(:order)
        data['order'] || data[:order]
      else
        FIXNUM_MAX
      end
    end

    def to_s
      @label || @date.to_s
    end

    private

    # Sets the following uninitialized instance attributes in APage from selected key/value pairs in `obj.data`:
    # `categories`, `date`, `description`, `excerpt`, `ext`, `last_modified` or `last_modified_at`,
    # `layout`, and `tags`.
    def data_field_init(obj)
      return unless obj.respond_to? :data

      @categories    ||= field(obj, :categories)
      @description   ||= field(obj, :description)
      @excerpt       ||= field(obj, :excerpt)
      @ext           ||= field(obj, :ext)
      @layout        ||= field(obj, :layout)
      @tags          ||= field(obj, :tags)
      @title         ||= field(obj, :title) # rubocop:disable Naming/MemoizedInstanceVariableName
    end

    # Sets the following instance attributes in APage from selected attributes in `obj` (when present):
    # `content`, `destination`, `ext` and `extname`, `label` from `collection.label`,
    # `path`, `relative_path`, `type`, and `url`.
    def obj_field_init(obj)
      @content ||= obj.content if obj.respond_to? :content

      # TODO: What _config.yml setting should be passed to destination()?
      @destination ||= obj.destination('') if obj.respond_to? :destination

      @date ||= field(obj, :date) || Time.now

      @last_modified ||= field(obj, :last_modified) ||
                         field(obj, :last_modified_at) ||
                         @date

      @last_modified_field ||= if field(obj, :last_modified)
                                 :last_modified
                               elsif field(obj, :last_modified_at)
                                 :last_modified_at
                               end

      @ext           ||= field(obj, :extname)
      @extname       ||= @ext # For compatibility with previous versions of all_collections
      @label         ||= obj.collection.label if obj.respond_to?(:collection) && obj.collection.respond_to?(:label)
      @path          ||= field(obj, :path)
      @relative_path ||= field(obj, :relative_path)
      @title         ||= field(obj, :title)
      @type          ||= field(obj, :type)
      return if @url

      @url = obj.url
      @url = if @url
               "#{@url}index.html" if @url.end_with? '/'
             else
               '/'
             end
    end
  end
end
