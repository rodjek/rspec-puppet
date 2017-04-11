require 'spec_helper'

describe 'test::bare_class' do
  describe 'rspec group' do
    it 'should have a catalogue method' do
      expect(catalogue).to be_a(Puppet::Resource::Catalog)
    end

    it 'subject should return a catalogue' do
      expect(subject.call).to be_a(Puppet::Resource::Catalog)
    end

    describe 'derivative group' do
      subject { catalogue.resource('Notify', 'foo') }

      it 'can redefine subject' do
        expect(subject).to be_a(Puppet::Resource)
      end
    end
  end

  describe 'coverage' do
    it 'class should be included in the coverage filter' do
      expect(RSpec::Puppet::Coverage.filters).to include('Class[Test::Bare_class]')
    end

    # file and line information was only added to resources created with
    # ensure_resource() in 4.6.0 (PUP-6530).
    if Puppet::Util::Package.versioncmp(Puppet.version, '4.6.0') >= 0
      it 'should not include resources from other modules created with create_resources()' do
        expect(RSpec::Puppet::Coverage.instance.results[:resources]).to_not include('Notify[create_resources notify]')
        expect(subject).to contain_notify('create_resources notify')
      end
    end
  end
end
