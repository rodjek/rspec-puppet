module RSpec::Puppet
  module ClassExampleGroup
    include RSpec::Puppet::ManifestMatchers
    include RSpec::Puppet::Support

    def catalogue
      @catalogue ||= load_catalogue(:class)
    end

    def exported_resources
      lambda { load_catalogue(:class, true) }
    end

    def rspec_puppet_cleanup
      @catalogue = nil
    end
  end
end
