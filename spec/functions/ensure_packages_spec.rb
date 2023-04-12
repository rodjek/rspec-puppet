# frozen_string_literal: true

require 'spec_helper'

describe 'ensure_packages' do
  before { subject.execute('facter') }

  it 'creates the resource in the catalogue' do
    expect(catalogue).to contain_package('facter').with_ensure('present')
    expect(-> { catalogue }).to contain_package('facter').with_ensure('present')
  end
end
