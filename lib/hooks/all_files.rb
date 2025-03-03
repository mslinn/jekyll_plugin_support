# Insert the url of a Jekyll::Page into each LruFile instance,
# along with the Page reference
# todo: replace references to url and :url with reverse_url and :reverse_url
LruFile = Struct.new(:url, :page) do
  include SendChain

  def <=>(other)
    url <=> other.url
  end

  def href
    url.reverse
  end
end

# Matches suffixes of an array of urls
# Converts suffixes to prefixes
class SortedLruFiles
  attr_reader :msbs

  def initialize
    @msbs = MSlinnBinarySearch.new %i[url start_with?]
  end

  # @param apages [Array[APage]]
  def add_pages(apages)
    apages.each { |apage| insert apage.href, apage }
    @msbs.enable_search
  end

  def enable_search
    @msbs.enable_search
  end

  def find(suffix)
    @msbs.find suffix
  end

  def insert(url, file)
    lru_file = LruFile.new(url.reverse, file)
    lru_file.new_chain [:url, %i[start_with? placeholder]]
    @msbs.insert(lru_file)
  end

  def select(suffix)
    @msbs.select_pages suffix
  end
end
