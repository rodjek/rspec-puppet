# frozen_string_literal: true

if ENV['COVERAGE']
  require 'coveralls'
  require 'simplecov'

  SimpleCov.formatter = Coveralls::SimpleCov::Formatter if ENV['COVERAGE'] == 'yes'

  SimpleCov.start do
    add_filter %r{^/spec/}
    add_filter %r{^/vendor/}
  end
end

require 'rspec-puppet'

module Helpers
  def rspec2?
    RSpec::Version::STRING < '3'
  end
  module_function :rspec2?

  def test_double(type, *args)
    if rspec2?
      double(type.to_s, *args)
    else
      instance_double(type, *args)
    end
  end
end

RSpec.configure do |c|
  c.include Helpers
  c.extend Helpers

  if Helpers.rspec2?
    RSpec::Matchers.define :be_truthy do
      match do |actual|
        !actual.nil? == true
      end
    end

    RSpec::Matchers.define :be_falsey do
      match do |actual|
        !actual.nil? == false
      end
    end
  end
end
