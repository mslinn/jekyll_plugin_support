module AllCollectionsHooks
  class << self
    attr_accessor :all_collections, :all_documents, :everything, :sorted_lru_files
  end

  # @sort_by = ->(apages, criteria) { [apages.sort(criteria)] } # todo delete this

  # @return [String] indicating if :all_collections is defined or not
  def self.all_collections_defined?(site)
    "site.all_collections #{site.class.method_defined?(:all_collections) ? 'IS' : 'IS NOT'} defined"
  end

  # Called by early, high-priority hook.
  # Computes site.all_collections, site.all_documents, site.everything, and site.sorted_lru_files
  def self.compute(site)
    site.class.module_eval { attr_accessor :all_collections, :all_documents, :everything, :sorted_lru_files }

    documents = site.collections
                    .values
                    .map { |x| x.class.method_defined?(:docs) ? x.docs : x }
                    .flatten
                    .compact
    @all_collections = JekyllSupport.apages_from_objects(documents, 'collection')
    @all_documents   = @all_collections +
                       JekyllSupport.apages_from_objects(site.pages, 'individual_page')
    @everything      = @all_documents +
                       JekyllSupport.apages_from_objects(site.static_files, 'static_file')
    @sorted_lru_files = SortedLruFiles.new.add_pages @everything

    site.all_collections  = @all_collections
    site.all_documents    = @all_documents
    site.everything       = @everything
    site.sorted_lru_files = @sorted_lru_files
  rescue StandardError => e
    ::JekyllSupport.error_short_trace(::JekyllAllCollections::AllCollectionsHooks.logger, e)
    # ::JekyllSupport.warn_short_trace(::JekyllAllCollections::AllCollectionsHooks.logger, e)
  end
end
