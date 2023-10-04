# frozen_string_literal: true

if ENV['COVERAGE']
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatter = Coveralls::SimpleCov::Formatter if ENV['COVERAGE'] == 'yes'

  SimpleCov.start do
    add_filter %r{^/spec/}
    add_filter %r{^/vendor/}
  end
end

require 'rspec-puppet'

# TODO: drop?
def windows?
  return @windowsp unless @windowsp.nil?

  @windowsp = RSpec::Support::OS.windows?
end

def sensitive?
  defined?(Puppet::Pops::Types::PSensitiveType)
end

RSpec.configure do |c|
  c.module_path     = File.join(File.dirname(File.expand_path(__FILE__)), 'fixtures', 'modules')
  c.environmentpath = File.join(Dir.pwd, 'spec')
  c.manifest        = File.join(File.dirname(File.expand_path(__FILE__)), 'fixtures', 'manifests', 'site.pp')

  c.after(:suite) do
    RSpec::Puppet::Coverage.report!(0)
  end
end
