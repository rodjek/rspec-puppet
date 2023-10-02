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
