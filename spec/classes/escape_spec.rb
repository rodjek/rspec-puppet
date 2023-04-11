# frozen_string_literal: true

require 'spec_helper'

describe 'escape' do
  let(:params) { { content: '$MSG foo' } }

  it { is_expected.to contain_file('/tmp/escape').with_content(/\$MSG foo/) }
end
