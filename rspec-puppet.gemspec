Gem::Specification.new do |s|
  s.name = 'rspec-puppet'
  s.version = '2.7.9'
  s.homepage = 'https://github.com/rodjek/rspec-puppet/'
  s.summary = 'RSpec tests for your Puppet manifests'
  s.description = 'RSpec tests for your Puppet manifests'
  s.license = 'MIT'

  s.executables = ['rspec-puppet-init']

  s.files = Dir['CHANGELOG.md', 'LICENSE.md', 'README.md', 'lib/**/*', 'bin/**/*']

  s.add_dependency 'rspec'

  s.authors = ['Tim Sharpe']
  s.email = 'tim@sharpe.id.au'
end
