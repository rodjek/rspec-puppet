require 'spec_helper'

describe RSpec::Puppet::ManifestMatchers::ParameterMatcher do
  describe '#matches?' do
    context 'with [1] expected' do
      subject do
        described_class.new(:foo_parameter, [1], :should)
      end

      it 'matches [1]' do
        expect(subject.matches?(:foo_parameter => [1])).to be(true)
      end
      it 'does not match []' do
        expect(subject.matches?(:foo_parameter => [])).to be(false)
      end
      it 'does not match [1,2,3]' do
        expect(subject.matches?(:foo_parameter => [1, 2, 3])).to be(false)
      end
      it 'does not match nil' do
        expect(subject.matches?(:foo_parameter => nil)).to be(false)
      end
    end
    context 'with [1,2,3] expected' do
      subject do
        described_class.new(:foo_parameter, [1, 2, 3], :should)
      end

      it 'matches [1,2,3]' do
        expect(subject.matches?(:foo_parameter => [1, 2, 3])).to be(true)
      end
      it 'does not match []' do
        expect(subject.matches?(:foo_parameter => [])).to be(false)
      end
      it 'does not match nil' do
        expect(subject.matches?(:foo_parameter => nil)).to be(false)
      end
    end
    context 'with {"foo" => "bar"} expected' do
      subject do
        described_class.new(:foo_parameter, {"foo" => "bar"}, :should)
      end

      it 'matches {"foo" => "bar"}' do
        expect(subject.matches?(:foo_parameter => {"foo" => "bar"})).to be(true)
      end
      it 'does not match nil' do
        expect(subject.matches?(:foo_parameter => nil)).to be(false)
      end
      it 'does not match {}' do
        expect(subject.matches?(:foo_parameter => {})).to be(false)
      end
      it 'does not match {"foo" => "baz"}' do
        expect(subject.matches?(:foo_parameter => {"foo" => "baz"})).to be(false)
      end
    end

    context 'with lambda(){"foo"} expected' do
      subject do
        block = lambda {|actual| actual == "foo" }
        described_class.new(:foo_parameter, block, :should)
      end

      it 'matches "foo"' do
        expect(subject.matches?(:foo_parameter => "foo")).to be(true)
      end
      it 'does not match nil' do
        expect(subject.matches?(:foo_parameter => nil)).to be(false)
      end
    end

    context 'with /foo/ expected' do
      subject do
        described_class.new(:foo_parameter, /foo/, :should)
      end

      it 'matches "foo"' do
        expect(subject.matches?(:foo_parameter => "foo")).to be(true)
      end
      it 'does not match nil' do
        expect(subject.matches?(:foo_parameter => nil)).to be(false)
      end
    end

    context 'with "foo" expected' do
      subject do
        described_class.new(:foo_parameter, "foo", :should)
      end

      it 'matches "foo"' do
        expect(subject.matches?(:foo_parameter => "foo")).to be(true)
      end
      it 'does not match nil' do
        expect(subject.matches?(:foo_parameter => nil)).to be(false)
      end
    end
  end
end
