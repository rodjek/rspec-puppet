if ENV['COVERAGE'] == 'yes'
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  SimpleCov.start do
    add_filter(/^\/spec\//)
  end
end

require 'rspec-puppet'

# rspec 2.x doesn't have RSpec::Support, so fall back to File::ALT_SEPARATOR to
# detect if running on windows
def windows?
  return @windowsp unless @windowsp.nil?
  @windowsp = defined?(RSpec::Support) ? RSpec::Support::OS.windows? : !!File::ALT_SEPARATOR
end

def sensitive?
  defined?(::Puppet::Pops::Types::PSensitiveType)
end

RSpec.configure do |c|
  c.module_path     = File.join(File.dirname(File.expand_path(__FILE__)), 'fixtures', 'modules')
  c.manifest_dir    = File.join(File.dirname(File.expand_path(__FILE__)), 'fixtures', 'manifests')
  c.manifest        = File.join(File.dirname(File.expand_path(__FILE__)), 'fixtures', 'manifests', 'site.pp')
  c.environmentpath = File.join(Dir.pwd, 'spec')
  c.parser          = ENV['FUTURE_PARSER'] == 'yes' ? 'future' : 'current'

  c.after(:suite) do
    RSpec::Puppet::Coverage.report!(0)
  end
end
