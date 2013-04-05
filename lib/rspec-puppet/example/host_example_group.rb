module RSpec::Puppet
  module HostExampleGroup
    include RSpec::Puppet::ManifestMatchers
    include RSpec::Puppet::Support

    def subject
      @catalogue ||= catalogue(:host)
    end
  end
end
