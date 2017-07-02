require 'spec_helper'

describe 'test::basic' do
  it { should contain_fake('foo').with_three([{'foo' => 'bar'}]) }

  context 'testing node based facts' do
    let(:pre_condition) { 'notify { $::fqdn: }' }
    let(:node) { 'test123.test.com' }
    let(:facts) do
      {
        :fqdn => 'notthis.test.com',
      }
    end

    it { should contain_notify('test123.test.com') }
    it { should_not contain_notify('notthis.test.com') }
  end
end
