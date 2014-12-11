require 'spec_helper'

def my_bool_func(boolean)
  return boolean
end


describe RSpec::Puppet::FunctionMatchers::Run do
  describe 'and_return()' do
    context 'with_params(true)' do
      subject do
        described_class.new()
          .with_params(true)
          .and_return(false)
      end

      it 'failure message is: have returned x instead of y' do
        subject.matches?(self.method(:my_bool_func))
        expect(subject.failure_message).to eq('expected my_bool_func(true) to have returned false instead of [true]')
      end
    end

    context 'with_params(false)' do
      subject do
        described_class.new()
          .with_params(false)
          .and_return(true)
      end

      it 'failure message is: have returned x instead of y' do
        subject.matches?(self.method(:my_bool_func))
        expect(subject.failure_message).to eq('expected my_bool_func(false) to have returned true instead of [false]')
      end
    end
  end
end
