source ENV['GEM_SOURCE'] || "https://rubygems.org"

gemspec

def location_for(place_or_version, fake_version = nil)
  git_url_regex = %r{\A(?<url>(https?|git)[:@][^#]*)(#(?<branch>.*))?}
  file_url_regex = %r{\Afile:\/\/(?<path>.*)}

  if place_or_version && (git_url = place_or_version.match(git_url_regex))
    [fake_version, { git: git_url[:url], branch: git_url[:branch], require: false }].compact
  elsif place_or_version && (file_url = place_or_version.match(file_url_regex))
    ['>= 0', { path: File.expand_path(file_url[:path]), require: false }]
  else
    [place_or_version, { require: false }]
  end
end

group :development do
  gem 'pry'
  gem 'pry-stack_explorer'
  gem 'fuubar'
end

group :test do

  gem 'puppet', *location_for(ENV['PUPPET_LOCATION'])
  gem 'facter', *location_for(ENV['FACTER_LOCATION'])

  gem 'json_pure'
  gem 'sync'

  gem 'rake', require: false

  gem 'codecov', require: false
  gem 'rspec', '~> 3.0', require: false
  gem 'rubocop', '~> 1.48', require: false
  gem 'rubocop-performance', '~> 1.16', require: false
  gem 'rubocop-rspec', '~> 2.19', require: false
  gem 'simplecov', require: false
  gem 'simplecov-console', require: false

  gem 'win32-taskscheduler', :platforms => [:mingw, :x64_mingw, :mswin]
end
