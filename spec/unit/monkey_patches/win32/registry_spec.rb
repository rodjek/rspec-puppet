require 'spec_helper'

describe ::Win32::Registry do
  subject { described_class }

  let(:stub_class) { RSpec::Puppet::Win32::Registry }


  context 'on non-windows', :unless => windows? do
    it { should_not be_nil }

    it 'uses the stubbed rspec-puppet version' do
      should eq(stub_class)
    end
  end

  context 'on windows', :if => windows? do

    it { should_not be_nil }

    it 'does not use the stubbed rspec-puppet version' do
      should_not eq(stub_class)
    end

    describe ::Win32::Registry::Constants do

      described_class.constants.each do |const_name|
        context const_name.to_s do
          subject { described_class.const_get(const_name) }

          it { should eq(stub_class.const_get(const_name)) }
        end
      end
    end
  end
end
