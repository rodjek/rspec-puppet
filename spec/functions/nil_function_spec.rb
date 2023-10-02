# frozen_string_literal: true

require 'spec_helper'

describe 'nil_function' do
  it { is_expected.to run.with_params(false).and_return(nil) }
  it { is_expected.to run.with_params(true).and_raise_error(Puppet::ParseError, /Forced Failure - new version/) }
end
