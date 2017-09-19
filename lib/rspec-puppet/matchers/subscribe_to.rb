module RSpec::Puppet
  module ManifestMatchers
    extend RSpec::Matchers::DSL

    matcher :subscribe_to do |*subscribed_resources|
      match do |resource|
        subscribed_resources.flatten.all? do |expected_subscribe|
          resource.subscribes_to_resource?(expected_subscribe)
        end
      end

      description do
        "subscribe to #{subscribed_resources.flatten.join(', ')}"
      end

      failure_message do |resource|
        "expected to subscribe to #{subscribed_resources.flatten.join(', ')}"
      end

      failure_message_when_negated do |resource|
        "expected not to subscribe to #{subscribed_resources.flatten.join(', ')}"
      end
    end
  end
end
