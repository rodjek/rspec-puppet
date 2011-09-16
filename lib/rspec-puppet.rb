require 'puppet'
require 'rspec-puppet/matchers'
require 'rspec-puppet/example'

RSpec.configure do |c|
  c.add_setting :module_path, :default => '/etc/puppet/modules'
  c.add_setting :manifest_dir, :default => nil
  c.add_setting :manifest, :default => nil
  c.add_setting :template_dir, :default => nil
end
