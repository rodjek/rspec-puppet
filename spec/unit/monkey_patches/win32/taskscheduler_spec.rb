require 'spec_helper'

describe ::Win32::TaskScheduler do
  subject { described_class }

  let(:stub_class) { RSpec::Puppet::Win32::TaskScheduler }


  context 'on non-windows', :unless => windows? do
    it { should_not be_nil }

    it 'uses the stubbed rspec-puppet version' do
      should eq(stub_class)
    end
  end

  context 'on windows', :if => windows? do
    ignored_consts = [
      :VERSION,
      :FORMAT_MESSAGE_IGNORE_INSERTS,
      :FORMAT_MESSAGE_FROM_SYSTEM,
      :FORMAT_MESSAGE_MAX_WIDTH_MASK,
      :Error,
      :TaskSchedulerConstants,
      :IdleSettings,
      :SID,
      :Helper,
      :TimeCalcHelper,
      :BUILT_IN_GROUPS,
      :SERVICE_ACCOUNT_USERS,
      :ERROR_INSUFFICIENT_BUFFER,
      :SYSTEM_USERS,
    ]

    it { should_not be_nil }

    it 'does not use the stubbed rspec-puppet version' do
      should_not eq(stub_class)
    end

    described_class.constants.each do |const_name|
      next if ignored_consts.include?(const_name)

      context const_name.to_s do
        subject { described_class.const_get(const_name) }

        it { should eq(stub_class.const_get(const_name)) }
      end
    end
  end
end
