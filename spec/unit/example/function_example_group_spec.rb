# frozen_string_literal: true

require 'spec_helper'

describe RSpec::Puppet::FunctionExampleGroup::V4FunctionWrapper do
  let(:name) { 'test_function' }
  let(:func) { double('func') }
  let(:global_scope) { double('global_scope') }
  let(:overrides) { { global_scope: global_scope } }

  describe 'when calling with params' do
    subject { described_class.new(name, func, overrides) }

    it do
      expect(func).to receive(:call).with(global_scope, 1, 2).once
      subject.call({}, 1, 2)
    end
  end

  describe 'when executing with params' do
    subject { described_class.new(name, func, overrides) }

    it do
      expect(func).to receive(:call).with(global_scope, 1, 2).once
      subject.execute(1, 2)
    end
  end
end

describe RSpec::Puppet::FunctionExampleGroup::V3FunctionWrapper do
  let(:name) { 'test_function' }
  let(:func) { double('func') }

  describe 'when calling with params' do
    subject { described_class.new(name, func) }

    it do
      expect(func).to receive(:call).with([1, 2]).once
      subject.call([1, 2])
    end
  end

  describe 'when executing with params' do
    subject { described_class.new(name, func) }

    it do
      expect(func).to receive(:call).with([1, 2]).once
      subject.execute(1, 2)
    end
  end
end
