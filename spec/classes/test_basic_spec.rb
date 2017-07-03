require 'spec_helper'

describe 'test::basic' do
  it { should contain_fake('foo').with_three([{'foo' => 'bar'}]) }

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

    context 'existing networking facts should not be clobbered', :if => Puppet.version.to_f >= 4.0 do
      let(:pre_condition) { 'notify { [$facts["networking"]["primary"], $facts["networking"]["hostname"]]: }' }

      it { should contain_notify('eth0') }
      it { should contain_notify('test123') }
    end
  end
end
