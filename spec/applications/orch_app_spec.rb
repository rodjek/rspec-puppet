require 'spec_helper'

describe 'orch_app', :if => Puppet.version.to_f >= 4.3 do
  let(:node) { 'my_node' }
  let(:title) { 'my_awesome_app' }
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
