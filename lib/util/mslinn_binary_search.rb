unless defined?(MSlinnBinarySearchError)
  class MSlinnBinarySearchError < StandardError
  end
end

# Ruby's binary search is unsuitable because the value to be searched for changes the required ordering for String compares
class MSlinnBinarySearch
  attr_reader :accessor_chain, :array # For testing only

  def initialize(accessor_chain)
    @array = SortedSet.new # [LruFile] Ordered highest to lowest
    @accessor_chain = accessor_chain
  end

  # Convert the SortedSet to an Array
  def enable_search
    @array = @array.to_a
  end

  # A match is found when the Array[LruFile] has an href which starts with the given stem
  # @param stem [String]
  # @return first item from @array.url that matches, or nil if no match
  def find(stem)
    raise MSlinnBinarySearchError, 'Invalid find because stem to search for is nil.' if stem.nil?

    index = find_index(stem)
    return nil if index.nil?

    @array[index]
  end

  # @param stem [String]
  # @return index of first matching stem, or nil if @array is empty, or 0 if no stem specified
  def find_index(stem)
    return nil if @array.empty?
    return 0 if stem.nil? || stem.empty?

    mets = stem.reverse
    return nil if @array[0].url[0...mets.size] > mets # TODO: use chain eval for item
    return nil if @array[0].url[0] != mets[0]

    _find_index(mets, 0, @array.length - 1)
  end

  # @param stem [String]
  # @return [index] of matching values, or [] if @array is empty, or entire array if no stem specified
  def find_indices(stem)
    return [] if @array.empty?
    return @array if stem.nil? || stem.empty?

    first_index = _find_index(stem, 0, @array.length - 1)
    last_index = first_index
    last_index += 1 while @array[last_index].url.start_with? stem
    [first_index..last_index]
  end

  # @param item [LruFile]
  # @return [int] index of matching LruFile in @array, or nil if not found
  def index_of(lru_file)
    raise MSlinnBinarySearchError, 'Invalid index_of lru_file (nil).' if lru_file.nil?

    find_index lru_file.url
  end

  # @return [LruFile] item at given index in @array
  def item_at(index)
    if index > @array.length - 1
      raise MSlinnBinarySearchError,
            "Invalid item_at index (#{index}) is greater than maximum stem (#{@array.length - 1})."
    end
    raise MSlinnBinarySearchError, "Invalid item_at index (#{index}) is less than zero." if index.negative?

    @array[index]
  end

  # @param lru_file [LruFile]
  def insert(lru_file)
    raise MSlinnBinarySearchError, 'Invalid insert because new item is nil.' if lru_file.nil?
    raise MSlinnBinarySearchError, "Invalid insert because new item has no chain (#{lru_file})" if lru_file.chain.nil?

    @array.add lru_file
  end

  # TODO: Cache this method
  # @param suffix [String] to use stem search on
  # @return nil if @array is empty
  # @return the first item in @array if suffix is nil or an empty string
  def prefix_search(suffix)
    return nil if @array.empty?
    return @array[0] if suffix.empty? || suffix.nil?

    low = search_index { |x| x.evaluate_with suffix }
    return [] if low.nil?

    high = low
    high += 1 while high < @array.length &&
                    @array[high].evaluate_with(suffix)
    @array[low..high]
  end

  # @param stem [String]
  # @return [APage] matching APages, or [] if @array is empty, or entire array if no stem specified
  def select_pages(stem)
    first_index = find_index stem
    return [] if first_index.nil?

    last_index = first_index
    while last_index < @array.length - 1
      # LruFile.url is reversed, bug LruFile.page is not
      break unless @array[last_index + 1].url.start_with?(stem.reverse)

      last_index += 1
    end
    Range.new(first_index, last_index).map { |i| @array[i].page }
  end

  private

  # A match is found when the Array[LruFile] has an href which starts with the given stem
  # @param stem [String]
  # @return [int] first index in @array that matches, or nil if no match
  def _find_index(mets, min_index, max_index)
    raise MSlinnBinarySearchError, "_find_index min_index(#{min_index})<0" if min_index.negative?
    raise MSlinnBinarySearchError, "_find_index min_index(#{min_index})>max_index(#{max_index})" if min_index > max_index
    raise MSlinnBinarySearchError, "_find_index max_index(#{max_index})>=@array.length(#{@array.length})" if max_index >= @array.length

    return min_index if (min_index == max_index) && @array[min_index].url.start_with?(mets)

    while min_index < max_index
      mid_index = (min_index + max_index) / 2
      mid_value = @array[mid_index].url[0...(mets.size)] # TODO: use chain eval for item

      if mid_value == mets # back up until the first match is found
        index = mid_index
        loop do
          return 0 if index.zero?

          return index unless @array[index - 1].url.start_with?(mets)

          index -= 1
        end
      elsif mid_value > mets
        max_index = mid_index - 1
        return _find_index(mets, min_index, max_index)
      else
        min_index = mid_index + 1
        return _find_index(mets, min_index, max_index)
      end
    end
    nil
  end
end
