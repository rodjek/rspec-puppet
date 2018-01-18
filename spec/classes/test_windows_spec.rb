require 'spec_helper'

describe 'test::windows' do
  let(:facts) { {:operatingsystem => 'windows' } }

  let(:symlink_path) do
    RUBY_VERSION == '1.8.7' ? 'C:\\\\something.txt' : 'C:\\something.txt'
  end

  it { should compile.with_all_deps }
  it { should contain_file(symlink_path) }
end
