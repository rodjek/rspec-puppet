require 'spec_helper'
require 'rspec-puppet/adapters'

def context_double(options = {})
  double({:environment => 'rp_puppet'}.merge(options))
end

describe RSpec::Puppet::Adapters::Base do
  describe '#setup_puppet' do
    it "sets up all settings listed in the settings map" do
      context = context_double
      expected_settings = Hash[*subject.settings_map.map { |r| [r.first, anything] }.flatten]
      expect(Puppet.settings).to receive(:initialize_app_defaults).with(hash_including(expected_settings))
      subject.setup_puppet(context)
    end
  end

  describe 'default settings' do
    before do
      subject.setup_puppet(context_double)
    end

    null_path = windows? ? 'c:/nul/' : '/dev/null'

    [:vardir, :confdir].each do |setting|
      it "sets #{setting} to #{null_path}" do
        expect(Puppet[setting]).to eq(File.expand_path(null_path))
      end
    end
  end

  describe '#set_setting' do
    describe "with a context specific setting" do
      it "sets the Puppet setting based on the example group setting" do
        context = context_double :confdir => "/etc/fingerpuppet"
        subject.setup_puppet(context)
        expect(Puppet[:confdir]).to match(%r{(C:)?/etc/fingerpuppet})
      end

      it "does not persist settings between example groups" do
        context1 = context_double :confdir => "/etc/fingerpuppet"
        context2 = context_double
        subject.setup_puppet(context1)
        expect(Puppet[:confdir]).to match(%r{(C:)?/etc/fingerpuppet})
        subject.setup_puppet(context2)
        expect(Puppet[:confdir]).not_to match(%r{(C:)?/etc/fingerpuppet})
      end
    end

    describe "with a global RSpec configuration setting" do
      before do
        allow(RSpec.configuration).to receive(:confdir).and_return("/etc/bunraku")
      end

      it "sets the Puppet setting based on the global configuration value" do
        subject.setup_puppet(context_double)
        expect(Puppet[:confdir]).to match(%r{(C:)?/etc/bunraku})
      end
    end

    describe "with both a global RSpec configuration setting and a context specific setting" do
      before do
        allow(RSpec.configuration).to receive(:confdir).and_return("/etc/bunraku")
      end

      it "prefers the context specific setting" do
        context = context_double :confdir => "/etc/sockpuppet"
        subject.setup_puppet(context)
        expect(Puppet[:confdir]).to match(%r{(C:)?/etc/sockpuppet})
      end
    end

    describe "when the setting is not available on the given version of Puppet" do
      it "logs a warning about the setting" do

      end
    end
  end
end

describe RSpec::Puppet::Adapters::Adapter35, :if => (3.5 ... 4.0).include?(Puppet.version.to_f) do

  let(:test_context) { double :environment => 'rp_env' }

  context 'when running on puppet 3.5 or later', :if => (3.5 ... 4.0).include?(Puppet.version.to_f) do
    it 'sets Puppet[:strict_variables] to false by default' do
      subject.setup_puppet(test_context)
      expect(Puppet[:strict_variables]).to eq(false)
    end

    it 'reads the :strict_variables setting' do
      allow(test_context).to receive(:strict_variables).and_return true
      subject.setup_puppet(test_context)
      expect(Puppet[:strict_variables]).to eq(true)
    end
  end

end

describe RSpec::Puppet::Adapters::Adapter34, :if => (3.4 ... 4.0).include?(Puppet.version.to_f) do

  let(:test_context) { double :environment => 'rp_env' }

  context 'when running on puppet 3.4 or later', :if => (3.4 ... 4.0).include?(Puppet.version.to_f) do
    it 'sets Puppet[:trusted_node_data] to false by default' do
      subject.setup_puppet(test_context)
      expect(Puppet[:trusted_node_data]).to eq(false)
    end

    it 'reads the :trusted_node_data setting' do
      allow(test_context).to receive(:trusted_node_data).and_return(true)
      subject.setup_puppet(test_context)
      expect(Puppet[:trusted_node_data]).to eq(true)
    end
  end

end

describe RSpec::Puppet::Adapters::Adapter33, :if => (3.3 ... 4.0).include?(Puppet.version.to_f) do

  let(:test_context) { double :environment => 'rp_env' }

  context 'when running on puppet ~> 3.3', :if => (3.3 ... 4.0).include?(Puppet.version.to_f) do
    it 'sets Puppet[:stringify_facts] to true by default' do
      subject.setup_puppet(test_context)
      expect(Puppet[:stringify_facts]).to eq(true)
    end

    it 'reads the :stringify_facts setting' do
      allow(test_context).to receive(:stringify_facts).and_return false
      subject.setup_puppet(test_context)
      expect(Puppet[:stringify_facts]).to eq(false)
    end

    it 'sets Puppet[:ordering] to title-hash by default' do
      subject.setup_puppet(test_context)
      expect(Puppet[:ordering]).to eq('title-hash')
    end

    it 'reads the :ordering setting' do
      allow(test_context).to receive(:ordering).and_return("manifest")
      subject.setup_puppet(test_context)
      expect(Puppet[:ordering]).to eq('manifest')
    end
  end

end

describe RSpec::Puppet::Adapters::Adapter32, :if => (3.2 ... 4.0).include?(Puppet.version.to_f) do

  let(:test_context) { double :environment => 'rp_env' }

  context 'when running on puppet ~> 3.2', :if => (3.2 ... 4.0).include?(Puppet.version.to_f) do
    it 'sets Puppet[:parser] to "current" by default' do
      subject.setup_puppet(test_context)
      expect(Puppet[:parser]).to eq("current")
    end

    it 'reads the :parser setting' do
      allow(test_context).to receive(:parser).and_return("future")
      subject.setup_puppet(test_context)
      expect(Puppet[:parser]).to eq("future")
    end
  end

  describe 'default settings' do
    before do
      subject.setup_puppet(context_double)
    end

    null_path = windows? ? 'c:/nul/' : '/dev/null'

    [:vardir, :rundir, :logdir, :hiera_config, :confdir].each do |setting|
      it "sets #{setting} to #{null_path}" do
        expect(Puppet[setting]).to eq(File.expand_path(null_path))
      end
    end
  end
end

describe RSpec::Puppet::Adapters::Adapter6X, :if => (6.0 ... 6.25).include?(Puppet.version.to_f) do

  let(:test_context) { double :environment => 'rp_env' }

  describe '#setup_puppet' do
    describe 'when managing the facter_implementation' do
      after(:each) do
        Object.send(:remove_const, :FacterImpl) if defined? FacterImpl
      end

      it 'warns and falls back if hash implementation is set and facter runtime is not supported' do
        context = context_double
        allow(RSpec.configuration).to receive(:facter_implementation).and_return('rspec')
        expect(subject).to receive(:warn)
          .with("Facter runtime implementations are not supported in Puppet #{Puppet.version}, continuing with facter_implementation 'facter'")
        subject.setup_puppet(context)
        expect(FacterImpl).to be(Facter)
      end
    end
  end
end

describe RSpec::Puppet::Adapters::Adapter6X, :if => Puppet::Util::Package.versioncmp(Puppet.version, '6.25.0') >= 0 do

  let(:test_context) { double :environment => 'rp_env' }

  describe '#setup_puppet' do
    describe 'when managing the facter_implementation' do
      after(:each) do
        Object.send(:remove_const, :FacterImpl) if defined? FacterImpl
      end

      it 'uses facter as default implementation' do
        context = context_double
        subject.setup_puppet(context)
        expect(FacterImpl).to be(Facter)
      end

      it 'uses the hash implementation if set and if puppet supports runtimes' do
        context = context_double
        Puppet.runtime[:facter] = 'something'
        allow(RSpec.configuration).to receive(:facter_implementation).and_return('rspec')
        subject.setup_puppet(context)
        expect(FacterImpl).to be_kind_of(RSpec::Puppet::FacterTestImpl)
      end

      it 'raises if given an unsupported option' do
        context = context_double
        allow(RSpec.configuration).to receive(:facter_implementation).and_return('salam')
        expect { subject.setup_puppet(context) }
          .to raise_error(RuntimeError, "Unsupported facter_implementation 'salam'")
      end
    end
  end
end

describe RSpec::Puppet::Adapters::Adapter4X, :if => (4.0 ... 6.0).include?(Puppet.version.to_f) do

  let(:test_context) { double :environment => 'rp_env' }

  it 'sets Puppet[:strict_variables] to false by default' do
    subject.setup_puppet(test_context)
    expect(Puppet[:strict_variables]).to eq(false)
  end

  it 'reads the :strict_variables setting' do
    allow(test_context).to receive(:strict_variables).and_return(true)
    subject.setup_puppet(test_context)
    expect(Puppet[:strict_variables]).to eq(true)
  end

  it 'overrides the environmentpath set by Puppet::Test::TestHelper' do
    allow(test_context).to receive(:environmentpath).and_return('/path/to/my/environments')
    subject.setup_puppet(test_context)
    expect(Puppet[:environmentpath]).to match(%r{(C:)?/path/to/my/environments})
  end

  describe '#manifest' do
    it 'returns the configured environment manifest when set' do
      allow(RSpec.configuration).to receive(:manifest).and_return("/path/to/manifest")
      subject.setup_puppet(double(:environment => 'rp_puppet'))
      expect(subject.manifest).to match(%r{(C:)?/path/to/manifest})
    end

    it 'returns nil when the configured environment manifest is not set' do
      allow(RSpec.configuration).to receive(:manifest)
      allow(RSpec.configuration).to receive(:environmentpath).and_return("/some/missing/path:/another/missing/path")
      subject.setup_puppet(double(:environment => 'rp_puppet'))
      expect(subject.manifest).to be_nil
    end
  end

  describe 'default settings' do
    before do
      subject.setup_puppet(context_double)
    end

    null_path = windows? ? 'c:/nul/' : '/dev/null'

    [:vardir, :codedir, :rundir, :logdir, :hiera_config, :confdir].each do |setting|
      it "sets #{setting} to #{null_path}" do
        expect(Puppet[setting]).to eq(File.expand_path(null_path))
      end
    end
  end
end
