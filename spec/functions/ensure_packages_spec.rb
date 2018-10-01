require 'spec_helper'

describe 'ensure_packages' do
  before { subject.execute('facter') }

  it 'should create the resource in the catalogue' do
    expect(catalogue).to contain_package('facter').with_ensure('present')
    expect(lambda { catalogue }).to contain_package('facter').with_ensure('present')
  end
end
