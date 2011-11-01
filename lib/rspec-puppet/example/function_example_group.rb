module RSpec::Puppet
  module FunctionExampleGroup
    include RSpec::Puppet::FunctionMatchers

    def subject
      function_name = self.class.top_level_description.downcase

      Puppet::Parser::Functions.autoloader.loadall

      scope = Puppet::Parser::Scope.new

      scope.method "function_#{function_name}".to_sym
    end
  end
end
