Gem::Specification.new do |s|
  s.name = 'rspec-puppet'
  s.version = '0.0.3'
  s.homepage = 'https://github.com/rodjek/rspec-puppet/'
  s.summary = 'RSpec tests for your Puppet manifests'
  s.description = 'RSpec tests for your Puppet manifests'

  s.files = [
    'lib/rspec-puppet/example/class_example_group.rb',
    'lib/rspec-puppet/example/define_example_group.rb',
    'lib/rspec-puppet/example.rb',
    'lib/rspec-puppet/support.rb',
    'lib/rspec-puppet/matchers/create_generic.rb',
    'lib/rspec-puppet/matchers/create_resource.rb',
    'lib/rspec-puppet/matchers/include_class.rb',
    'lib/rspec-puppet/matchers.rb',
    'lib/rspec-puppet.rb',
    'LICENSE',
    'Rakefile',
    'README.md',
    'rspec-puppet.gemspec',
    'spec/classes/sysctl_common_spec.rb',
    'spec/defines/sysctl_spec.rb',
    'spec/fixtures/sysctl/manifests/init.pp',
    'spec/spec_helper.rb',
  ]

  s.add_dependency 'rspec'

  s.authors = ['Tim Sharpe']
  s.email = 'tim@sharpe.id.au'
end
