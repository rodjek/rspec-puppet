Gem::Specification.new do |s|
  s.name = 'rspec-puppet'
  s.version = '1.0.1'
  s.homepage = 'https://github.com/rodjek/rspec-puppet/'
  s.summary = 'RSpec tests for your Puppet manifests'
  s.description = 'RSpec tests for your Puppet manifests'
  s.license = 'MIT'

  s.executables = ['rspec-puppet-init']

  s.files = Dir['LICENSE.md', 'README.md', 'lib/**/*', 'bin/**/*']

  s.add_dependency 'rspec', '< 3.0.0'

  s.authors = ['Tim Sharpe']
  s.email = 'tim@sharpe.id.au'
end
