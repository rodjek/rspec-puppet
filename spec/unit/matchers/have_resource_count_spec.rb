require 'spec_helper'

describe 'RSpec::Puppet::ManifestMatchers.have_resource_count' do
  subject(:example_group) { Class.new { extend RSpec::Puppet::ManifestMatchers } }
  let(:expected) { 123 }

  after do
    example_group.have_resource_count(expected)
  end

  it 'initialises a CountGeneric matcher for all resources' do
    expect(RSpec::Puppet::ManifestMatchers::CountGeneric).to receive(:new).with('resource', expected)
  end
end
