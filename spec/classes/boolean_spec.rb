# frozen_string_literal: true

require 'spec_helper'

unless Puppet::PUPPETVERSION.include?('0.2')
  describe 'boolean_test' do
    let(:title) { 'bool.testing' }
    let(:params) { { bool: false } }

    it {
      expect(subject).to create_notify('bool testing')
        .with_message('This will print when $bool is false.')
    }
  end
end
