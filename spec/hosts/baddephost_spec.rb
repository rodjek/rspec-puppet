require 'spec_helper'

describe 'baddephost' do
  it do
    expect do
      should include_all_deps()
    end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
  end
end
