module RSpec::Puppet
  module CatalogueExampleGroup
    include RSpec::Puppet::ManifestMatchers
    include RSpec::Puppet::Support

    def catalogue
      @catalogue ||= load_catalogue_from_file
    end

    def rspec_puppet_cleanup
      @catalogue = nil
    end
  end
end
