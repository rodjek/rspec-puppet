require 'spec_helper'

describe 'node_params', :if => Puppet::Util::Package.versioncmp(Puppet.version, '3.0.0') >= 0 do
  fuzzed = {
    :string => 'foo bar baz',
    :hash => { 'foo' => 'bar', 'baz' => 'foo' },
    :array => %w[baz foo bar],
    :true => true,
    :false => false,
    :integer => 5,
    :float => 4.4,
    :nil => nil
  }

  let(:node_params) { fuzzed }

  it 'compiles into a catalogue without dependency cycles' do
    is_expected.to compile.with_all_deps
    is_expected.to contain_class('node_params')
  end

  fuzzed.each do |title, message|
    it "contains Notify[#{title}] with message => #{message}" do
      is_expected.to contain_notify(title.to_s).with(:message => message)
    end
  end

  it "doesn't leak to the facts hash", :if => Puppet::Util::Package.versioncmp(Puppet.version, '4.0.0') >= 0 do
    is_expected.to contain_notify('stringfact').with(:message => '')
  end
end
