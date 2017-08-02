require 'spec_helper'

describe 'good_dep_host' do
  let(:facts) { { 'operatingsystem' => 'Debian' } }

  it { should compile.with_all_deps }
end
