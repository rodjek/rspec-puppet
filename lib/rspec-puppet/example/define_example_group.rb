# frozen_string_literal: true

module RSpec::Puppet
  module DefineExampleGroup
    include RSpec::Puppet::ManifestMatchers
    include RSpec::Puppet::Support

    def catalogue
      @catalogue ||= load_catalogue(:define)
    end

    def exported_resources
      -> { load_catalogue(:define, true) }
    end

    def rspec_puppet_cleanup
      @catalogue = nil
    end
  end
end
