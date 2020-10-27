# frozen_string_literal: true

module RSpec
  module Puppet
    module ManifestMatchers
      extend RSpec::Matchers::DSL

      matcher :have_unique_values_for_all do |type, attribute|
        match do |catalogue|
          catalogue.call.resources.select { |rsrc| rsrc.type == type.capitalize }
                   .group_by { |rsrc| rsrc[attribute.to_sym] }
                   .all? { |_, group| group.size == 1 }
        end

        description do
          "have unique attribute values for #{type.capitalize}[#{attribute.to_sym}]"
        end

        if RSpec::Version::STRING < '3'
          failure_message_for_should do |_actual|
            "expected that the catalogue would have no duplicate values for #{type.capitalize}[#{attribute.to_sym}]"
          end
        else
          failure_message do |_actual|
            "expected that the catalogue would have no duplicate values for #{type.capitalize}[#{attribute.to_sym}]"
          end
        end
      end
    end
  end
end
