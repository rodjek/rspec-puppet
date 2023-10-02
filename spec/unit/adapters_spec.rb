# frozen_string_literal: true

require 'spec_helper'
require 'rspec-puppet/adapters'

def context_double(options = {})
  double({ environment: 'rp_puppet' }.merge(options))
end

describe RSpec::Puppet::Adapters::Base do
  describe '#setup_puppet' do
    it 'sets up all settings listed in the settings map' do
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

    %i[vardir codedir rundir logdir hiera_config confdir].each do |setting|
      it "sets #{setting} to #{null_path}" do
        expect(Puppet[setting]).to eq(File.expand_path(null_path))
      end
    end
  end

  describe '#set_setting' do
    describe 'with a context specific setting' do
      it 'sets the Puppet setting based on the example group setting' do
        context = context_double confdir: '/etc/fingerpuppet'
        subject.setup_puppet(context)
        expect(Puppet[:confdir]).to match(%r{(C:)?/etc/fingerpuppet})
      end

      it 'does not persist settings between example groups' do
        context1 = context_double confdir: '/etc/fingerpuppet'
        context2 = context_double
        subject.setup_puppet(context1)
        expect(Puppet[:confdir]).to match(%r{(C:)?/etc/fingerpuppet})
        subject.setup_puppet(context2)
        expect(Puppet[:confdir]).not_to match(%r{(C:)?/etc/fingerpuppet})
      end
    end

    describe 'with a global RSpec configuration setting' do
      before do
        allow(RSpec.configuration).to receive(:confdir).and_return('/etc/bunraku')
      end

      it 'sets the Puppet setting based on the global configuration value' do
        subject.setup_puppet(context_double)
        expect(Puppet[:confdir]).to match(%r{(C:)?/etc/bunraku})
      end
    end

    describe 'with both a global RSpec configuration setting and a context specific setting' do
      before do
        allow(RSpec.configuration).to receive(:confdir).and_return('/etc/bunraku')
      end

      it 'prefers the context specific setting' do
        context = context_double confdir: '/etc/sockpuppet'
        subject.setup_puppet(context)
        expect(Puppet[:confdir]).to match(%r{(C:)?/etc/sockpuppet})
      end
    end

    describe 'when the setting is not available on the given version of Puppet' do
      it 'logs a warning about the setting' do
      end
    end
  end

  describe '#setup_puppet' do
    describe 'when managing the facter_implementation' do
      after do
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
        expect(FacterImpl).to be_a(RSpec::Puppet::FacterTestImpl)
      end

      it 'ensures consistency of FacterImpl in subsequent example groups' do
        context = context_double

        # Pretend that FacterImpl is already initialized from a previous example group
        Puppet.runtime[:facter] = RSpec::Puppet::FacterTestImpl.new
        Object.send(:const_set, :FacterImpl, Puppet.runtime[:facter])

        allow(RSpec.configuration).to receive(:facter_implementation).and_return('rspec')
        subject.setup_puppet(context)
        expect(FacterImpl).to eq(Puppet.runtime[:facter])
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
