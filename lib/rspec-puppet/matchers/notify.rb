module RSpec::Puppet
  module ManifestMatchers
    extend RSpec::Matchers::DSL

    matcher :notify do |*notified_resources|
      match do |resource|
        notified_resources.flatten.all? do |expected_notify|
          resource.notifies_resource?(expected_notify)
        end
      end

      description do
        "notify #{notified_resources.flatten.join(', ')}"
      end

      failure_message do |resource|
        "expected to notify #{notified_resources.flatten.join(', ')}"
      end

      failure_message_when_negated do |resource|
        "expected not to notify #{notified_resources.flatten.join(', ')}"
      end
    end
  end
end
