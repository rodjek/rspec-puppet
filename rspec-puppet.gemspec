# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec-puppet/version'

Gem::Specification.new do |s|
  s.name = 'rspec-puppet'
  s.version = RSpecPuppet::VERSION
  s.homepage = 'https://github.com/puppetlabs/rspec-puppet/'
  s.summary = 'RSpec tests for your Puppet manifests'
  s.description = 'RSpec tests for your Puppet manifests'
  s.license = 'MIT'

  s.executables = ['rspec-puppet-init']

  s.files = Dir['CHANGELOG.md', 'LICENSE.md', 'README.md', 'lib/**/*', 'bin/**/*']

  s.add_dependency 'rspec', '~> 3.0'

  s.authors = ['Tim Sharpe', 'Puppet, Inc.', 'Community Contributors']
  s.email = ['tim@sharpe.id.au', 'modules-team@puppet.com']
  s.metadata['rubygems_mfa_required'] = 'true'

  s.required_ruby_version = Gem::Requirement.new('>= 2.7.0')
end
