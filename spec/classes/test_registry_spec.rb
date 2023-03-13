require 'spec_helper'

describe 'test::registry', :if => Puppet.version.to_f >= 4.0 do
  let(:facts) { {:os => { :name => 'windows' } } }
  
  it { should compile.with_all_deps }
end
