if ENV['COVERAGE'] == 'yes'
  require 'coveralls'
  Coveralls.wear!
end

require 'rspec-puppet'

RSpec.configure do |c|
  c.module_path     = File.join(File.dirname(File.expand_path(__FILE__)), 'fixtures', 'modules')
  c.manifest_dir    = File.join(File.dirname(File.expand_path(__FILE__)), 'fixtures', 'manifests')
  c.manifest        = File.join(File.dirname(File.expand_path(__FILE__)), 'fixtures', 'manifests', 'site.pp')
  c.environmentpath = File.join(Dir.pwd, 'spec')

  c.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
end
