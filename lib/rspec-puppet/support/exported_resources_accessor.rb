# Expose a catalogue's exported resources to tests
module RSpec::Puppet
  module Support
    def exported_resources
      lambda do
        catalogue.filter { |r| !r.exported? }
      end
    end
  end
end
