module RSpec::Puppet
  module FunctionExampleGroup
    def subject
      function_name = self.class.top_level_description.downcase

      Puppet::Parser::Functions.autoloader.loadall

      scope = Puppet::Parser::Scope.new

      func_args = self.respond_to?(:args) ? args : nil

      lambda { scope.send("function_#{function_name}".to_sym, args) }.call
    end
  end
end
