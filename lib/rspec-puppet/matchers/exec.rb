module RSpec::Puppet
  module Matchers
    extend RSpec::Matchers::DSL

    matcher :create_exec do |expected_title|
      match do |catalogue|
        ret = true
        resources = catalogue.resources.select { |r|
          r.title == expected_title if r.respond_to? :title
        }

        unless resources.length == 1
          ret = false
        end

        unless @expected_command.nil?
          unless resources.first.send(:parameters)[:command] == @expected_command
            ret = false
          end
        end
        ret
      end

      description do
        "create Exec['#{expected_title}']"
      end

      failure_message_for_should do |actual|
        "expected that the catalogue would contain Exec['#{expected_title}']#{with_command_msg}"
      end

      chain :with_command do |expected_command|
        @expected_command = expected_command
      end

      def with_command_msg
        @expected_command.nil?? "" : " with the command `#{@expected_command}`"
      end
    end
  end
end
