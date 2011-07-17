require 'puppet'
require 'puppet-rspec/matchers/exec'
require 'puppet-rspec/helpers/subject'

module PuppetRSpec
  include PuppetRSpec::Matchers
  include PuppetRSpec::Helpers
end
