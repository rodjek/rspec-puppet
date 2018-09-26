module RSpec::Puppet
  module ManifestMatchers
    extend RSpec::Matchers::DSL

    matcher :come_before do |*preceding_resources|
      match do |resource|
        preceding_resources.flatten.all? do |expected_precede|
          resource.comes_before_resource?(expected_precede)
        end
      end

      description do
        "come before #{preceding_resources.flatten.join(', ')}"
      end

      failure_message do |resource|
        "expected to come before #{preceding_resources.flatten.join(', ')}"
      end

      failure_message_when_negated do |resource|
        "expected not to come before #{preceding_resources.flatten.join(', ')}"
      end
    end
  end
end
