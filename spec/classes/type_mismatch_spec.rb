require 'spec_helper'

describe 'type_mismatch', :if => Puppet.version.to_f >= 4.0 do
  it { should compile.with_all_deps }

  it do
    should_not contain_type_mismatch__hash('bug').with_hash(
      'foo' => {
        'bar' => {},
      }
    )
  end

  it do
    expect {
      should_not contain_type_mismatch__hash('bug').with_hash(
        'foo' => {
          'bar' => {},
        }
      )
    }.to_not raise_error
  end
end
