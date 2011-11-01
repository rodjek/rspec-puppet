module RSpec::Puppet
  module FunctionExampleGroup
    include RSpec::Puppet::FunctionMatchers

    def subject
      function_name = self.class.top_level_description.downcase

      Puppet[:modulepath] = self.respond_to?(:module_path) ? module_path : RSpec.configuration.module_path
      Puppet[:libdir] = Dir["#{Puppet[:modulepath]}/*/lib"].entries.join(':')
      Puppet::Parser::Functions.autoloader.loadall

      scope = Puppet::Parser::Scope.new

      scope.method "function_#{function_name}".to_sym
    end
  end
end
