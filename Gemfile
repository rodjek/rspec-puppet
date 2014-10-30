source 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_VERSION') ? "~> #{ENV['PUPPET_VERSION']}.0" : ['~> 4.0']
rspecversion = ENV.key?('RSPEC_VERSION') ? "= #{ENV['RSPEC_VERSION']}" : ['~> 2.0']

gem 'rake'
gem 'rspec', rspecversion
gem 'rspec-core', rspecversion
gem 'puppet', puppetversion
gem 'pry', :group => :development
