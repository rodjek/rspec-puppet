require 'rake'
require 'rspec/core/rake_task'
require 'bundler/gem_tasks'
require 'fileutils'

task :default => :test
task :spec => :test

require 'rspec-puppet/tasks/release_test' unless RUBY_VERSION.start_with?('1')

fixtures_dir = File.expand_path(File.join(__FILE__, '..', 'spec', 'fixtures', 'modules'))
fixtures = {
  'augeas_core' => 'https://github.com/puppetlabs/puppetlabs-augeas_core',
}

namespace :test do
  RSpec::Core::RakeTask.new(:spec) do |t|
    next unless t.respond_to?(:exclude_pattern)
    t.exclude_pattern = 'spec/fixtures/**/*_spec.rb'
  end

  task :setup do
    next unless (ENV['PUPPET_GEM_VERSION'] || '').include?('#master')

    Dir.chdir(fixtures_dir) do
      fixtures.each do |name, repo|
        next if File.directory?(name)
        system('git', 'clone', repo, name)
        fail unless $?.success?
      end
    end
  end

  task :teardown do
    Dir.chdir(fixtures_dir) do
      fixtures.each do |name, _|
        next unless File.directory?(name)
        FileUtils.rm_r(name)
      end
    end
  end
end

task :test do
  begin
    Rake::Task['test:setup'].invoke
    Rake::Task['test:spec'].invoke
  ensure
    Rake::Task['test:teardown'].invoke
  end
end
