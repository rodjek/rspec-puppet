Gem::Specification.new do |s|
  s.name = 'rspec-puppet'
  s.version = '0.0.1'
  s.homepage = 'https://github.com/rodjek/rspec-puppet/'
  s.summary = ''
  s.description = ''

  s.files = [
    'rspec-puppet.gemspec',
    'lib/rspec-puppet.rb',
    'lib/rspec-puppet/matchers/exec.rb',
    'lib/rspec-puppet/example.rb',
    'lib/rspec-puppet/example/define_example_group.rb',
  ]

  s.add_dependency 'rspec'

  s.authors = ['Tim Sharpe']
  s.email = 'tim@sharpe.id.au'
end
