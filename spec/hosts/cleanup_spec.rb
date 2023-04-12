# frozen_string_literal: true

require 'spec_helper'

describe '#rspec_puppet_cleanup' do
  it { expect(respond_to?(:rspec_puppet_cleanup)).to be true }

  it 'wipes @catalogue' do
    @catalogue = Object.new
    rspec_puppet_cleanup
    expect(@catalogue).to be_nil
  end
end
