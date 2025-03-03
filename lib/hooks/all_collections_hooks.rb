module JekyllAllCollections
  module AllCollectionsHooks
    class << self
      attr_accessor :logger
    end
    @logger = PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)

    # No, all_collections is not defined for this hook
    # Jekyll::Hooks.register(:site, :after_init, priority: :normal) do |site|
    #   defined_msg = ::AllCollectionsHooks.all_collections_defined?(site)
    #   @logger.debug { "Jekyll::Hooks.register(:site, :after_init: #{defined_msg}" }
    # end

    # Creates a `Array[APage]` property called site.all_collections if it does not already exist.
    # The array is available from :site, :pre_render onwards
    # Each `APage` entry is one document or page.
    Jekyll::Hooks.register(:site, :post_read, priority: :normal) do |site|
      @site = site
      unless site.class.method_defined? :all_collections
        defined_msg = ::AllCollectionsHooks.all_collections_defined? site
        @logger.debug { "Jekyll::Hooks.register(:site, :post_read, :normal: #{defined_msg}" }
        ::AllCollectionsHooks.compute(site) if !@site.class.method_defined?(:all_documents) || @site.all_documents.nil?
      end
    rescue StandardError => e
      JekyllSupport.error_short_trace(@logger, e)
      # JekyllSupport.warn_short_trace(@logger, e)
    end

    # Yes, all_collections is defined for this hook
    # Jekyll::Hooks.register(:site, :post_read, priority: :low) do |site|
    #   defined_msg = ::AllCollectionsHooks.all_collections_defined?(site)
    #   @logger.debug { "Jekyll::Hooks.register(:site, :post_read, :low: #{defined_msg}" }
    # rescue StandardError => e
    #   JekyllSupport.error_short_trace(@logger, e)
    #   # JekyllSupport.warn_short_trace(@logger, e)
    # end

    # Yes, all_collections is defined for this hook
    # Jekyll::Hooks.register(:site, :post_read, priority: :normal) do |site|
    #   defined_msg = ::AllCollectionsHooks.all_collections_defined?(site)
    #   @logger.debug { "Jekyll::Hooks.register(:site, :post_read, :normal: #{defined_msg}" }
    # rescue StandardError => e
    #   JekyllSupport.error_short_trace(@logger, e)
    #   # JekyllSupport.warn_short_trace(@logger, e)
    # end

    # Yes, all_collections is defined for this hook
    # Jekyll::Hooks.register(:site, :pre_render, priority: :normal) do |site, _payload|
    #   defined_msg = ::AllCollectionsHooks.all_collections_defined?(site)
    #   @logger.debug { "Jekyll::Hooks.register(:site, :pre_render: #{defined_msg}" }
    # rescue StandardError => e
    #   JekyllSupport.error_short_trace(@logger, e)
    #   # JekyllSupport.warn_short_trace(@logger, e)
    # end
  end
end

PluginMetaLogger.instance.logger.info do
  "Loaded AllCollectionsHooks v#{JekyllPluginSupportVersion::VERSION} :site, :pre_render, :normal hook plugin."
end
Liquid::Template.register_filter(JekyllAllCollections::AllCollectionsHooks)
