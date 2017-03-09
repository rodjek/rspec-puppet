module RSpec::Puppet
  module HostExampleGroup
    include RSpec::Puppet::ManifestMatchers
    include RSpec::Puppet::Support

    def catalogue
      @catalogue ||= load_catalogue(:host)
    end

    def rspec_puppet_cleanup
      @catalogue = nil
    end
  end
end
