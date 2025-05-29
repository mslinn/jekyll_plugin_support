require_relative '../spec_helper'
require_relative '../../lib/hooks/a_page'

module AllCollectionsHooks
  # Override class definition for easiler testing
  class APage
    def to_s
      @title
    end
  end
end

class NullBinding < BasicObject
  include ::Kernel

  # Avoid error message "warning: undefining `object_id' may cause serious problems"
  # https://stackoverflow.com/a/17791631/553865
  (
    ::Kernel.instance_methods(false) +
    ::Kernel.private_instance_methods(false) -
    [:binding]
  ).each { |x| undef_method(x) unless x == :object_id }

  def min_binding
    binding
  end
end

def show(lambda_string, result, expected)
  p "For lambda_string: #{lambda_string}"
  p "  result: #{result.map(&:label).join(', ')}  <==>  expected: #{expected.map(&:label).join(', ')}"
end

# See https://stackoverflow.com/a/75388137/553865
RSpec.describe(AllCollectionsHooks::APage) do
  let(:o1) do
    described_class.apage_from(
      collection_name: '_posts',
      date:            '2020-01-01',
      last_modified:   '2020-01-01',
      title:           'a_A'
    )
  end
  let(:o2) do
    described_class.apage_from(
      collection_name: '_posts',
      date:            '2021-01-01',
      last_modified:   '2020-01-01',
      title:           'b_A'
    )
  end
  let(:o3) do
    described_class.apage_from(
      collection_name: '_posts',
      date:            '2021-01-01',
      last_modified:   '2023-01-01',
      title:           'b_B'
    )
  end
  let(:o4) do
    described_class.apage_from(
      collection_name: '_posts',
      date:            '2022-01-01',
      last_modified:   '2023-01-01',
      title:           'c_B'
    )
  end
  let(:objs) { [o1, o2, o3, o4] }

  it 'defines sort_by lambda with last_modified' do
    sort_lambda = ->(a, b) { [a.last_modified] <=> [b.last_modified] }
    actual = objs.sort(&sort_lambda)
    # show(lambda_string, result, expected)
    expect(actual).to eq([o1, o2, o3, o4])
  end

  it 'makes sort_by lambdas from stringified date' do
    sort_lambda = eval '->(a, b) { a.last_modified <=> b.last_modified }',
                       NullBinding.new.min_binding, __FILE__, __LINE__ - 1
    actual = objs.sort(&sort_lambda)
    # show(lambda_string, result, expected)
    expect(actual).to eq([o1, o2, o3, o4])
  end

  it 'makes sort_by lambdas from stringified array of last_modified' do
    sort_lambda = eval '->(a, b) { [a.last_modified] <=> [b.last_modified] }',
                       NullBinding.new.min_binding, __FILE__, __LINE__ - 1
    actual = objs.sort(&sort_lambda)
    # show(lambda_string, result, expected)
    expect(actual).to eq([o1, o2, o3, o4])
  end

  it 'makes sort_by lambdas with descending keys from stringified array of last_modified' do
    sort_lambda = eval '->(a, b) { [b.last_modified] <=> [a.last_modified] }',
                       NullBinding.new.min_binding, __FILE__, __LINE__ - 1
    actual = objs.sort(&sort_lambda)
    expected = [o3, o4, o1, o2]
    # show(lambda_string, result, expected)
    expect(actual).to eq(expected)
  end

  it 'create_lambda with 1 date key, descending' do
    lambda_string = JekyllAllCollections::AllCollectionsTag.create_lambda_string('-last_modified')
    sort_lambda = self.eval lambda_string, binding
    actual = objs.sort(&sort_lambda)
    expected = [o3, o4, o1, o2]
    # show(lambda_string, result, expected)
    expect(actual).to eq(expected)
  end

  it 'create_lambda with 1 date key, ascending' do
    lambda_string = JekyllAllCollections::AllCollectionsTag.create_lambda_string('date')
    sort_lambda = self.eval lambda_string, binding
    actual = objs.sort(&sort_lambda)
    expected = [o1, o2, o3, o4]
    # show(lambda_string, result, expected)
    expect(actual).to eq(expected)
  end

  it 'create_lambda with 2 date keys, both ascending' do
    lambda_string = JekyllAllCollections::AllCollectionsTag.create_lambda_string(%w[date last_modified])
    sort_lambda = self.eval lambda_string, binding
    actual = objs.sort(&sort_lambda)
    expected = [o1, o2, o3, o4]
    # show(lambda_string, result, expected)
    expect(actual).to eq(expected)
  end

  it 'create_lambda with 2 date keys, both descending' do
    lambda_string = JekyllAllCollections::AllCollectionsTag.create_lambda_string(['-date', '-last_modified'])
    sort_lambda = self.eval lambda_string, binding
    actual = objs.sort(&sort_lambda)
    expected = [o4, o3, o2, o1]
    # show(lambda_string, result, expected)
    expect(actual).to eq(expected)
  end

  it 'create_lambda with 2 date keys, first descending and second ascending' do
    lambda_string = JekyllAllCollections::AllCollectionsTag.create_lambda_string(['-date', 'last_modified'])
    sort_lambda = self.eval lambda_string, binding
    actual = objs.sort(&sort_lambda)
    expected = [o4, o2, o3, o1]
    # show(lambda_string, result, expected)
    expect(actual).to eq(expected)
  end

  it 'create_lambda with 2 date keys, first ascending and second descending' do
    lambda_string = JekyllAllCollections::AllCollectionsTag.create_lambda_string(['date', '-last_modified'])
    sort_lambda = self.eval lambda_string, binding
    actual = objs.sort(&sort_lambda)
    expected = [o1, o3, o2, o4]
    # show(lambda_string, result, expected)
    expect(actual).to eq(expected)
  end
end
