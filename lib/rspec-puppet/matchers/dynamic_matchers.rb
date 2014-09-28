module RSpec::Puppet
  module ManifestMatchers
    def method_missing(method, *args, &block)
      return RSpec::Puppet::ManifestMatchers::CreateGeneric.new(method, *args, &block) if method.to_s =~ /^(create|contain)_/
      return RSpec::Puppet::ManifestMatchers::CountGeneric.new(nil, args[0], method) if method.to_s =~ /^have_.+_count$/
      return RSpec::Puppet::ManifestMatchers::Compile.new if method == :compile
      super
    end
  end

  module FunctionMatchers
    def method_missing(method, *args, &block)
      return RSpec::Puppet::FunctionMatchers::Run.new if method == :run
      super
    end
  end

  module TypeMatchers
    def method_missing(method, *args, &block)
      return RSpec::Puppet::TypeMatchers::CreateGeneric.new(method, *args, &block) if method == :be_valid_type
      super
    end
  end
end
