# frozen_string_literal: true

require 'spec_helper'

describe 'test::empty_class' do
  it { is_expected.to compile }

  context 'exported resources' do
    subject { exported_resources }

    it { is_expected.to have_resource_count(0) }
  end
end
