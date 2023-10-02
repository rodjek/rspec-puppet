# frozen_string_literal: true

require 'spec_helper'
require 'rspec-puppet/support'

describe RSpec::Puppet::TypeAliasMatchers::AllowValue do
  subject { described_class.new(values) }

  let(:catalogue) { double('catalogue builder') }

  describe 'one matching value' do
    let(:values) { ['circle'] }

    before { allow(catalogue).to receive(:call).with('circle') }

    describe '#matches?' do
      it { expect(subject.matches?(catalogue)).to be true }
    end

    describe '#description' do
      it { expect(subject.description).to eq('match value "circle"') }
    end
  end

  describe 'one incorrect value' do
    let(:values) { ['circle'] }

    before do
      allow(catalogue).to receive(:call).with('circle').and_raise(Puppet::Error.new('expected a Shape value, got circle'))
    end

    describe '#matches?' do
      it { expect(subject.matches?(catalogue)).to be false }
    end

    describe '#description' do
      it { expect(subject.description).to eq('match value "circle"') }
    end

    describe '#failure_message' do
      before { subject.matches?(catalogue) }

      it {
        expect(subject.failure_message).to eq('expected that the type alias would match value "circle" but it raised the error expected a Shape value, got circle')
      }
    end

    describe '#failure_message_when_negated' do
      it {
        expect(subject.failure_message_when_negated).to eq('expected that the type alias would not match value "circle" but it does')
      }
    end
  end

  describe 'multiple matching values' do
    let(:values) { %w[circle square] }

    before do
      allow(catalogue).to receive(:call).with('circle')
      allow(catalogue).to receive(:call).with('square')
    end

    describe '#matches?' do
      it { expect(subject.matches?(catalogue)).to be true }
    end

    describe '#description' do
      it { expect(subject.description).to eq('match values "circle", "square"') }
    end
  end

  describe 'mixed matching/incorrect values' do
    let(:values) { %w[circle square triangle] }

    before do
      allow(catalogue).to receive(:call).with('circle').and_raise(Puppet::Error.new('expected a Shape value, got circle'))
      allow(catalogue).to receive(:call).with('triangle').and_raise(Puppet::Error.new('expected a Shape value, got triangle'))
      allow(catalogue).to receive(:call).with('square')
    end

    describe '#matches?' do
      it { expect(subject.matches?(catalogue)).to be false }
    end

    describe '#description' do
      it { expect(subject.description).to eq('match values "circle", "square", "triangle"') }
    end

    describe '#failure_message' do
      before { subject.matches?(catalogue) }

      it {
        expect(subject.failure_message).to eq('expected that the type alias would match values "circle", "square", "triangle" but it raised the errors expected a Shape value, got circle, expected a Shape value, got triangle')
      }
    end

    describe '#failure_message_when_negated' do
      it {
        expect(subject.failure_message_when_negated).to eq('expected that the type alias would not match values "circle", "square", "triangle" but it does')
      }
    end
  end
end
