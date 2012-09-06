module RSpec::Puppet
  module ManifestMatchers
    extend RSpec::Matchers::DSL

    matcher :create_resource do |expected_type, expected_title|
      match do |catalogue|
        ret = true
        resources = catalogue.resources.select { |r|
          r.type == referenced_type(expected_type)
        }.select { |r|
          if expected_title.class.to_s == 'Regexp' then
            (expected_title.match(r.title) != nil) if r.respond_to? :title
          else
            r.title == expected_title if r.respond_to? :title
          end
        }

        unless resources.length == 1
          ret = false
        end

        if @expected_params and resources.length != 0
          @expected_params.each do |name, value|
            unless resources.first.send(:parameters)[name.to_sym] == value
              ret = false
              (@errors ||= []) << "the parameter #{name.to_s} set to `#{value}`"
            end
          end
        end

        ret
      end

      def errors
        @errors.nil? ? "" : " with #{@errors.join(', ')}"
      end

      def referenced_type(type)
        type.split('::').map { |r| r.capitalize }.join('::')
      end

      chain :with_param do |param_name,param_value|
        (@expected_params ||= []) << [param_name, param_value]
      end

      description do
        type = referenced_type(expected_type)
        if expected_title.class.to_s == 'Regexp' then
          "create #{type} matching a Regexp"
        else
          "create #{type}['#{expected_title}']"
        end
      end

      failure_message_for_should do |actual|
        type = referenced_type(expected_type)
        if expect_title.class.to_s == 'Regexp' then
          "expected that the catalogue would contain #{type}[matching Regexp]#{errors}"
        else
          "expected that the catalogue would contain #{type}['#{expected_title}']#{errors}"
        end
      end
    end
  end
end
