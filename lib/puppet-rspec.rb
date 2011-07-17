require 'puppet'
require 'puppet-rspec/matchers/exec'
require 'puppet-rspec/helpers/subject'
require 'puppet-rspec/example'

module PuppetRSpec
  include PuppetRSpec::Matchers
  include PuppetRSpec::Helpers
end
