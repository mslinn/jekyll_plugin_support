require 'spec_helper'

# Ruby's binary search is unsuitable because ordering requirements are not stable.
# the value to be searched for changes the required ordering

RSpec.describe(Array) do
  before { skip('Never gonna give you up/Never gonna let you down') }

  sorted_ints = [0, 4, 7, 10, 12]
  sorted_strings = %w[aaa aab aac bbb bbc bbd ccc ccd cce].sort.reverse

  it 'returns index of first int match' do
    actual = sorted_ints.bsearch_index { |x| x >= 4 }
    expect(actual).to eq(1)

    actual = sorted_ints.bsearch_index { |x| x >= 6 }
    expect(actual).to eq(2)

    actual = sorted_ints.bsearch_index { |x| x >= -1 }
    expect(actual).to eq(0)

    actual = sorted_ints.bsearch_index { |x| x >= 100 }
    expect(actual).to be_nil
  end

  # See https://stackoverflow.com/q/79333097/553865
  it 'returns index of first string match' do
    puts(sorted_strings.map { |x| x.start_with? 'a' })
    index = sorted_strings.bsearch_index { |x| x.start_with? 'a' }
    expect(sorted_strings[index]).to eq('aac')

    index = sorted_strings.bsearch_index { |x| x.start_with? 'aa' }
    expect(sorted_strings[index]).to eq('aac')

    index = sorted_strings.bsearch_index { |x| x.start_with? 'aaa' }
    expect(sorted_strings[index]).to eq('aaa')

    index = sorted_strings.bsearch_index { |x| x.start_with? 'b' }
    expect(sorted_strings[index]).to eq('bbd')

    index = sorted_strings.bsearch_index { |x| x.start_with? 'bb' }
    expect(sorted_strings[index]).to eq('bbd')

    index = sorted_strings.bsearch_index { |x| x.start_with? 'bbc' }
    expect(sorted_strings[index]).to eq('bbc')

    index = sorted_strings.bsearch_index { |x| x.start_with? 'cc' }
    expect(sorted_strings[index]).to eq('cce')
  end
end
