source ENV['GEM_SOURCE'] || "https://rubygems.org"

def location_for(place, fake_version = nil)
  if place =~ /^((?:git|https?)[:@][^#]*)#(.*)/
    [fake_version, { :git => $1, :branch => $2, :require => false }].compact
  elsif place =~ /^file:\/\/(.*)/
    ['>= 0', { :path => File.expand_path($1), :require => false }]
  else
    [place, { :require => false }]
  end
end

gemspec

if RUBY_VERSION < '1.9.3'
  gem 'rake', '< 11'
  gem 'json_pure', '< 2.0'
else
  gem 'rake', :require => false
end
gem 'rspec', *location_for(ENV['RSPEC_GEM_VERSION'] || '~> 3.0')
gem 'puppet', *location_for(ENV['PUPPET_GEM_VERSION'] || '~> 4.0')

gem 'pry', :group => :development

if ENV['COVERAGE'] == 'yes'
  gem 'coveralls', :require => false
end

if File.exist?('Gemfile.local')
  eval_gemfile('Gemfile.local')
end
