require 'spec_helper'

# Exploring how to set date attributes in an object

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
  let(:obj) { described_class.new('2000-01-01', '2001-01-01') }

  it 'can send date' do
    date = obj.send :date
    expect(obj.date).to eq(date)
  end

  it 'can send last_modified' do
    last_modified = obj.send :last_modified
    expect(obj.last_modified).to eq(last_modified)
  end
end
