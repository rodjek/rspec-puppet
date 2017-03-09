module RSpec::Puppet
  module TypeMatchers

    class CreateGeneric

      def initialize(*args, &block)

        @exp_provider = nil
        @exp_parameters       = []
        @exp_properties       = []
        @exp_features         = []
        @exp_defaults         = {}
        @params_with_values   = {}
        @errors               = []
      end

      # specifies a provider to validate
      def with_provider(name)
        @exp_provider = name
        self
      end

      # ensures the listed properties are valid
      def with_properties(props)
        @exp_properties = @exp_properties | Array(props)
        self
      end

      # ensures the listed parameters are valid
      def with_parameters(params)
        @exp_parameters = @exp_parameters | Array(params)
        self
      end

      # ensure the type has the list of features
      def with_features(features)
        @exp_features = @exp_features | Array(features)
        self
      end

      #
      # ensures that the specified parameters with their values
      # results in a valid resource
      #
      def with_set_attributes(params)
        @params_with_values.merge!(params)
        self
      end

      def with_defaults(defaults_hash)
        @exp_defaults.merge!(defaults_hash)
        self
      end

      #def with_autorequires(autorequires))
      #end

      #
      # this is the method that drives all of the validation
      #
      def matches?(type_title_and_params)
        type   = type_title_and_params[0]
        title  = type_title_and_params[1]
        params = type_title_and_params[2]
        unless match_params(type) && match_props(type) && match_features(type)
         return false
        end
        if @params_with_values != {} || @exp_provider
          # only build a resource if we are validating provider or setting
          # additional parameters
          resource = be_valid_resource(type, title, params.merge(@params_with_values))
          match_default_provider(resource) and match_default_values(resource)
        else
          true
        end
      end

      # checks that the specified params exist
      def match_params(type)
        match_attrs(type, @exp_parameters, :parameter)
      end

      # checks that the specified properties exist
      def match_props(type)
        match_attrs(type, @exp_properties, :property)
      end

      # checks that the specified features exist
      def match_features(type)
        match_attrs(type, @exp_features, :feature)
      end

      # builds the resource with the specified param values
      def be_valid_resource(type, title, params)
        params[:name] ||= title
        type.new(params)
      end

      #
      # checks that the expected provider is set
      #
      def match_default_provider(resource)
        if @exp_provider
          if resource[:provider] == @exp_provider
            return true
          else
            @errors.push("Expected provider: #{@exp_provider} does not match: #{resource[:provider]}")
            return false
          end
        else
          return true
        end
      end

      def match_default_values(resource)
        # TODO FINISH
        true
      end

      def description
        "be a valid type"
      end

      def failure_message
        "Not a valid type #{@errors.inspect}"
      end

      private

        def match_attrs(type, attrs, attr_type)
          baddies = []
          attrs.each do |param|
            param = param.to_sym
            if attr_type == :feature
              unless type.provider_feature(param)
                baddies.push(param)
              end
            elsif ! type.send("valid#{attr_type}?".to_sym, param)
              baddies.push(param)
            end
          end
          if baddies.size > 0
            @errors.push("Invalid #{pluralize(attr_type)}: #{baddies.join(',')}")
            false
          else
            true
          end
        end

        def pluralize(name)
          if name == :property
            "properties"
          else
            "#{name}s"
          end
        end

    end

  end
end
