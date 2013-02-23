module RSpec::Puppet
  module ManifestMatchers
    def method_missing(method, *args, &block)
      return RSpec::Puppet::ManifestMatchers::CreateGeneric.new(method, *args, &block) if method.to_s =~ /^(create|contain)_/
      return RSpec::Puppet::ManifestMatchers::CountGeneric.new(nil, args[0], method) if method.to_s =~ /^have_.+_count$/
      super
    end
  end
end
