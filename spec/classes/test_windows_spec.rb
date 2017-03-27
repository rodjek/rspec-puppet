require 'spec_helper'

describe 'test::windows' do
  let(:facts) { {:operatingsystem => 'windows'} }

  it { should compile.with_all_deps }
end
