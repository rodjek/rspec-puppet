module RSpec::Puppet
  module DefineExampleGroup
    include RSpec::Puppet::ManifestMatchers
    include RSpec::Puppet::Support

    def subject
      @catalogue ||= catalogue(:define)
    end
  end
end
