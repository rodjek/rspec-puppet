module RSpec::Puppet
  module TypeAliasExampleGroup
    include RSpec::Puppet::TypeAliasMatchers
    include RSpec::Puppet::Support

    def catalogue(test_value)
      load_catalogue(:type_alias, false, :test_value => test_value)
    end

    def subject
      lambda { |test_value| catalogue(test_value) }
    end
  end
end
