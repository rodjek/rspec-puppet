require 'puppet'
require 'rspec-puppet/matchers/exec'
require 'rspec-puppet/example'

module RSpec::Puppet
  include RSpec::Puppet::Matchers
end
