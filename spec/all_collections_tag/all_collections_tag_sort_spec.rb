require_relative '../spec_helper'
require_relative '../../lib/hooks/a_page'

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

def show_dates(label, array)
  puts "  #{label} actual: #{array.map(&:title).join(', ')}  <==>  expected: #{expected.map(&:title).join(', ')}"
end

def show(lambda_string, actual, expected)
  puts "For lambda_string: #{lambda_string}"
  puts "  actual: #{actual.map(&:title).join(', ')}"
  puts "expected: #{expected.map(&:title).join(', ')}"
  actual_array   = actual.map   { |x| [(x.date.strftime '%Y-%m-%d'), (x.last_modified.strftime '%Y-%m-%d')].join('/') }
  expected_array = expected.map { |x| [(x.date.strftime '%Y-%m-%d'), (x.last_modified.strftime '%Y-%m-%d')].join('/') }
  puts '  actual date/last_modified: ' + actual_array.join(', ')
  puts 'expected date/last_modified: ' + expected_array.join(', ')
end

# See https://stackoverflow.com/a/75388137/553865
RSpec.describe(JekyllSupport) do
  let(:o1) do
    described_class.apage_from(
      collection_name: '_posts',
      date:            '2020-01-01',
      last_modified:   '2020-01-01',
      title:           'a_A (o1)'
    )
  end
  let(:o2) do
    described_class.apage_from(
      collection_name: '_posts',
      date:            '2021-01-01',
      last_modified:   '2021-01-01',
      title:           'b_B (o2)'
    )
  end
  let(:o3) do
    described_class.apage_from(
      collection_name: '_posts',
      date:            '2021-01-01',
      last_modified:   '2022-01-01',
      title:           'b_C (o3)'
    )
  end
  let(:o4) do
    described_class.apage_from(
      collection_name: '_posts',
      date:            '2022-01-01',
      last_modified:   '2023-01-01',
      title:           'c_D (o4)'
    )
  end
  let(:objs) { [o1, o2, o3, o4] }

  it '(1) defines sort_by lambda with last_modified (ascending)' do
    sort_lambda = ->(a, b) { [a.last_modified] <=> [b.last_modified] }
    actual = objs.sort(&sort_lambda)
    expected = [o1, o2, o3, o4]
    show('[a.last_modified] <=> [b.last_modified]', actual, expected)
    expect(actual).to eq(expected)
  end

  it '(2) makes sort_by lambdas from stringified comparison of last_modified (ascending)' do
    sort_lambda_string = '->(a, b) { a.last_modified <=> b.last_modified }'
    sort_lambda = eval sort_lambda_string, NullBinding.new.min_binding, __FILE__, __LINE__ - 1
    actual = objs.sort(&sort_lambda)
    expected = [o1, o2, o3, o4]
    show(sort_lambda_string, actual, expected)
    expect(actual).to eq(expected)
  end

  it '(3) makes sort_by lambda from stringified array of last_modified (ascending)' do
    sort_lambda_string = '->(a, b) { [a.last_modified] <=> [b.last_modified] }'
    sort_lambda = eval sort_lambda_string, NullBinding.new.min_binding, __FILE__, __LINE__ - 1
    actual = objs.sort(&sort_lambda)
    expected = [o1, o2, o3, o4]
    show(sort_lambda_string, actual, expected)
    expect(actual).to eq(expected)
  end

  it '(4) makes sort_by lambda with last_modified (ascending) from stringified array' do
    sort_lambda_string = '->(a, b) { [b.last_modified] <=> [a.last_modified] }'
    sort_lambda = eval sort_lambda_string, NullBinding.new.min_binding, __FILE__, __LINE__ - 1
    actual = objs.sort(&sort_lambda)
    expected = [o4, o3, o2, o1]
    show(sort_lambda_string, actual, expected)
    expect(actual).to eq(expected)
  end

  it '(5) create_lambda with date (descending)' do
    lambda_string = JekyllAllCollections::AllCollectionsTag.create_lambda_string('-last_modified')
    expect(lambda_string).to eq('->(a, b) { [b.last_modified] <=> [a.last_modified] }')
    sort_lambda = self.eval lambda_string, binding
    actual = objs.sort(&sort_lambda)
    expected = [o4, o3, o2, o1]
    show(lambda_string, actual, expected)
    expect(actual).to eq(expected)
  end

  it '(6) create_lambda with date (ascending)' do
    lambda_string = JekyllAllCollections::AllCollectionsTag.create_lambda_string('date')
    expect(lambda_string).to eq('->(a, b) { [a.date] <=> [b.date] }')
    sort_lambda = self.eval lambda_string, binding
    actual = objs.sort(&sort_lambda)
    expected = [o1, o2, o3, o4]
    show(lambda_string, actual, expected)
    expect(actual).to eq(expected)
  end

  it '(7) create_lambda with date (ascending) and last_modified (ascending)' do
    lambda_string = JekyllAllCollections::AllCollectionsTag.create_lambda_string(%w[date last_modified])
    expect(lambda_string).to eq('->(a, b) { [a.date, a.last_modified] <=> [b.date, b.last_modified] }')
    sort_lambda = self.eval lambda_string, binding
    actual = objs.sort(&sort_lambda)
    expected = [o1, o2, o3, o4]
    show(lambda_string, actual, expected)
    expect(actual).to eq(expected)
  end

  it '(8) create_lambda with date (descending) and last_modified (descending)' do
    lambda_string = JekyllAllCollections::AllCollectionsTag.create_lambda_string(['-date', '-last_modified'])
    expect(lambda_string).to eq('->(a, b) { [b.date, b.last_modified] <=> [a.date, a.last_modified] }')
    sort_lambda = self.eval lambda_string, binding
    actual = objs.sort(&sort_lambda)
    expected = [o4, o3, o2, o1]
    show(lambda_string, actual, expected)
    expect(actual).to eq(expected)
  end

  it '(9) create_lambda with date (descending) and last_modified (ascending)' do
    lambda_string = JekyllAllCollections::AllCollectionsTag.create_lambda_string(['-date', 'last_modified'])
    expect(lambda_string).to eq('->(a, b) { [b.date, a.last_modified] <=> [a.date, b.last_modified] }')
    sort_lambda = self.eval lambda_string, binding
    actual = objs.sort(&sort_lambda)
    expected = [o4, o2, o3, o1]
    show(lambda_string, actual, expected)
    expect(actual).to eq(expected)
  end

  it '(10) create_lambda with date (ascending) and last_modified (descending)' do
    lambda_string = JekyllAllCollections::AllCollectionsTag.create_lambda_string(['date', '-last_modified'])
    expect(lambda_string).to eq('->(a, b) { [a.date, b.last_modified] <=> [b.date, a.last_modified] }')
    sort_lambda = self.eval lambda_string, binding
    actual = objs.sort(&sort_lambda)
    expected = [o1, o3, o2, o4]
    show(lambda_string, actual, expected)
    expect(actual).to eq(expected)
  end
end
