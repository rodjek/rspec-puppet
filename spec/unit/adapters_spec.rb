require 'spec_helper'
require 'rspec-puppet/adapters'

describe RSpec::Puppet::Adapters::Base do
  describe '#setup_puppet' do
    it "sets up all settings listed in the settings map" do
      context = double :environment => 'rp_puppet'
      subject.settings_map.each do |puppet_setting, rspec_setting|
        expect(subject).to receive(:set_setting).with(context, puppet_setting, rspec_setting)
      end
      subject.setup_puppet(context)
    end
  end

  describe '#set_setting' do
    describe "with a context specific setting" do
      it "sets the Puppet setting based on the example group setting" do
        context = double :confdir => "/etc/fingerpuppet"
        subject.set_setting(context, :confdir, :confdir)
        expect(Puppet[:confdir]).to eq("/etc/fingerpuppet").or eq("C:/etc/fingerpuppet")
      end

      it "does not persist settings between example groups" do
        context1 = double :confdir => "/etc/fingerpuppet"
        context2 = double
        subject.set_setting(context1, :confdir, :confdir)
        expect(Puppet[:confdir]).to eq("/etc/fingerpuppet").or eq("C:/etc/fingerpuppet")
        subject.set_setting(context2, :confdir, :confdir)
        expect(Puppet[:confdir]).to eq("/etc/puppet").or eq("C:/etc/puppet")
      end
    end

    describe "with a global RSpec configuration setting" do
      before do
        allow(RSpec.configuration).to receive(:confdir).and_return("/etc/bunraku")
      end

      it "sets the Puppet setting based on the global configuration value" do
        subject.set_setting(double, :confdir, :confdir)
        expect(Puppet[:confdir]).to eq("/etc/bunraku").or eq("C:/etc/bunraku")
      end
    end

    describe "with both a global RSpec configuration setting and a context specific setting" do
      before do
        allow(RSpec.configuration).to receive(:confdir).and_return("/etc/bunraku")
      end

      it "prefers the context specific setting" do
        context = double :confdir => "/etc/sockpuppet"
        subject.set_setting(context, :confdir, :confdir)
        expect(Puppet[:confdir]).to eq("/etc/sockpuppet").or eq("C:/etc/sockpuppet")
      end
    end

    describe "when the setting is not available on the given version of Puppet" do
      it "logs a warning about the setting" do

      end
    end
  end
end

describe RSpec::Puppet::Adapters::Adapter3X do

  let(:test_context) { double :environment => 'rp_env' }

  context 'when running on puppet 3.5 or later', :if => Puppet.version.to_f >= 3.5 do
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

  context 'when running on puppet 3.x, with x >= 5', :if => (3.5 ... 4.0).include?(Puppet.version.to_f) do
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

describe RSpec::Puppet::Adapters::Adapter4X, :if => Puppet.version.to_f >= 4.0 do

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

  describe '#manifest' do
    it 'returns the configured environment manifest when set' do
      allow(RSpec.configuration).to receive(:manifest).and_return("/path/to/manifest")
      subject.setup_puppet(double(:environment => 'rp_puppet'))
      expect(subject.manifest).to eq("/path/to/manifest").or eq("C:/path/to/manifest")
    end

    it 'returns nil when the configured environment manifest is not set' do
      allow(RSpec.configuration).to receive(:manifest)
      allow(RSpec.configuration).to receive(:environmentpath).and_return("/some/missing/path:/another/missing/path")
      subject.setup_puppet(double(:environment => 'rp_puppet'))
      expect(subject.manifest).to be_nil
    end
  end
end
