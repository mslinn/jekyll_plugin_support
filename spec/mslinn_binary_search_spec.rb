require 'spec_helper'
require_relative '../lib/hooks/all_files'

def build_msbs(sorted_strings)
  sorted_strings.each do |string|
    $msbs.insert LruFile.new(string.reverse, "Page #{string}") # { |x| x.url.start_with? string }
  end
  $msbs.enable_search
end

RSpec.describe(MSlinnBinarySearch) do
  $msbs = described_class.new [:url, %i[start_with? placeholder]]
  build_msbs %w[aaa.html baa.html caa.html bbb.html cbb.html dbb.html ccc.html ccd.html cce.html]

  it 'handles an empty search string by returning the index of the first item (0)' do
    index = $msbs.find_index '' # { |x| x.url.start_with? '' }
    expect(index).to be_zero
  end

  it 'returns the index of the first partial match' do
    index = $msbs.find_index 'a.html' # { |x| x.url.start_with? 'a.html' }
    expect(index).to eq(0)

    index = $msbs.find_index 'baa.html' # { |x| x.url.start_with? 'baa.html' }
    expect(index).to eq(1)

    index = $msbs.find_index 'c.html' # { |x| x.url.start_with? 'c.html' }
    expect(index).to eq(6)

    index = $msbs.find_index 'cce.html' # { |x| x.url.start_with? 'cce.html' }
    expect(index).to eq(8)
  end

  it 'returns the item of the first match' do
    item = $msbs.find 'a.html' # { |x| x.url.start_with? 'a.html' }
    expect(item.url.reverse).to eq('aaa.html')

    item = $msbs.find 'baa.html' # { |x| x.url.start_with? 'baa.html' }
    expect(item.url.reverse).to eq('baa.html')

    item = $msbs.find 'c.html' # { |x| x.url.start_with? 'c.html' }
    expect(item.url.reverse).to eq('ccc.html')

    item = $msbs.find 'cce.html' # { |x| x.url.start_with? 'cce.html' }
    expect(item.url.reverse).to eq('cce.html')
  end
end
