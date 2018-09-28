module RSpec::Puppet
  module StringExampleGroup
    include RSpec::Puppet::ManifestMatchers
    include RSpec::Puppet::Support

    def catalogue
      @catalogue ||= load_catalogue(:string)
    end

    def exported_resources
      lambda { load_catalogue(:string, true) }
    end

    def rspec_puppet_cleanup
      @catalogue = nil
    end
  end
end
