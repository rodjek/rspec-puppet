# frozen_string_literal: true

require 'spec_helper'

describe 'test::hiera' do
  context 'with :hiera_config set' do
    let(:hiera_config) { 'spec/fixtures/hiera.yaml' }

    it { is_expected.to contain_notify('foo') }
  end

  context 'without :hiera_config set' do
    it { is_expected.to contain_notify('not found') }
  end
end

describe 'hiera_test' do
  before do
    RSpec.configuration.disable_module_hiera = false
    RSpec.configuration.use_fixture_spec_hiera = false
    RSpec.configuration.fixture_hiera_configs = {}
    RSpec.configuration.fallback_to_default_hiera = true
  end

  context 'without :hiera_config set' do
    context 'with module eyaml hiera data enabled' do
      it { is_expected.to raise_error(Puppet::PreformattedError, /hiera_eyaml/) }
    end

    context 'with module eyaml hiera data disabled' do
      before { RSpec.configuration.disable_module_hiera = true }

      it { is_expected.to raise_error(Puppet::ParseError) }
    end

    context 'with relative fixture hiera config path' do
      before { RSpec.configuration.fixture_hiera_configs = { 'hiera_test' => 'spec/module_hiera.yaml' } }

      it { is_expected.to contain_notify('module') }
    end

    context 'with absolute fixture hiera config path' do
      before do
        RSpec.configuration.fixture_hiera_configs = {
          'hiera_test' => File.join(__FILE__, '../../fixtures/modules/hiera_test/spec/module_hiera.yaml')
        }
      end

      it { is_expected.to contain_notify('module') }
    end

    context 'with invalid fixture hiera config path' do
      before { RSpec.configuration.fixture_hiera_configs = { 'hiera_test' => 'non_existent.yaml' } }

      it { is_expected.to raise_error(Puppet::ParseError) }
    end

    context 'with :use_fixture_spec_hiera set' do
      before { RSpec.configuration.use_fixture_spec_hiera = true }

      it { is_expected.to contain_notify('spec') }
    end
  end

  context 'with :hiera_config set' do
    let(:hiera_config) { 'spec/fixtures/hiera.yaml' }

    context 'with module eyaml hiera data enabled' do
      it { is_expected.to raise_error(Puppet::PreformattedError, /hiera_eyaml/) }
    end

    context 'with module eyaml hiera data disabled' do
      before { RSpec.configuration.disable_module_hiera = true }

      it { is_expected.to contain_notify('global') }
    end

    context 'with relative fixture hiera config path' do
      before { RSpec.configuration.fixture_hiera_configs = { 'hiera_test' => 'spec/module_hiera.yaml' } }

      it { is_expected.to contain_notify('global') }
    end

    context 'with absolute fixture hiera config path' do
      before do
        RSpec.configuration.fixture_hiera_configs = {
          'hiera_test' => File.join(__FILE__, '../../fixtures/modules/hiera_test/spec/module_hiera.yaml')
        }
      end

      it { is_expected.to contain_notify('global') }
    end

    context 'with invalid fixture hiera config path' do
      before { RSpec.configuration.fixture_hiera_configs = { 'hiera_test' => 'non_existent.yaml' } }

      it { is_expected.to contain_notify('global') }
    end

    context 'with :use_fixture_spec_hiera set' do
      before { RSpec.configuration.use_fixture_spec_hiera = true }

      it { is_expected.to contain_notify('global') }
    end
  end
end

describe 'hiera_test2' do
  before do
    RSpec.configuration.disable_module_hiera = false
    RSpec.configuration.use_fixture_spec_hiera = false
    RSpec.configuration.fixture_hiera_configs = {}
    RSpec.configuration.fallback_to_default_hiera = true
  end

  context 'without :hiera_config set' do
    context 'with module-layer hiera enabled' do
      it { is_expected.to contain_notify('module') }
    end

    context 'with module-layer hiera disabled' do
      before { RSpec.configuration.disable_module_hiera = true }

      it { is_expected.to raise_error(Puppet::ParseError) }
    end

    context 'with :use_fixture_spec_hiera set' do
      before { RSpec.configuration.use_fixture_spec_hiera = true }

      context 'with missing spec hiera.yaml and hiera fallback enabled' do
        it { is_expected.to contain_notify('module') }
      end

      context 'with missing spec hiera.yaml and hiera fallback disabled' do
        before { RSpec.configuration.fallback_to_default_hiera = false }

        it { is_expected.to raise_error(Puppet::ParseError) }
      end
    end
  end

  context 'with :hiera_config set' do
    let(:hiera_config) { 'spec/fixtures/hiera.yaml' }

    context 'with module-layer hiera enabled' do
      it { is_expected.to contain_notify('global') }
    end

    context 'with module-layer hiera disabled' do
      before { RSpec.configuration.disable_module_hiera = true }

      it { is_expected.to contain_notify('global') }
    end

    context 'with :use_fixture_spec_hiera set' do
      before { RSpec.configuration.use_fixture_spec_hiera = true }

      context 'with missing spec hiera.yaml and hiera fallback enabled' do
        it { is_expected.to contain_notify('global') }
      end

      context 'with missing spec hiera.yaml and hiera fallback disabled' do
        before { RSpec.configuration.fallback_to_default_hiera = false }

        it { is_expected.to contain_notify('global') }
      end
    end
  end
end
