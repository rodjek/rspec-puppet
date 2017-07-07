require 'spec_helper'

describe 'someotherhost' do
  let(:pre_condition) do
    <<-EOF
      define foo($param) {
      }

      foo { 'bar':
        param => ['baz'],
      }
    EOF
  end

  it { should contain_foo('bar').with_param(['baz']) }
end
