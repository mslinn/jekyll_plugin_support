require 'spec_helper'
require_relative '../lib/jekyll_all_collections'

# Verifies how data comparisons work

class Obj
  # `last_modified` is primary sort key
  # `date` (when specified) is secondary sort key
  attr_reader :date, :last_modified

  def initialize(param1, param2)
    @last_modified = Date.parse(param1)
    @date = Date.parse(param2)
  end
end

RSpec.describe(Obj) do
  let(:o1) { described_class.new('2000-01-01', '2001-01-01') }
  let(:o2) { described_class.new('2010-01-01', '2001-01-01') }
  let(:o3) { described_class.new('2010-01-01', '2011-01-01') }
  let(:o4) { described_class.new('2020-01-01', '2011-01-01') }
  let(:objs) { [o1, o2, o3, o4] }

  # See https://ruby-doc.org/3.2.0/Comparable.html
  it 'compares one key with ascending dates' do
    expect([o1.last_modified] <=> [o2.last_modified]).to eq(-1)
    expect([o2.last_modified] <=> [o3.last_modified]).to eq(0)
    expect([o3.last_modified] <=> [o4.last_modified]).to eq(-1)
  end

  it 'compares two keys with ascending dates' do
    expect([o1.last_modified, o1.date] <=> [o2.last_modified, o2.date]).to eq(-1)
    expect([o2.last_modified, o2.date] <=> [o3.last_modified, o3.date]).to eq(-1)
    expect([o3.last_modified, o3.date] <=> [o4.last_modified, o4.date]).to eq(-1)
  end

  it 'compares one key with descending dates' do
    expect([o1.last_modified] <=> [o2.last_modified]).to eq(-1)
    expect([o2.last_modified] <=> [o3.last_modified]).to eq(0)
  end

  it 'compares two keys with descending dates' do
    expect([o2.last_modified, o2.date] <=> [o1.last_modified, o1.date]).to eq(1)
    expect([o3.last_modified, o3.date] <=> [o2.last_modified, o2.date]).to eq(1)
    expect([o4.last_modified, o4.date] <=> [o3.last_modified, o3.date]).to eq(1)
  end

  # See https://ruby-doc.org/3.2.0/Enumerable.html#method-i-sort
  it 'sort with one key ascending' do
    sort_lambda = ->(a, b) { [a.last_modified] <=> [b.last_modified] }
    result = objs.sort(&sort_lambda)
    expect(result).to eq([o1, o2, o3, o4])
  end

  it 'sort with one key descending' do
    sort_lambda = ->(a, b) { [b.last_modified] <=> [a.last_modified] }
    result = objs.sort(&sort_lambda)
    expect(result).to eq([o4, o2, o3, o1])
  end

  it 'sort with two keys ascending' do
    sort_lambda = ->(a, b) { [a.last_modified, a.date] <=> [b.last_modified, b.date] }
    result = objs.sort(&sort_lambda)
    expect(result).to eq([o1, o2, o3, o4])
  end

  it 'sort with both keys descending' do
    sort_lambda = ->(a, b) { [b.last_modified, b.date] <=> [a.last_modified, a.date] }
    result = objs.sort(&sort_lambda)
    expect(result).to eq([o4, o3, o2, o1])
  end

  it 'sort with last_modified descending and date ascending' do
    sort_lambda = ->(a, b) { [b.last_modified, a.date] <=> [a.last_modified, b.date] }
    result = objs.sort(&sort_lambda)
    expect(result).to eq([o4, o2, o3, o1])
  end

  it 'sort with last_modified ascending and date descending' do
    sort_lambda = ->(a, b) { [a.last_modified, b.date] <=> [b.last_modified, a.date] }
    result = objs.sort(&sort_lambda)
    expect(result).to eq([o1, o3, o2, o4])
  end
end
