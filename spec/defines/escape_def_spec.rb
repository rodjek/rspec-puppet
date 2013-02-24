require 'spec_helper'

describe 'escape::def' do
  let(:title) { '/tmp/bla' }
  let(:params) { {:content => 'bar $BLA'} }

  it { should contain_file('/tmp/bla').with_content(/bar \$BLA/) }
end
