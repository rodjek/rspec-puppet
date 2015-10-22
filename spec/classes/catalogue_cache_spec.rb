require 'spec_helper'

describe 'test::bare_class' do
  describe 'cache between adjacent examples' do
    catalogue_id = nil

    it 'records the initial catalogue ID' do
      catalogue_id = catalogue.object_id
    end

    it 'should contain the same catalogue ID' do
      expect(catalogue.object_id).to eq(catalogue_id)
    end
  end

  describe 'cache multiple catalogues' do
    catalogue_ids = {}

    (1..10).each do |i|
      context "iteration #{i}" do
        let(:facts) do
          { 'iteration' => i }
        end

        it 'records the initial catalogue ID' do
          catalogue_ids[i] = catalogue.object_id
        end
      end
    end

    (1..10).each do |i|
      context "iteration #{i}" do
        let(:facts) do
          { 'iteration' => i }
        end

        it 'should contain the same catalogue ID' do
          expect(catalogue.object_id).to eq(catalogue_ids[i])
        end
      end
    end
  end

  describe 'limits number of cached catalogues' do
    catalogue_ids = {}

    (1..20).each do |i|
      context "iteration #{i}" do
        let(:facts) do
          { 'iteration' => i }
        end

        it 'records the initial catalogue ID' do
          catalogue_ids[i] = catalogue.object_id
        end
      end
    end

    (1..4).each do |i|
      context "iteration #{i}" do
        let(:facts) do
          { 'iteration' => i }
        end

        it 'should receive a new catalogue ID' do
          expect(catalogue.object_id).not_to eq(catalogue_ids[i])
        end
      end
    end

    (9..20).each do |i|
      context "iteration #{i}" do
        let(:facts) do
          { 'iteration' => i }
        end

        it 'should contain the same catalogue ID' do
          expect(catalogue.object_id).to eq(catalogue_ids[i])
        end
      end
    end
  end
end
