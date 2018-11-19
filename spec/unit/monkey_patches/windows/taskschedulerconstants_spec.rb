require 'spec_helper'

klass = if defined?(::Win32::TaskScheduler::TaskSchedulerConstants)
          ::Win32::TaskScheduler::TaskSchedulerConstants
        else
          ::Windows::TaskSchedulerConstants
        end

describe klass do
  subject { described_class }

  let(:stub_class) { RSpec::Puppet::Windows::TaskSchedulerConstants }


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
      :SERVICE_ACCOUNT_USERS,
      :BUILT_IN_GROUPS,
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
