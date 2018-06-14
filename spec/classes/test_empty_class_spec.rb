require 'spec_helper'

describe 'test::empty_class' do
  it { should compile }

  context 'exported resources' do
    subject { exported_resources }

    it { should have_resource_count(0) }
  end
end
