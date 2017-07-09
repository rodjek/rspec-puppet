require 'rake'
require 'rspec/core/rake_task'
require 'bundler/gem_tasks'

begin
  require 'rubocop/rake_task'

  RuboCop::RakeTask.new
rescue LoadError
  $stderr.puts 'Rubocop not available for this version of ruby.'
end

task :default => :test
task :spec => :test

RSpec::Core::RakeTask.new(:test)
