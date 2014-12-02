source 'https://rubygems.org'

if ENV['PUPPET_VERSION']
  puppetversion = "= #{ENV['PUPPET_VERSION']}"
else
  puppetversion = '~> 3.0'
end

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
