# frozen_string_literal: true

require 'spec_helper'

describe Win32::Registry do
  subject { described_class }

  let(:stub_class) { RSpec::Puppet::Win32::Registry }

  context 'on non-windows', unless: windows? do
    it { is_expected.not_to be_nil }

    it 'uses the stubbed rspec-puppet version' do
      expect(subject).to eq(stub_class)
    end
  end

  context 'on windows', if: windows? do
    it { is_expected.not_to be_nil }

    it 'does not use the stubbed rspec-puppet version' do
      expect(subject).not_to eq(stub_class)
    end

    describe Win32::Registry::Constants do
      described_class.constants.each do |const_name|
        context const_name.to_s do
          subject { described_class.const_get(const_name) }

          it { is_expected.to eq(stub_class.const_get(const_name)) }
        end
      end
    end
  end
end
