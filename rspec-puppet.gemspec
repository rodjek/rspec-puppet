Gem::Specification.new do |s|
  s.name = 'rspec-puppet'
  s.version = '0.1.6gg1'
  s.homepage = 'https://github.com/rodjek/rspec-puppet/'
  s.summary = 'RSpec tests for your Puppet manifests'
  s.description = 'RSpec tests for your Puppet manifests'

  s.executables = ['rspec-puppet-init']

  s.files = `git ls-files|grep -v "^\."`.split("\n")

  s.add_dependency 'rspec'

  s.authors = ['Tim Sharpe']
  s.email = 'tim@sharpe.id.au'
end
