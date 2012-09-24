source :rubygems

puppetversion = ENV.key?('PUPPET_VERSION') ? "= #{ENV['PUPPET_VERSION']}" : ['>= 2.7']
rspecversion = ENV.key?('RSPEC_VERSION') ? "= #{ENV['RSPEC_VERSION']}" : ['>= 2.9']

gem 'rake'
gem 'rspec', rspecversion
gem 'puppet', puppetversion
gem 'puppetlabs_spec_helper'
gem 'activerecord', '~> 3.0.17'
gem 'sqlite3'
