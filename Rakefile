require 'rake'
require 'rspec/core/rake_task'
require 'bundler/gem_tasks'

task :default => :test
task :spec => :test

unless RUBY_VERSION.start_with?('1')
  require 'rspec-puppet/tasks/release_test'
  require 'rspec-puppet/tasks/audit'
end

RSpec::Core::RakeTask.new(:test)
