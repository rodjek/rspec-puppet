require 'spec_helper'

describe 'export_resource' do
  describe 'exported_resources accessor' do
    it 'should support the contain_* matcher' do
      expect(exported_resources).to contain_file('/exported/resource')\
        .with_content('Exported Content')
    end

    it 'should support the have_*_resource_count matcher' do
      expect(exported_resources).to have_file_resource_count(1)
    end
  end

  describe 'exported_resources sub-context' do
    subject { exported_resources }

    it 'should support the contain_* matcher' do
      should contain_file('/exported/resource')\
        .with_content('Exported Content')
    end

    it 'should support the have_*_resource_count matcher' do
      should have_file_resource_count(1)
    end
  end

  describe 'normal catalogue tests' do
    it 'should not match exported resources' do
      should_not contain_file('/exported/resource')
      should have_file_resource_count(0)
    end
  end
end
