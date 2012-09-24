Gem::Specification.new do |s|
  s.name = 'rspec-puppet'
  s.version = '0.1.4'
  s.homepage = 'https://github.com/rodjek/rspec-puppet/'
  s.summary = 'RSpec tests for your Puppet manifests'
  s.description = 'RSpec tests for your Puppet manifests'

  s.executables = ['rspec-puppet-init']

  s.files = [
    'bin/rspec-puppet-init',
    'lib/rspec-puppet/example/class_example_group.rb',
    'lib/rspec-puppet/example/define_example_group.rb',
    'lib/rspec-puppet/example/function_example_group.rb',
    'lib/rspec-puppet/example/host_example_group.rb',
    'lib/rspec-puppet/example.rb',
    'lib/rspec-puppet/matchers/create_generic.rb',
    'lib/rspec-puppet/matchers/create_resource.rb',
    'lib/rspec-puppet/matchers/include_class.rb',
    'lib/rspec-puppet/matchers/run.rb',
    'lib/rspec-puppet/matchers.rb',
    'lib/rspec-puppet/setup.rb',
    'lib/rspec-puppet/support/database.rb',
    'lib/rspec-puppet/support.rb',
    'lib/rspec-puppet.rb',
    'LICENSE',
    'Rakefile',
    'README.md',
    'rspec-puppet.gemspec',
    'spec/classes/boolean_regexp_spec.rb',
    'spec/classes/boolean_spec.rb',
    'spec/classes/exported_export_files_spec.rb',
    'spec/classes/exported_realise_all_spec.rb',
    'spec/classes/exported_realise_file_spec.rb',
    'spec/classes/exported_realise_title_spec.rb',
    'spec/classes/sysctl_common_spec.rb',
    'spec/classes/virtual_realise_file_spec.rb',
    'spec/defines/sysctl_before_spec.rb',
    'spec/defines/sysctl_spec.rb',
    'spec/hosts/foo_spec.rb',
    'spec/hosts/testhost_spec.rb',
    'spec/fixtures/manifests/site.pp',
    'spec/fixtures/modules/boolean/manifests/init.pp',
    'spec/fixtures/modules/exported/manifests/export_files.pp',
    'spec/fixtures/modules/exported/manifests/realise_all.pp',
    'spec/fixtures/modules/exported/manifests/realise_file.pp',
    'spec/fixtures/modules/exported/manifests/realise_title.pp',
    'spec/fixtures/modules/sysctl/manifests/init.pp',
    'spec/fixtures/modules/virtual/manifests/realise_file.pp',
    'spec/functions/split_spec.rb',
    'spec/hosts/foo_spec.rb',
    'spec/hosts/testhost_spec.rb',
    'spec/spec_helper.rb',
  ]

  s.add_dependency 'rspec'

  s.authors = ['Tim Sharpe']
  s.email = 'tim@sharpe.id.au'
end
