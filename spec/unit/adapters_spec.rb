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
