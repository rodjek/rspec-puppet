require 'rake'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'bundler/gem_tasks'
require 'fileutils'
require 'puppet'

task :default => :test
task :spec => :test

require 'rspec-puppet/tasks/release_test'

fixtures_dir = File.expand_path(File.join(__FILE__, '..', 'spec', 'fixtures', 'modules'))
fixtures = {
  'augeas_core' => {
    :url         => 'https://github.com/puppetlabs/puppetlabs-augeas_core',
    :requirement => Gem::Requirement.new('>= 6.0.0'),
  },
  'stdlib'      => {
    :url         => 'https://github.com/puppetlabs/puppetlabs-stdlib',
    :requirement => Gem::Requirement.new('>= 0'),
    :ref         => '4.2.0',
  },
  'registry'    => {
    :url         => 'https://github.com/puppetlabs/puppetlabs-registry',
    :requirement => Gem::Requirement.new('>= 0'),
  },
}

namespace :test do
  RSpec::Core::RakeTask.new(:spec) do |t|
    if t.respond_to?(:exclude_pattern)
      t.exclude_pattern = 'spec/fixtures/**/*_spec.rb'
    else
      t.pattern = 'spec/{classes,defines,functions,hosts,type_aliases,types,unit}/**/*_spec.rb'
    end
  end

  RSpec::Core::RakeTask.new(:spec_unit) do |t|
    t.pattern = 'spec/unit/**/*_spec.rb'
  end

  task :setup do
    puppet_version = Gem::Version.new(Puppet.version)

    Dir.chdir(fixtures_dir) do
      fixtures.each do |name, fixture|
        next if File.directory?(name)
        next unless fixture[:requirement].satisfied_by?(puppet_version)

        system('git', 'clone', fixture[:url], name)
        fail unless $?.success?

        if fixture.key?(:ref)
          Dir.chdir(name) do
            system('git', 'checkout', fixture[:ref])
            fail unless $?.success?
          end
        end
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

  task :unit do
    begin
      Rake::Task['test:setup'].invoke
      ENV['COVERAGE'] = 'local'
      Rake::Task['test:spec_unit'].invoke
    ensure
      ENV.delete('COVERAGE')
      Rake::Task['test:teardown'].invoke
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

RuboCop::RakeTask.new(:rubocop) do |task|
  task.options = %w[-D -S -E]
end
