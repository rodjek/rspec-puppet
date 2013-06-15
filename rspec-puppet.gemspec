Gem::Specification.new do |s|
  s.name = 'rspec-puppet'
  s.version = '0.1.6gg1'
  s.homepage = 'https://github.com/rodjek/rspec-puppet/'
  s.summary = 'RSpec tests for your Puppet manifests'
  s.description = 'RSpec tests for your Puppet manifests'

  s.executables = ['rspec-puppet-init']

  s.files = [
    'Gemfile',
    'LICENSE',
    'README.md',
    'Rakefile',
    'bin/rspec-puppet-init',
    'lib/rspec-puppet.rb',
    'lib/rspec-puppet/errors.rb',
    'lib/rspec-puppet/example.rb',
    'lib/rspec-puppet/example/class_example_group.rb',
    'lib/rspec-puppet/example/define_example_group.rb',
    'lib/rspec-puppet/example/function_example_group.rb',
    'lib/rspec-puppet/example/host_example_group.rb',
    'lib/rspec-puppet/matchers.rb',
    'lib/rspec-puppet/matchers/compile.rb',
    'lib/rspec-puppet/matchers/count_generic.rb',
    'lib/rspec-puppet/matchers/create_generic.rb',
    'lib/rspec-puppet/matchers/dynamic_matchers.rb',
    'lib/rspec-puppet/matchers/include_class.rb',
    'lib/rspec-puppet/matchers/run.rb',
    'lib/rspec-puppet/setup.rb',
    'lib/rspec-puppet/support.rb',
    'rspec-puppet.gemspec',
    'spec/classes/boolean_regexp_spec.rb',
    'spec/classes/boolean_spec.rb',
    'spec/classes/cycle_bad_spec.rb',
    'spec/classes/cycle_good_spec.rb',
    'spec/classes/escape_spec.rb',
    'spec/classes/sysctl_common_spec.rb',
    'spec/defines/escape_def_spec.rb',
    'spec/defines/sysctl_before_spec.rb',
    'spec/defines/sysctl_spec.rb',
    'spec/fixtures/manifests/site.pp',
    'spec/fixtures/modules/boolean/manifests/init.pp',
    'spec/fixtures/modules/cycle/manifests/bad.pp',
    'spec/fixtures/modules/cycle/manifests/good.pp',
    'spec/fixtures/modules/cycle/manifests/init.pp',
    'spec/fixtures/modules/escape/manifests/def.pp',
    'spec/fixtures/modules/escape/manifests/init.pp',
    'spec/fixtures/modules/sysctl/manifests/init.pp',
    'spec/functions/split_spec.rb',
    'spec/hosts/bad_dep_host_spec.rb',
    'spec/hosts/foo_spec.rb',
    'spec/hosts/good_dep_host_spec.rb',
    'spec/hosts/testhost_spec.rb',
    'spec/spec_helper.rb',
  ]

  s.add_dependency 'rspec'

  s.authors = ['Tim Sharpe']
  s.email = 'tim@sharpe.id.au'
end
