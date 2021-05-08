require 'spec_helper'

describe 'tags_testing' do
  it { should compile }
  it { should contain_class('sysctl::common')
                .tagged('sysctl')
                .tagged('keyword_tag')
                .not_tagged('no_such_tag')
  }
  it { should contain_file('/tmp/a')
                .tagged('keyword_tag')
                .not_tagged('not_even_this')
                .not_tagged('metaparam_tag')
  }
  it { should contain_file('/tmp/b')
                .with_ensure('present')
                .tagged(['keyword_tag', 'metaparam_tag'])
  }
end
