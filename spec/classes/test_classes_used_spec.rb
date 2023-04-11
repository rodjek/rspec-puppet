# frozen_string_literal: true

require 'spec_helper'

describe 'test::classes_used' do
  it {
    expect(RSpec).to receive(:deprecate).with('include_class()', { replacement: 'contain_class()' })
    expect(subject).to include_class('test::bare_class')
  }

  it {
    expect(RSpec).to receive(:deprecate).with('include_class()', { replacement: 'contain_class()' })
    expect(subject).to include_class('test::parameterised_class')
  }

  it { is_expected.to contain_class('test::parameterised_class').with_text('bar') }
  it { is_expected.to contain_class('test::bare_class') }
  it { is_expected.to contain_class('test::parameterised_class').with_something(proc { |v| v.nil? || v.empty? }) }
end
