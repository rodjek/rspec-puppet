module RSpec::Puppet
  module TypeExampleGroup
    include RSpec::Puppet::TypeMatchers
    include RSpec::Puppet::Support

    def subject
      @type_and_resource ||= begin
        setup_puppet
        type_name = self.class.top_level_description.downcase
        my_params = self.respond_to?(:params) ? params : {}
        [
          Puppet::Type.type(type_name),
          # I don't want to create the resource here, so I have
          # to pass all of the bits form the current scope
          # required to create it
          title,
          my_params
        ]
      end
    end

    def rspec_puppet_cleanup
      @type_and_resource = nil
    end
  end
end
