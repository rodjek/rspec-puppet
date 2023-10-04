# frozen_string_literal: true

require 'rspec-puppet'

RSpec.configure do |c|
  c.module_path     = File.join(fixture_path, 'modules')
  c.manifest        = File.join(fixture_path, 'manifests', 'site.pp')
  c.environmentpath = File.join(Dir.pwd, 'spec')
end
