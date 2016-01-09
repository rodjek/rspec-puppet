require 'spec_helper'
require 'rspec-puppet/adapters'

describe RSpec::Puppet::Adapters::Base do
  describe '#setup_puppet' do
    it "sets up all settings listed in the settings map" do
      context = Object.new
      subject.settings_map.each do |puppet_setting, rspec_setting|
        expect(subject).to receive(:set_setting).with(context, puppet_setting, rspec_setting)
      end
      subject.setup_puppet(context)
    end
  end

  describe '#set_setting' do
    describe "with a context specific setting" do
      it "sets the Puppet setting based on the example group setting" do
        context = Object.new
        def context.confdir
          "/etc/fingerpuppet"
        end
        subject.set_setting(context, :confdir, :confdir)
        expect(Puppet[:confdir]).to eq "/etc/fingerpuppet"
      end

      it "does not persist settings between example groups" do
        context1 = Object.new
        def context1.confdir
          "/etc/fingerpuppet"
        end
        context2 = Object.new
        subject.set_setting(context1, :confdir, :confdir)
        expect(Puppet[:confdir]).to eq "/etc/fingerpuppet"
        subject.set_setting(context2, :confdir, :confdir)
        expect(Puppet[:confdir]).to eq "/etc/puppet"
      end
    end

    describe "with a global RSpec configuration setting" do
      before do
        allow(RSpec.configuration).to receive(:confdir).and_return("/etc/bunraku")
      end

      it "sets the Puppet setting based on the global configuration value" do
        subject.set_setting(Object.new, :confdir, :confdir)
        expect(Puppet[:confdir]).to eq "/etc/bunraku"
      end
    end

    describe "with both a global RSpec configuration setting and a context specific setting" do
      before do
        allow(RSpec.configuration).to receive(:confdir).and_return("/etc/bunraku")
      end

      it "prefers the context specific setting" do
        context = Object.new
        def context.confdir
          "/etc/sockpuppet"
        end
        subject.set_setting(context, :confdir, :confdir)
        expect(Puppet[:confdir]).to eq "/etc/sockpuppet"
      end
    end

    describe "when the setting is not available on the given version of Puppet" do
      it "logs a warning about the setting" do

      end
    end
  end
end

describe RSpec::Puppet::Adapters::Adapter3X do
  context 'when running on puppet 3.5 or later', :if => Puppet.version.to_f >= 3.5 do
    it 'sets Puppet[:strict_variables] to false by default' do
      subject.setup_puppet(double)
      expect(Puppet[:strict_variables]).to eq(false)
    end

    it 'reads the :strict_variables setting' do
      subject.setup_puppet(double(:strict_variables => true))
      expect(Puppet[:strict_variables]).to eq(true)
    end
  end

  context 'when running on puppet 3.x, with x >= 5', :if => (3.5 ... 4.0).include?(Puppet.version.to_f) do
    it 'sets Puppet[:trusted_node_data] to false by default' do
      subject.setup_puppet(double)
      expect(Puppet[:trusted_node_data]).to eq(false)
    end
    it 'reads the :trusted_node_data setting' do
      subject.setup_puppet(double(:trusted_node_data => true))
      expect(Puppet[:trusted_node_data]).to eq(true)
    end
  end

  context 'when running on puppet ~> 3.2', :if => (3.2 ... 4.0).include?(Puppet.version.to_f) do
    it 'sets Puppet[:parser] to "current" by default' do
      subject.setup_puppet(double)
      expect(Puppet[:parser]).to eq("current")
    end

    it 'reads the :parser setting' do
      subject.setup_puppet(double(:parser => "future"))
      expect(Puppet[:parser]).to eq("future")
    end
  end

  context 'when running on puppet ~> 3.3', :if => (3.3 ... 4.0).include?(Puppet.version.to_f) do
    it 'sets Puppet[:stringify_facts] to true by default' do
      subject.setup_puppet(double)
      expect(Puppet[:stringify_facts]).to eq(true)
    end

    it 'reads the :stringify_facts setting' do
      subject.setup_puppet(double(:stringify_facts => false))
      expect(Puppet[:stringify_facts]).to eq(false)
    end

    it 'sets Puppet[:ordering] to title-hash by default' do
      subject.setup_puppet(double)
      expect(Puppet[:ordering]).to eq('title-hash')
    end

    it 'reads the :ordering setting' do
      subject.setup_puppet(double(:ordering => "manifest"))
      expect(Puppet[:ordering]).to eq('manifest')
    end
  end
end

describe RSpec::Puppet::Adapters::Adapter4X, :if => Puppet.version.to_f >= 4.0 do
  it 'sets Puppet[:strict_variables] to false by default' do
    subject.setup_puppet(double)
    expect(Puppet[:strict_variables]).to eq(false)
  end

  it 'reads the :strict_variables setting' do
    subject.setup_puppet(double(:strict_variables => true))
    expect(Puppet[:strict_variables]).to eq(true)
  end
end
