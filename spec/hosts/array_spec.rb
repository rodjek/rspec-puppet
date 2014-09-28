require 'spec_helper'

describe 'someotherhost' do
  let(:pre_condition) { <<-EOF
    define foo($param) {
    }

    foo { 'bar':
      param => ['baz'],
    }
    EOF
  }

  it { is_expected.to contain_foo('bar').with_param(['baz']) }
end
