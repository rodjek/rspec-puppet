require 'spec_helper'

describe 'split' do
  describe 'rspec group' do
    it 'should have a catalogue method' do
      expect(catalogue).to be_a(Puppet::Resource::Catalog)
    end

    it 'catalogue should not change after subject is called' do
      expect(catalogue).to be_a(Puppet::Resource::Catalog)
      pre_id = catalogue.object_id

      should run.with_params('aoeu', 'o').and_return(%w(a eu))

      post_id = catalogue.object_id

      expect(pre_id).to eq post_id
    end
  end
end
