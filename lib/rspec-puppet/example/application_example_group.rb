module RSpec::Puppet
  # This module provides support for the application type
  module ApplicationExampleGroup
    include RSpec::Puppet::ManifestMatchers
    include RSpec::Puppet::Support

    def catalogue
      @catalogue ||= load_catalogue(:application)
    end

    def exported_resources
      lambda { load_catalogue(:application, true) }
    end

    def rspec_puppet_cleanup
      @catalogue = nil
    end
  end
end
