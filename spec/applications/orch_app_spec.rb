require 'spec_helper'

describe 'orch_app', :if => Puppet::Util::Package.versioncmp(Puppet.version, '4.3.0') >= 0 do
  let(:node) { 'my_node' }
  let(:title) { 'my_awesome_app' }

  context 'with params' do
    let(:params) do
      {
        :nodes => {
          ref('Node', node) => ref('Orch_app::Db', title),
        },
        :mystring => 'foobar',
      }
    end

    it { should compile }
    it { should contain_orch_app(title) }
    it { should contain_orch_app__db(title) }
  end

  context 'missing params' do
    it { expect { should compile }.to raise_error(ArgumentError, /provide params for an app/) }
  end
end
