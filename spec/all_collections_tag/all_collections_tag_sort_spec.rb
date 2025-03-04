require 'spec_helper'
require_relative '../../lib/jekyll_all_collections'

class APageStub
  attr_reader :date, :last_modified, :label

  def initialize(date, last_modified, label = '')
    @date = Date.parse date
    @last_modified = Date.parse last_modified
    @label = label
  end

  def to_s
    @label
  end
end

def show(lambda_string, result, expected)
  p "For lambda_string: #{lambda_string}"
  p "  result: #{result.map(&:label).join(', ')}  <==>  expected: #{expected.map(&:label).join(', ')}"
end

# See https://stackoverflow.com/a/75388137/553865
RSpec.describe(AllCollectionsTag::AllCollectionsTag) do
  let(:o1) { APageStub.new('2020-01-01', '2020-01-01', 'a_A') }
  let(:o2) { APageStub.new('2021-01-01', '2020-01-01', 'b_A') }
  let(:o3) { APageStub.new('2021-01-01', '2023-01-01', 'b_B') }
  let(:o4) { APageStub.new('2022-01-01', '2023-01-01', 'c_B') }
  let(:objs) { [o1, o2, o3, o4] }

  it 'defines sort_by lambda with last_modified' do
    sort_lambda = ->(a, b) { [a.last_modified] <=> [b.last_modified] }
    result = objs.sort(&sort_lambda)
    expect(result).to eq([o1, o2, o3, o4])
  end

  it 'makes sort_by lambdas from stringified date' do
    sort_lambda = eval '->(a, b) { a.last_modified <=> b.last_modified }',
                       NullBinding.new.min_binding, __FILE__, __LINE__ - 1
    result = objs.sort(&sort_lambda)
    expect(result).to eq([o1, o2, o3, o4])
  end

  it 'makes sort_by lambdas from stringified array of last_modified' do
    sort_lambda = eval '->(a, b) { [a.last_modified] <=> [b.last_modified] }',
                       NullBinding.new.min_binding, __FILE__, __LINE__ - 1
    result = objs.sort(&sort_lambda)
    expect(result).to eq([o1, o2, o3, o4])
  end

  it 'makes sort_by lambdas with descending keys from stringified array of last_modified' do
    sort_lambda = eval '->(a, b) { [b.last_modified] <=> [a.last_modified] }',
                       NullBinding.new.min_binding, __FILE__, __LINE__ - 1
    result = objs.sort(&sort_lambda)
    expected = [o3, o4, o1, o2]
    expect(result).to eq(expected)
  end

  it 'create_lambda with 1 date key, descending' do
    lambda_string = described_class.create_lambda_string('-last_modified')
    sort_lambda = described_class.evaluate(lambda_string)
    result = objs.sort(&sort_lambda)
    expected = [o3, o4, o1, o2]
    # show(lambda_string, result, expected)
    expect(result).to eq(expected)
  end

  it 'create_lambda with 1 date key, ascending' do
    lambda_string = described_class.create_lambda_string('date')
    sort_lambda = described_class.evaluate(lambda_string)
    result = objs.sort(&sort_lambda)
    expected = [o1, o2, o3, o4]
    # show(lambda_string, result, expected)
    expect(result).to eq(expected)
  end

  it 'create_lambda with 2 date keys, both ascending' do
    lambda_string = described_class.create_lambda_string(%w[date last_modified])
    sort_lambda = described_class.evaluate(lambda_string)
    result = objs.sort(&sort_lambda)
    expected = [o1, o2, o3, o4]
    # show(lambda_string, result, expected)
    expect(result).to eq(expected)
  end

  it 'create_lambda with 2 date keys, both descending' do
    lambda_string = described_class.create_lambda_string(['-date', '-last_modified'])
    sort_lambda = described_class.evaluate(lambda_string)
    result = objs.sort(&sort_lambda)
    expected = [o4, o3, o2, o1]
    # show(lambda_string, result, expected)
    expect(result).to eq(expected)
  end

  it 'create_lambda with 2 date keys, first descending and second ascending' do
    lambda_string = described_class.create_lambda_string(['-date', 'last_modified'])
    sort_lambda = described_class.evaluate(lambda_string)
    result = objs.sort(&sort_lambda)
    expected = [o4, o2, o3, o1]
    # show(lambda_string, result, expected)
    expect(result).to eq(expected)
  end

  it 'create_lambda with 2 date keys, first ascending and second descending' do
    lambda_string = described_class.create_lambda_string(['date', '-last_modified'])
    sort_lambda = described_class.evaluate(lambda_string)
    result = objs.sort(&sort_lambda)
    expected = [o1, o3, o2, o4]
    # show(lambda_string, result, expected)
    expect(result).to eq(expected)
  end
end
