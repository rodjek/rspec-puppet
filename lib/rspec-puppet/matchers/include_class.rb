module RSpec::Puppet
  module ManifestMatchers
    extend RSpec::Matchers::DSL

    matcher :include_class do |expected_class|
      match do |catalogue|
        RSpec.deprecate(:include_class, :contain_class)
        catalogue.call.classes.include?(expected_class)
      end

      description do
        "include Class[#{expected_class}]"
      end

      failure_message do |actual|
        "expected that the catalogue would include Class[#{expected_class}]"
      end
    end
  end
end
