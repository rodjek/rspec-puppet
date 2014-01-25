module RSpec::Puppet
  module ClassExampleGroup
    include RSpec::Puppet::ManifestMatchers
    include RSpec::Puppet::Support

    def catalogue
      @catalogue ||= load_catalogue(:class)
    end

    alias_method :subject, :catalogue
  end
end
