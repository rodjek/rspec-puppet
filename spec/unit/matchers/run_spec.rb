require 'spec_helper'

describe RSpec::Puppet::FunctionMatchers::Run do
  let (:wrapper) { double("function wrapper") }

  before :each do
    expect(wrapper).to receive(:call).never
  end

  it 'should call the wrapper with no params' do
    expect(wrapper).to receive(:execute).with(no_args).once
    expect(subject.matches?(wrapper)).to be true
  end

  it 'should not match a wrapper that raises an error' do
    expect(wrapper).to receive(:execute).and_raise(StandardError, 'Forced Error').once
    expect(subject.matches?(wrapper)).to be false
  end

  [[true], [false], [''], ['string'], [nil], [0], [1.1], [[]], %w(one two), [{}], [{ 'key' => 'value' }], [:undef]].each do |supplied_params|
    context "with_params(#{supplied_params.collect(&:inspect).join(', ')})" do
      before(:each) { subject.with_params(*supplied_params) }

      it 'should call the wrapper with the supplied params' do
        expect(wrapper).to receive(:execute).with(*supplied_params).once
        expect(subject.matches?(wrapper)).to be true
      end

      it 'should not match a wrapper that raises an error' do
        expect(wrapper).to receive(:execute).and_raise(StandardError, 'Forced Error').once
        expect(subject.matches?(wrapper)).to be false
      end
    end

    [true, false, '', 'string', nil, 0, 1.1, [], {}, :undef].each do |expected_return|
      context "and_return(#{expected_return.inspect})" do
        before(:each) { subject.and_return(expected_return) }

        it 'should match a wrapper that does return the requested value' do
          expect(wrapper).to receive(:execute).and_return(expected_return).once
          expect(subject.matches?(wrapper)).to be true
        end

        it 'should not match a wrapper that does return a different value' do
          expect(wrapper).to receive(:execute).and_return(!expected_return).once
          expect(subject.matches?(wrapper)).to be false
        end
      end

      context "and_raise_error(ArgumentError)" do
        before(:each) { subject.and_raise_error(ArgumentError) }

        it 'should match a wrapper that raises ArgumentError' do
          expect(wrapper).to receive(:execute).and_raise(ArgumentError, 'Forced Error').once
          expect(subject.matches?(wrapper)).to be true
        end

        [true, false, '', 'string', nil, 0, 1.1, [], {}, :undef].each do |value|
          it "should not match a wrapper that returns #{value.inspect}" do
            expect(wrapper).to receive(:execute).and_return(value).once
            expect(subject.matches?(wrapper)).to be false
          end
        end

        it 'should not match a wrapper that raises a different error' do
          expect(wrapper).to receive(:execute).and_raise(StandardError, 'Forced Error').once
          expect(subject.matches?(wrapper)).to be false
        end
      end

      context "and_raise_error(ArgumentError, /message/)" do
        before(:each) { subject.and_raise_error(ArgumentError, /message/) }

        it 'should match a wrapper that raises ArgumentError("with matching message")' do
          expect(wrapper).to receive(:execute).and_raise(ArgumentError, 'with matching message').once
          expect(subject.matches?(wrapper)).to be true
        end

        it 'should not match a wrapper that raises a different ArgumentError' do
          expect(wrapper).to receive(:execute).and_raise(ArgumentError, 'Forced Error').once
          expect(subject.matches?(wrapper)).to be false
        end

        [true, false, '', 'string', nil, 0, 1.1, [], {}, :undef].each do |value|
          it "should not match a wrapper that returns #{value.inspect}" do
            expect(wrapper).to receive(:execute).and_return(value).once
            expect(subject.matches?(wrapper)).to be false
          end
        end

        it 'should not match a wrapper that raises a different error' do
          expect(wrapper).to receive(:execute).and_raise(StandardError, 'Forced Error').once
          expect(subject.matches?(wrapper)).to be false
        end
      end
    end
  end
end
