require 'spec_helper'
require_relative '../lib/hooks/all_files'

RSpec.describe(SortedLruFiles) do
  expected1 = 'first-page.html'
  expected2 = 'second-page.html'
  expected3 = 'third-page.html'

  it 'can read back an inserted item' do
    sorted_files = described_class.new
    sorted_files.insert(expected1, "https://mslinn.com/#{expected1}") # insert reverses expected1
    sorted_files.enable_search

    actual = sorted_files.select expected1
    expect(actual.length).to eq(1)
    expect(actual.first&.reverse&.start_with?(expected1.reverse)).to be true

    actual = sorted_files.select expected1[5..]
    expect(actual.length).to eq(1)
    expect(actual.first&.reverse&.start_with?(expected1[5..].reverse)).to be true

    actual = sorted_files.select 'should_not_match'
    expect(actual).to be_empty
  end

  it 'works with 2 items and one match' do
    sorted_files = described_class.new
    sorted_files.insert(expected1, "https://mslinn.com/#{expected1}") # insert reverses expected1
    sorted_files.insert(expected2, "https://mslinn.com/#{expected2}")
    sorted_files.enable_search

    expect(sorted_files.msbs.array[0].url).to be <= sorted_files.msbs.array[1].url

    actual = sorted_files.select expected1
    expect(actual.length).to eq(1)
    expect(actual.first&.end_with?(expected1)).to be true

    actual = sorted_files.select expected2
    expect(actual.length).to eq(1)
    expect(actual.first&.end_with?(expected2)).to be true
  end

  it 'handles multiple matches' do
    sorted_files = described_class.new
    sorted_files.insert(expected1, "https://mslinn.com/#{expected1}") # insert reverses expected1
    sorted_files.insert(expected2, "https://mslinn.com/#{expected2}")
    sorted_files.enable_search

    expected = '.html'
    actual = sorted_files.select expected
    expect(actual.length).to eq(2)
    expect(actual.first&.end_with?(expected)).to be true
  end

  it 'works with 3 items' do
    sorted_files = described_class.new
    sorted_files.insert(expected1, "https://mslinn.com/#{expected1}") # insert reverses expected1
    sorted_files.insert(expected2, "https://mslinn.com/#{expected2}")
    sorted_files.insert(expected3, "https://mslinn.com/#{expected3}")
    sorted_files.enable_search

    expect(sorted_files.msbs.array[0].url).to be <= sorted_files.msbs.array[1].url
    expect(sorted_files.msbs.array[1].url).to be <= sorted_files.msbs.array[2].url

    actual = sorted_files.select expected1
    expect(actual.length).to eq(1)
    expect(actual.first&.end_with?(expected1)).to be true

    actual = sorted_files.select expected2
    expect(actual.length).to eq(1)
    expect(actual.first&.end_with?(expected2)).to be true

    actual = sorted_files.select expected3
    expect(actual.length).to eq(1)
    expect(actual.first&.end_with?(expected3)).to be true

    expected = '.html'
    actual = sorted_files.select expected
    expect(actual.length).to eq(3)
    expect(actual.first&.end_with?(expected)).to be true
  end
end
