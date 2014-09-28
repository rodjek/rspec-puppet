require 'spec_helper'

describe 'escape::def' do
  let(:title) { '/tmp/bla' }
  let(:params) { {:content => 'bar $BLA'} }

  it { is_expected.to contain_file('/tmp/bla').with_content(/bar \$BLA/) }
end
