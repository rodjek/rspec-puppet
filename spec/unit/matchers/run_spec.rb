require 'spec_helper'

describe RSpec::Puppet::FunctionMatchers::Run do
  it 'should call the lambda with no params' do
    received_params = nil
    if Puppet.version.to_f >= 4.0
      subject.matches?(lambda { |env, *params| received_params = params })
      expect(received_params).to eq([])
    else
      subject.matches?(lambda { |params| received_params = params })
      expect(received_params).to be_nil
    end
  end

  it 'should not match a lambda that raises an error' do
    expect(subject.matches?(lambda { |env, *params| raise StandardError, 'Forced Error' })).to be false
  end

  [ [], [true], [false], [''], ['string'], [nil], [0], [1.1], [[]], ['one', 'two'], [{}], [{ 'key' => 'value' }], [:undef] ].each do |supplied_params|
    context "with_params(#{supplied_params.collect { |p| p.inspect }.join(', ')})" do
      before(:each) { subject.with_params(*supplied_params) }

      it 'should call the lambda with the supplied params' do
        received_params = nil
        if Puppet.version.to_f >= 4.0
          subject.matches?(lambda { |env, *params| received_params = params })
        else
          subject.matches?(lambda { |params| received_params = params })
        end
        expect(received_params).to eq(supplied_params)
      end

      it 'should not match a lambda that raises an error' do
        expect(subject.matches?(lambda { |env, *params| raise StandardError, 'Forced Error' })).to be false
      end

      [ true, false, '', 'string', nil, 0, 1.1, [], {}, :undef ].each do |expected_return|
        context "and_return(#{expected_return.inspect})" do
          before(:each) { subject.and_return(expected_return) }

          it 'should match a lambda that does return the requested value' do
            expect(subject.matches?(lambda { |env, *params| expected_return })).to be true
          end

          it 'should not match a lambda that does return a different value' do
            expect(subject.matches?(lambda { |env, *params| !expected_return })).to be false
          end

          it 'should not match a lambda that raises an error' do
            expect(subject.matches?(lambda { |env, *params| raise StandardError, 'Forced Error' })).to be false
          end
        end
      end

      context "and_raise_error(ArgumentError)" do
        before(:each) { subject.and_raise_error(ArgumentError) }

        it 'should match a lambda that raises ArgumentError' do
          expect(subject.matches?(lambda { |env, *params| raise ArgumentError, 'Forced Error' })).to be true
        end

        [ true, false, '', 'string', nil, 0, 1.1, [], {}, :undef ].each do |value|
          it "should not match a lambda that returns #{value.inspect}" do
            expect(subject.matches?(lambda { |env, *params| value })).to be false
          end
        end

        it 'should not match a lambda that raises a different error' do
          expect(subject.matches?(lambda { |env, *params| raise StandardError, 'Forced Error' })).to be false
        end
      end

      context "and_raise_error(ArgumentError, /message/)" do
        before(:each) { subject.and_raise_error(ArgumentError, /message/) }

        it 'should match a lambda that raises ArgumentError("with matching message")' do
          expect(subject.matches?(lambda { |env, *params| raise ArgumentError, 'with matching message' })).to be true
        end

        it 'should not match a lambda that raises a different ArgumentError' do
          expect(subject.matches?(lambda { |env, *params| raise ArgumentError, 'Forced Error' })).to be false
        end

        [ true, false, '', 'string', nil, 0, 1.1, [], {}, :undef ].each do |value|
          it "should not match a lambda that returns #{value.inspect}" do
            expect(subject.matches?(lambda { |env, *params| value })).to be false
          end
        end

        it 'should not match a lambda that raises a different error' do
          expect(subject.matches?(lambda { |env, *params| raise StandardError, 'Forced Error' })).to be false
        end
      end
    end
  end
end
