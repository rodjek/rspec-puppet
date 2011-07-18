require 'puppet'
require 'rspec-puppet/matchers'
require 'rspec-puppet/example'

RSpec.configure do |c|
  c.add_setting :module_path, :default => '/etc/puppet/modules'
end
