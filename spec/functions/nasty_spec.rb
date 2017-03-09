require 'spec_helper'

describe 'nasty' do

  it { expect(subject).not_to eq(nil) }
  it { expect(subject).to run.with_params('foo', 'bar').and_return('foo') }

  describe 'the underlying Run matcher' do
    it 'should not have its description manipulated by running the function' do
      run_matcher = run.with_params('foo', 'bar').and_return('foo')
      should run_matcher
      expect(run_matcher.description).to eq('run nasty("foo", "bar") and return "foo"')
    end
  end
end
