module RSpec::Puppet
  module ManifestMatchers
    extend RSpec::Matchers::DSL

    matcher :require do |*required_resources|
      match do |resource|
        required_resources.flatten.all? do |expected_require|
          resource.requires_resource?(expected_require)
        end
      end

      description do
        "require #{required_resources.flatten.join(', ')}"
      end

      failure_message do |resource|
        "expected to require #{required_resources.flatten.join(', ')}"
      end

      failure_message_when_negated do |resource|
        "expected not to require #{required_resources.flatten.join(', ')}"
      end
    end
  end
end
