source ENV['GEM_SOURCE'] || "https://rubygems.org"

def location_for(place, fake_version = nil)
  if place =~ /^((?:git|https?)[:@][^#]*)#(.*)/
    [fake_version, { :git => $1, :branch => $2, :require => false, :submodules => true }].compact
  elsif place =~ /^file:\/\/(.*)/
    ['>= 0', { :path => File.expand_path($1), :require => false }]
  else
    [place, { :require => false }]
  end
end

gemspec

# ffi (specifically the x64-mingw32 variant) requires ruby >= 2.0 after version 1.9.14 
if RUBY_VERSION =~ /^1\.?9/
  gem 'ffi', '<= 1.9.14'
end

gem 'rspec', *location_for(ENV['RSPEC_GEM_VERSION'] || '~> 3.0')
gem 'puppet', *location_for(ENV['PUPPET_GEM_VERSION'] || '~> 4.0')
gem 'facter', *location_for(ENV['FACTER_GEM_VERSION'] || '~> 2.0')
gem 'pry', :group => :development

if RUBY_VERSION =~ /^1\.?/
  gem 'rake', '10.5.0' # still supports 1.8
else
  gem 'rake'
end

# json_pure 2.0.2 added a requirement on ruby >= 2. We pin to json_pure 2.0.1
# if using ruby 1.9; older ruby versions do not support puppets that require
# these gems.
if RUBY_VERSION =~ /^1\.?9/
  gem 'json_pure', '<=2.0.1'
  # rubocop 0.42.0 requires ruby >=2; 1.8 is not supported
  gem 'rubocop', '0.41.2'       if RUBY_VERSION =~ /^1\.?9/
elsif RUBY_VERSION =~ /^1\.?8/
  gem 'json_pure', '< 2.0.0'
else
  gem 'rubocop'
  gem 'rubocop-rspec', '~> 1.6' if (RUBY_VERSION >= '2.3.0' || RUBY_VERSION >= '23')
  gem 'sync' if (RUBY_VERSION >= '2.7.0')
end

if ENV['COVERAGE'] == 'yes'
  gem 'coveralls', :require => false
end

gem 'win32-taskscheduler', :platforms => [:mingw, :x64_mingw, :mswin]

if File.exist?('Gemfile.local')
  eval_gemfile('Gemfile.local')
end
