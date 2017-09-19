require 'spec_helper'

describe 'test::basic' do
  it { should contain_fake('foo').with_three([{'foo' => 'bar'}]) }

  context 'using the new syntax', :if => RSpec::Core::Version::STRING.start_with?('3') do
    describe puppet_resource('fake', 'foo') do
      it { is_expected.to be_in_catalogue }
      its(:params) { is_expected.to include(:three => [{'foo' => 'bar'}]) }
    end
  end

  context 'testing node based facts' do
    let(:pre_condition) { 'notify { $::fqdn: }' }
    let(:node) { 'test123.test.com' }
    let(:facts) do
      {
        :fqdn       => 'notthis.test.com',
        :networking => {
          :primary => 'eth0',
        },
      }
    end

    it { should contain_notify('test123.test.com') }
    it { should_not contain_notify('notthis.test.com') }

    context 'using the new syntax', :if => RSpec::Core::Version::STRING.start_with?('3') do
      describe puppet_resource('notify', 'test123.test.com') do
        it { is_expected.to exist }
      end

      describe puppet_resource('notify', 'notthis.test.com') do
        it { is_expected.not_to exist }
      end
    end

    context 'existing networking facts should not be clobbered', :if => Puppet.version.to_f >= 4.0 do
      let(:pre_condition) { 'notify { [$facts["networking"]["primary"], $facts["networking"]["hostname"]]: }' }

      it { should contain_notify('eth0') }
      it { should contain_notify('test123') }

      context 'using the new syntax', :if => RSpec::Core::Version::STRING.start_with?('3') do
        describe puppet_resource('notify', 'eth0') do
          it { is_expected.to exist }
        end

        describe puppet_resource('notify', 'test123') do
          it { is_expected.to exist }
        end
      end
    end

    context 'when derive_node_facts_from_nodename => false' do
      let(:pre_condition) { 'notify { $::fqdn: }' }
      let(:node) { 'mycertname.test.com' }
      let(:facts) do
        {
          :fqdn => 'myhostname.test.com',
        }
      end

      before do
        RSpec.configuration.derive_node_facts_from_nodename = false
      end

      it { should contain_notify('myhostname.test.com') }
      it { should_not contain_notify('mycertname.test.com') }

      context 'using the new syntax', :if => RSpec::Core::Version::STRING.start_with?('3') do
        describe puppet_resource('notify', 'myhostname.test.com') do
          it { is_expected.to exist }
        end

        describe puppet_resource('notify', 'mycertname.test.com') do
          it { is_expected.not_to exist }
        end
      end
    end
  end
end
