require 'securerandom'

# @author Copyright 2020 Michael Slinn
# @license SPDX-License-Identifier: Apache-2.0
module JekyllAllCollections
  PLUGIN_NAME = 'all_collections'.freeze unless defined?(PLUGIN_NAME)
  CRITERIA = %w[date destination draft label last_modified last_modified_at path relative_path title type url].freeze unless defined?(CRITERIA)
  DRAFT_HTML = '<i class="jekyll_draft">Draft</i>'.freeze unless defined?(DRAFT_HTML)

  class AllCollectionsTag < ::JekyllSupport::JekyllTag
    include ::JekyllPluginSupportVersion

    # Method prescribed by JekyllTag.
    # @return [String]
    def render_impl
      parse_arguments # Defines instance variables like @sort_by
      sort_lambda = init_sort_by @sort_by
      generate_output sort_lambda
    rescue StandardError => e
      ::JekyllSupport.error_short_trace @logger, e
      # ::JekyllSupport.warn_short_trace @logger, e
    end

    # Descending sort keys are preceded by a minus sign, and reverse the order of comparison
    # @param criteria String Examples: 'date', '-date', 'last_modified', '-last_modified',
    #        ['date', 'last_modified], ['-date', '-last_modified'], ['date', '-last_modified']
    # @return values:
    #   "->(a, b) { [a.last_modified] <=> [b.last_modified] }" (ascending)
    #   "->(a, b) { [b.last_modified] <=> [a.last_modified] }" (descending)
    #   "->(a, b) { [a.last_modified, a.date] <=> [b.last_modified, b.date] }" (descending last_modified, ascending date)
    #   "->(a, b) { [a.last_modified, b.date] <=> [b.last_modified, a.date] }" (ascending last_modified, descending date)
    def self.create_lambda_string(criteria)
      criteria_lhs_array = []
      criteria_rhs_array = []
      verify_sort_by_type(criteria).each do |c|
        descending_sort = c.start_with? '-'
        c.delete_prefix! '-'
        abort("Error: '#{c}' is not a valid sort field. Valid field names are: #{CRITERIA.join ', '}") \
          unless CRITERIA.include?(c)
        criteria_lhs_array << (descending_sort ? "b.#{c}" : "a.#{c}")
        criteria_rhs_array << (descending_sort ? "a.#{c}" : "b.#{c}")
      end
      "->(a, b) { [#{criteria_lhs_array.join(', ')}] <=> [#{criteria_rhs_array.join(', ')}] }"
    end

    def self.verify_sort_by_type(sort_by)
      case sort_by
      when Array
        sort_by
      when Enumerable
        sort_by.to_a
      when Date
        [sort_by.to_i]
      when String
        [sort_by]
      else
        abort "Error: @sort_by was specified as '#{sort_by}'; it must either be a string or an array of strings"
      end
    end

    private

    def default_head(sort_by)
      criteria = (sort_by.map do |x|
        reverse = x.start_with? '-'
        criterion = x.delete_prefix('-').capitalize
        criterion += reverse ? ' (Newest to Oldest)' : ' (Oldest to Newest)'
        criterion
      end).join(', ')
      "All Posts in All Categories Sorted By #{criteria}"
    end

    def evaluate(string)
      self.eval string, binding, __FILE__, __LINE__
    rescue StandardError => e
      warn_short_trace e.red
    end

    def date_value(apage, field_name)
      if %i[last_modified last_modified_at].include? field_name
        apage.field(:last_modified_at, use_default: false) ||
          apage.field(:last_modified, use_default: false) ||
          Date.today
      else
        apage.date || Time.now
      end
    end

    def generate_output(sort_lambda)
      id = @id.to_s.strip.empty? ? '' : " id=\"#{@id}\""
      heading = @heading.strip.to_s.empty? ? '' : "<h2#{id}>#{@heading}</h2>"
      apages = case @data_selector
               when 'all_collections'
                 @site.all_collections
               when 'all_documents'
                 @site.all_documents
               when 'everything'
                 @site.everything
               else
                 raise AllCollectionsError, "Invalid value for @data_selector (#{data_selector})"
               end
      filtered_apages = @collection_name.nil? ? apages : apages.select { |apage| apage.collection == @collection_name }
      sorted_apages = filtered_apages.sort(&sort_lambda)
      posts = sorted_apages.map do |apage|
        date_column = @date_column.to_s == 'last_modified' ? :last_modified : :date
        d = date_value(apage, date_column)
        if d.instance_of?(Date) || d.instance_of?(Time)
          date = d.strftime '%Y-%m-%d'
        else
          @logger.error { "date_value returned a #{d.class} instead of a Date or a Time; date_column=#{date_column}" }
        end
        draft         = apage.draft ? DRAFT_HTML : ''
        title         = apage.title || apage.href
        href          = "<a href='#{apage.href}'>#{title}</a>"
        @logger.debug { "  date='#{date}' #{title}\n" }
        "  <span>#{date}</span><span>#{href}#{draft}</span>"
      end
      <<~END_TEXT
        #{heading}
        <div class="posts">
          #{posts.join "\n"}
        </div>
      END_TEXT
    rescue NoMethodError || ArgumentError => e
      ::JekyllSupport.error_short_trace e
    end

    # See https://stackoverflow.com/a/75377832/553865
    def init_sort_by(sort_by)
      sort_lambda_string = AllCollectionsTag.create_lambda_string sort_by

      @logger.debug do
        "#{@page['path']} sort_lambda_string = #{sort_lambda_string}\n"
      end

      evaluate sort_lambda_string
    end

    # @return String defining the parsed sort_by expression
    def parse_arguments
      @collection_name = @helper.parameter_specified('collection_name')
      @data_selector = @helper.parameter_specified?('data_selector') || 'all_collections'
      abort "Invalid data_selector #{@data_selector}" unless %w[all_collections all_documents everything].include? @data_selector
      @logger.warn {
        "collection_name was specified as #{@collection_name}, but data_selector is #{@data_selector}, which is less effcient than specifying all_collections."
      }

      sort_by_param = @helper.parameter_specified? 'sort_by' # Might specify multiple sort fields

      # Default to displaying last modified field unless a sort field is specified
      @date_column = @helper.parameter_specified?('date_column') || 'last_modified'
      unless %w[date last_modified].include?(@date_column)
        raise AllCollectionsError "The date_column attribute must either have value 'date' or 'last_modified', " \
                                  "but '#{@date_column}' was specified instead."
      end
      @date_column ||= (sort_by_param.include?('last_modified') ? 'last_modified' : 'date') # display the sort date by default

      @heading = @helper.parameter_specified?('heading') || default_head(@sort_by)

      @id = @helper.parameter_specified?('id') || SecureRandom.hex(10)

      @sort_by = (sort_by_param&.delete(' ')&.split(',') if sort_by_param != false) || ['-date']
      @sort_by
    end

    ::JekyllSupport::JekyllPluginHelper.register(self, PLUGIN_NAME)
  end
end
