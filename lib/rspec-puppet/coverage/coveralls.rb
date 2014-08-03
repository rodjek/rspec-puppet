module RSpec::Puppet
  class Coverage

    class << self
      extend Forwardable
      def_delegators :instance, :add, :coveralls!
    end

    def coveralls!
      require 'coveralls'
      ::Coveralls::API.post_json "jobs", { :source_files => coverage }
      report!
    end

  end
end
