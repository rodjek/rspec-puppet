# frozen_string_literal: true

require 'spec_helper'

describe '#rspec_puppet_cleanup' do
  it { expect(respond_to?(:rspec_puppet_cleanup)).to be true }

  it 'wipes @catalogue' do
    @type_and_resource = Object.new
    rspec_puppet_cleanup
    expect(@type_and_resource).to be_nil
  end
end
