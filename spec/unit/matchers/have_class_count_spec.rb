require 'spec_helper'

describe 'RSpec::Puppet::ManifestMatchers.have_class_count' do
  subject(:example_group) { Class.new { extend RSpec::Puppet::ManifestMatchers } }
  let(:expected) { 123 }

  after do
    example_group.have_class_count(expected)
  end

  it 'initialises a CountGeneric matcher for Class resources' do
    expect(RSpec::Puppet::ManifestMatchers::CountGeneric).to receive(:new).with('class', expected)
  end
end
