# frozen_string_literal: true

require 'spec_helper_unit'

describe 'RSpec::Puppet::ManifestMatchers.include_class' do
  subject(:matcher) { Class.new { extend RSpec::Puppet::ManifestMatchers }.include_class(expected) }

  let(:actual) do
    -> { instance_double(Puppet::Resource::Catalog, classes: included_classes) }
  end

  let(:expected) { 'test_class' }
  let(:included_classes) { [] }

  before do
    allow(RSpec).to receive(:deprecate).with('include_class()', replacement: 'contain_class()')
  end

  it 'is not a diffable matcher' do
    expect(matcher).not_to be_diffable
  end

  describe '#description' do
    it 'includes the expected class name' do
      expect(matcher.description).to eq("include Class[#{expected}]")
    end
  end

  describe '#matches?' do
    context 'when the catalogue includes the expected class' do
      let(:included_classes) { [expected] }

      it 'returns true' do
        expect(matcher).to be_matches(actual)
      end
    end

    context 'when the catalogue does not include the expected class' do
      let(:included_classes) { ['something_else'] }

      it 'returns false' do
        expect(matcher).not_to be_matches(actual)
      end
    end
  end

  describe '#failure_message' do
    it 'provides a description and the expected class' do
      matcher.matches?(actual)
      expect(matcher.failure_message).to eq("expected that the catalogue would include Class[#{expected}]")
    end
  end

  describe '#failure_message_when_negated' do
    let(:included_classes) { [expected] }

    it 'provides a description and the expected class' do
      pending 'not implemented'
      matcher.matches?(actual)
      expect(matcher.failure_message_when_negated).to eq("expected that the catalogue would not include Class[#{expected}]")
    end
  end
end
