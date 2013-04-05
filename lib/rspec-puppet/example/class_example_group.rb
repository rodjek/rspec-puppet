module RSpec::Puppet
  module ClassExampleGroup
    include RSpec::Puppet::ManifestMatchers
    include RSpec::Puppet::Support

    def subject
      @catalogue ||= catalogue(:class)
    end
  end
end
