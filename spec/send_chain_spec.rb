require 'spec_helper'
require_relative '../lib/util/send_chain'

unless defined? LruFile
  LruFile = Struct.new(:url, :page) do
    include SendChain
  end
end

RSpec.describe(LruFile) do
  lru_file = described_class.new 'abc', 'def'

  it 'can perform a simple call if no arguments are required' do
    # Equivalent to: lru_file.url.reverse
    actual = lru_file.send_chain %i[url reverse]
    expect(actual).to eq('cba')
  end

  it 'can accept a scalar argument in stages' do
    lru_file.new_chain [:url, %i[end_with? placeholder]]
    # Equivalent to: lru_file.url.end_with?('bc')
    substituted_chain = lru_file.substitute_chain_with 'bc'
    actual = lru_file.send_chain substituted_chain
    expect(actual).to be true
  end

  it 'can accept a vector argument in stages' do
    lru_file.new_chain [:url, %i[end_with? placeholder]]
    # Next 2 lines are equivalent to: lru_file.url.end_with?('bc')
    substituted_chain = lru_file.substitute_chain_with ['bc']
    actual = lru_file.send_chain substituted_chain
    expect(actual).to be true
  end

  it 'can accept a scalar argument in one stage' do
    lru_file.new_chain [:url, %i[end_with? placeholder]]
    # Equivalent to: lru_file.url.end_with?('bc')
    actual = lru_file.substitute_and_send_chain_with 'bc'
    expect(actual).to be true
  end

  it 'can accept an array argument in one stage' do
    lru_file.new_chain [:url, %i[end_with? placeholder]]
    # Equivalent to: lru_file.url.end_with?('bc')
    actual = lru_file.substitute_and_send_chain_with ['bc']
    expect(actual).to be true
  end

  it 'can use the evaluate_with alias' do
    lru_file.new_chain [:url, %i[end_with? placeholder]]
    # Equivalent to: lru_file.url.end_with?('bc')
    actual = lru_file.evaluate_with ['bc']
    expect(actual).to be true
  end

  it 'can reuse the chain with different values' do
    lru_file.new_chain [:url, %i[end_with? placeholder]]

    # Equivalent to: lru_file.url.end_with?('bc')
    actual = lru_file.substitute_and_send_chain_with 'bc'
    expect(actual).to be true

    # Equivalent to: lru_file.url.end_with?('abc')
    substituted_chain = lru_file.substitute_chain_with ['abc']
    actual = lru_file.send_chain substituted_chain
    expect(actual).to be true

    # Equivalent to: lru_file.url.end_with?('de')
    actual = lru_file.substitute_and_send_chain_with 'de'
    expect(actual).to be false
  end
end
