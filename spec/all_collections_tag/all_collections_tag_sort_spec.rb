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

def show(label, lambda_string, actual, expected)
  puts "#{label} - For lambda_string: #{lambda_string}"
  puts "  actual: #{actual.map(&:title).join(', ')}"
  puts "expected: #{expected.map(&:title).join(', ')}"
  actual_array = actual.map do |x|
    [
      (x.date.strftime '%Y-%m-%d' + '/' + x.title), (x.last_modified.strftime '%Y-%m-%d' + '/' + x.title)
    ].join('/')
  end
  expected_array = expected.map do |x|
    [
      (x.date.strftime '%Y-%m-%d' + '/' + x.title), (x.last_modified.strftime '%Y-%m-%d' + '/' + x.title)
    ].join('/')
  end
  puts '  actual date/last_modified: ' + actual_array.join(', ')
  puts 'expected date/last_modified: ' + expected_array.join(', ')
end

logger = PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)

# See https://stackoverflow.com/a/75388137/553865
RSpec.describe(JekyllSupport) do
  let(:o1) do
    described_class.apage_from(
      collection_name: '_posts',
      date:            '2020-01-20',
      last_modified:   '2020-01-20',
      logger:          logger,
      title:           'a_A (o1)'
    )
  end
  let(:o2) do
    described_class.apage_from(
      collection_name: '_posts',
      date:            '2021-01-21',
      last_modified:   '2021-01-21',
      logger:          logger,
      title:           'b_B (o2)'
    )
  end
  let(:o3) do
    described_class.apage_from(
      collection_name: '_posts',
      date:            '2021-01-21',
      last_modified:   '2022-01-22',
      logger:          logger,
      title:           'b_C (o3)'
    )
  end
  let(:o4) do
    described_class.apage_from(
      collection_name: '_posts',
      date:            '2022-01-22',
      last_modified:   '2022-01-22',
      logger:          logger,
      title:           'c_C (o4)'
    )
  end
  let(:objs) { [o1, o2, o3, o4] }

  it '(1) defines sort_by lambda with last_modified (ascending)' do
    sort_lambda = ->(a, b) { [a.last_modified] <=> [b.last_modified] }
    actual = objs.sort(&sort_lambda)
    expected = [o1, o2, o3, o4]
    show('(1)', '[a.last_modified] <=> [b.last_modified]', actual, expected)
    expect(actual).to eq(expected)
  end

  it '(2) makes sort_by lambdas from stringified comparison of last_modified (ascending)' do
    sort_lambda_string = '->(a, b) { a.last_modified <=> b.last_modified }'
    sort_lambda = eval sort_lambda_string, NullBinding.new.min_binding, __FILE__, __LINE__ - 1
    actual = objs.sort(&sort_lambda)
    expected = [o1, o2, o3, o4]
    show('(2)', sort_lambda_string, actual, expected)
    expect(actual).to eq(expected)
  end

  it '(3) makes sort_by lambda from stringified array of last_modified (ascending)' do
    sort_lambda_string = '->(a, b) { [a.last_modified] <=> [b.last_modified] }'
    sort_lambda = eval sort_lambda_string, NullBinding.new.min_binding, __FILE__, __LINE__ - 1
    actual = objs.sort(&sort_lambda)
    expected = [o1, o2, o3, o4]
    show('(3)', sort_lambda_string, actual, expected)
    expect(actual).to eq(expected)
  end

  it '(4) makes sort_by lambda with last_modified (descending) from stringified array' do
    sort_lambda_string = '->(a, b) { [b.last_modified] <=> [a.last_modified] }'
    sort_lambda = eval sort_lambda_string, NullBinding.new.min_binding, __FILE__, __LINE__ - 1
    actual = objs.sort(&sort_lambda)
    expected = [o4, o3, o2, o1]
    show('(4)', sort_lambda_string, actual, expected)
    expect([o3, o4]).to include(actual[0]) # The sort might yield o3 or o4 in this position
    expect([o3, o4]).to include(actual[1]) # The sort might yield o3 or o4 in this position
    expect(o2).to eq(actual[2])
    expect(o1).to eq(actual[3])
  end

  it '(5) create_lambda with date (descending)' do
    lambda_string = JekyllAllCollections::AllCollectionsTag.create_lambda_string('-last_modified')
    expect(lambda_string).to eq('->(a, b) { [b.last_modified] <=> [a.last_modified] }')
    sort_lambda = self.eval lambda_string, binding
    actual = objs.sort(&sort_lambda)
    expected = [o4, o3, o2, o1]
    show('(5)', lambda_string, actual, expected)
    expect([o3, o4]).to include(actual[0]) # The sort might yield o3 or o4 in this position
    expect([o3, o4]).to include(actual[1]) # The sort might yield o3 or o4 in this position
    expect(o2).to eq(actual[2])
    expect(o1).to eq(actual[3])
  end

  it '(6) create_lambda with date (ascending)' do
    lambda_string = JekyllAllCollections::AllCollectionsTag.create_lambda_string('date')
    expect(lambda_string).to eq('->(a, b) { [a.date] <=> [b.date] }')
    sort_lambda = self.eval lambda_string, binding
    actual = objs.sort(&sort_lambda)
    expected = [o1, o2, o3, o4]
    show('(1)', lambda_string, actual, expected)
    expect(actual).to eq(expected)
  end

  it '(7) create_lambda with date (ascending) and last_modified (ascending)' do
    lambda_string = JekyllAllCollections::AllCollectionsTag.create_lambda_string(%w[date last_modified])
    expect(lambda_string).to eq('->(a, b) { [a.date, a.last_modified] <=> [b.date, b.last_modified] }')
    sort_lambda = self.eval lambda_string, binding
    actual = objs.sort(&sort_lambda)
    expected = [o1, o2, o3, o4]
    show('(7)', lambda_string, actual, expected)
    expect(actual).to eq(expected)
  end

  it '(8) create_lambda with date (descending) and last_modified (descending)' do
    lambda_string = JekyllAllCollections::AllCollectionsTag.create_lambda_string(['-date', '-last_modified'])
    expect(lambda_string).to eq('->(a, b) { [b.date, b.last_modified] <=> [a.date, a.last_modified] }')
    sort_lambda = self.eval lambda_string, binding
    actual = objs.sort(&sort_lambda)
    expected = [o4, o3, o2, o1]
    show('(8)', lambda_string, actual, expected)
    expect(actual).to eq(expected)
  end

  it '(9) create_lambda with date (descending) and last_modified (ascending)' do
    lambda_string = JekyllAllCollections::AllCollectionsTag.create_lambda_string(['-date', 'last_modified'])
    expect(lambda_string).to eq('->(a, b) { [b.date, a.last_modified] <=> [a.date, b.last_modified] }')
    sort_lambda = self.eval lambda_string, binding
    actual = objs.sort(&sort_lambda)
    expected = [o4, o2, o3, o1]
    show('(9)', lambda_string, actual, expected)
    expect(actual).to eq(expected)
  end

  it '(10) create_lambda with date (ascending) and last_modified (descending)' do
    lambda_string = JekyllAllCollections::AllCollectionsTag.create_lambda_string(['date', '-last_modified'])
    expect(lambda_string).to eq('->(a, b) { [a.date, b.last_modified] <=> [b.date, a.last_modified] }')
    sort_lambda = self.eval lambda_string, binding
    actual = objs.sort(&sort_lambda)
    expected = [o1, o3, o2, o4]
    show('(10)', lambda_string, actual, expected)
    expect(actual).to eq(expected)
  end
end
