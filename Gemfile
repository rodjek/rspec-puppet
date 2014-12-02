source 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_VERSION') ? "= #{ENV['PUPPET_VERSION']}" : ['>= 2.7']

if ENV['RSPEC_VERSION']
  rspecversion = "= #{ENV['RSPEC_VERSION']}"
else
  rspecversion = '~> 2.0'
end

gem 'rake'
gem 'rspec', rspecversion
gem 'rspec-core', rspecversion
gem 'puppet', puppetversion
gem 'pry', :group => :development
