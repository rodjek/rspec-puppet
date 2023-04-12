# frozen_string_literal: true

require 'spec_helper'

describe 'nasty' do
  it { expect(subject).not_to be_nil }
  it { expect(subject).to run.with_params('foo', 'bar').and_return('foo') }

  describe 'the underlying Run matcher' do
    it 'does not have its description manipulated by running the function' do
      run_matcher = run.with_params('foo', 'bar').and_return('foo')
      expect(subject).to run_matcher
      expect(run_matcher.description).to eq('run nasty("foo", "bar") and return "foo"')
    end
  end
end
