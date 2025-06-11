require 'date'
require 'jekyll_draft'
require 'time'

module JekyllSupport
  # Contructor for testing and jekyll_outline
  def self.apage_from( # rubocop:disable Metrics/ParameterLists
    collection_name: nil,
    date: nil,
    description: nil,
    draft: false,
    last_modified: nil,
    logger: nil,
    order: nil,
    title: nil,
    url: nil
  )
    # Jekyll documents have inconsistent date and last_modified property types.
    date = Time.parse(date) if date.instance_of?(String)
    unless date.instance_of? Time
      logger.error { "date is not an instance of Time, it is an instance of #{date.class}" }
      exit 2
    end

    last_modified = Date.parse(last_modified) if last_modified.instance_of?(String)
    unless last_modified.instance_of? Date
      logger.error { "last_modified is not an instance of Date, it is an instance of #{last_modified.class}" }
      exit 3
    end
    last_modified = Date.parse(date._to_s) if last_modified.nil?
    data = {
      collection:    { label: collection_name },
      draft:         draft,
      last_modified: last_modified,
      order:         order,
      title:         title,
    }
    obj = {}
    JekyllSupport.new_attribute obj, :data, data
    JekyllSupport.new_attribute obj, :date, date
    JekyllSupport.new_attribute obj, :description, description
    JekyllSupport.new_attribute obj, :draft, draft
    JekyllSupport.new_attribute obj, :extname, '.html'
    JekyllSupport.new_attribute obj, :last_modified, last_modified
    JekyllSupport.new_attribute obj, :logger, PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)
    JekyllSupport.new_attribute obj, :title, title
    JekyllSupport.new_attribute obj, :url, url

    JekyllSupport::APage.new obj, nil
  rescue StandardError => e
    puts e.full_message
  end

  # Create Array of JekyllSupport::APage from objects
  # @param objects [Array] An array of Jekyll::Document, Jekyll::Page or file names
  # @param origin [String] Indicates type of objects being passed
  def self.apages_from_objects(objects, origin)
    pages = []
    objects.each do |object|
      unless object.respond_to?(:logger)
        JekyllSupport.new_attribute(object,
                                    :logger,
                                    PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config))
      end
      page = APage.new(object, origin)
      pages << page unless page.data['exclude_from_all'] || page.path == 'redirect.html'
    end
    pages
  end

  # Defines a new attribute called `prop_name` in object `obj` and sets it to `prop_value`
  def self.new_attribute(obj, prop_name, prop_value)
    obj.class.module_eval { attr_accessor prop_name }
    obj.instance_variable_set :"@#{prop_name}", prop_value
  end

  FIXNUM_MAX = (2**((0.size * 8) - 2)) - 1 unless defined? FIXNUM_MAX
  END_OF_DAYS = 1_000_000_000_000 unless defined? END_OF_DAYS # One trillion years in the future
  # Time.new is -4712-01-01

  class APage
    attr_reader :categories, :collection_name, :content, :data, :date, :description, :destination, :draft,
                :excerpt, :ext, :extname, :href, :label, :last_modified, :last_modified_field,
                :layout, :logger, :name, :origin, :path, :relative_path, :tags, :title, :type, :url

    # @param obj can be a `Jekyll::Document` or a Hash with properties
    # @param origin values: 'collection', 'individual_page', and 'static_file'
    #               (See method JekyllSupport.apages_from_objects)
    def initialize(obj, origin)
      @logger = obj.logger
      @origin = origin
      build obj
    rescue StandardError => e
      ::JekyllSupport.error_short_trace(@logger, e)
    end

    # @param name can be either a String or a Symbol
    def field(name, use_default: true)
      default_value = case name
                      when :date, :last_modified, :last_modified_at
                        END_OF_DAYS
                      else
                        ''
                      end

      result = data[name.to_sym] || data[name.to_s] if data.key?(name.to_sym) || data.key?(name.to_s)
      return result if result

      default_value if use_default
    end

    # Look within @data (if the property exists), then self for the given key as a symbol or a string
    # @param key must be a symbol
    # @return value of data[key] if key exists as a string or a symbol, else nil
    def obj_field(obj, key)
      if obj.respond_to? :data
        return obj.data[key] if obj.data.key? key

        return obj.data[key.to_s] if obj.data.key? key.to_s
      end
      return obj.send(key) if obj.respond_to?(key)

      return unless obj.respond_to?(:key?)
      return obj[key] if obj.key?(key)

      obj[key.to_s] if obj.key?(key.to_s)
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
    # Sets the following instance attributes in APage from selected attributes in `obj` (when present):
    # `content`, `destination`, `ext` and `extname`, `label` from `collection.label`,
    # `path`, `relative_path`, `type`, and `url`.
    def build(obj) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      @categories          ||= obj_field(obj, :categories)

      collection_value     = obj_field(obj, :collection)
      @collection_name     = if collection_value
                               if collection_value.respond_to?(:label)
                                 collection_value.label
                               elsif collection_value.key? :label
                                 collection_value[:label]
                               end
                             end

      @content             ||= obj.content if obj.respond_to? :content
      @data                ||= obj.respond_to?(:data) ? obj.data : {}
      @date                ||= obj_field(obj, :date) || Time.now # Jekyll doc.date property is a Time
      @description         ||= obj_field(obj, :description)
      # TODO: What _config.yml setting should be passed to destination()?
      @destination         ||= obj.destination('') if obj.respond_to? :destination
      @draft               ||= Jekyll::Draft.draft? obj
      @excerpt             ||= obj_field(obj, :excerpt)
      @ext                 ||= obj_field(obj, :ext) || obj_field(obj, :extname)
      @extname             ||= @ext # For compatibility with previous versions of all_collections
      @label               ||= obj.collection.label if obj.respond_to?(:collection) && obj.collection.respond_to?(:label)

      @last_modified       ||= obj_field(obj, :last_modified) ||
                               obj_field(obj, :last_modified_at) ||
                               Date.parse(@date.to_s) # Jekyll doc.last_modified property is a Date

      @last_modified_field ||= if obj_field(obj, :last_modified)
                                 :last_modified
                               elsif obj_field(obj, :last_modified_at)
                                 :last_modified_at
                               end

      @layout              ||= obj_field(obj, :layout)
      @path                ||= obj_field(obj, :path)
      @relative_path       ||= obj_field(obj, :relative_path)
      @tags                ||= obj_field(obj, :tags)
      @type                ||= obj_field(obj, :type)

      @url                 ||= obj.url
      if @url
        @url = "#{@url}index.html" if @url&.end_with? '/'
      else
        @url = '/index.html'
      end

      # @href  = "/#{@href}" if @origin == 'individual_page'
      @href  ||= @url
      @name  ||= File.basename(@href)
      @title ||= obj_field(obj, :title) || "<code>#{@href}</code>"
    end
  end
end
