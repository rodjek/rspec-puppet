# frozen_string_literal: true

require 'spec_helper'

describe 'export_resource' do
  describe 'exported_resources accessor' do
    it 'supports the contain_* matcher' do
      expect(exported_resources).to contain_file('/exported/resource')
        .with_content('Exported Content')
    end

    it 'supports the have_*_resource_count matcher' do
      expect(exported_resources).to have_file_resource_count(1)
    end
  end

  describe 'exported_resources sub-context' do
    subject { exported_resources }

    it 'supports the contain_* matcher' do
      expect(subject).to contain_file('/exported/resource')
        .with_content('Exported Content')
    end

    it 'supports the have_*_resource_count matcher' do
      expect(subject).to have_file_resource_count(1)
    end
  end

  describe 'normal catalogue tests' do
    it 'does not match exported resources' do
      expect(subject).not_to contain_file('/exported/resource')
      expect(subject).to have_file_resource_count(0)
    end
  end
end
