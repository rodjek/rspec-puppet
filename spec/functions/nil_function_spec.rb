# frozen_string_literal: true

require 'spec_helper'

describe 'nil_function' do
  let(:version) do
    if (Puppet[:parser] == 'future') || (Puppet.version.to_f >= 4)
      'new version'
    else
      'old version'
    end
  end

  it { is_expected.to run.with_params(false).and_return(nil) }
  it { is_expected.to run.with_params(true).and_raise_error(Puppet::ParseError, /Forced Failure/) }

  it { is_expected.to run.with_params(true).and_raise_error(Puppet::ParseError, /Forced Failure - #{version}/) }
end
