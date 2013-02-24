module RSpec::Puppet
  module ManifestMatchers
    extend RSpec::Matchers::DSL

    matcher :include_all_deps do
      @failed_resource=""

      match do |catalogue|
        retval=true
        # Build a hash of defined resources
        @res_hash = { }
        catalogue.vertices.each do |vertex|
          if vertex.is_a? Puppet::Resource
            @res_hash[vertex.ref] = 1
            if vertex[:alias]
              @res_hash["#{vertex.type.to_s}[#{vertex[:alias]}]"] = 1
            end
          end
        end

        def check_resource(res)
          if @res_hash[res.ref]
            true
          elsif res[:alias] && @res_hash["#{res.type.to_s}[#{res[:alias]}]"]
            true
          else
            false
          end
        end

        catalogue.vertices.each do |vertex|
          if vertex.is_a? Puppet::Resource
            vertex.each do |param,value|
              if [:require, :subscribe, :notify, :before].include? param
                if value.is_a? Puppet::Resource
                  next if check_resource(value)
                  @failed_resource="#{value.ref} used at #{vertex.file.to_s}:#{vertex.line.to_s} in #{vertex.ref}"
                   retval = false
                elsif value.is_a? Array
                  value.each do |val|
                    if val.is_a? Puppet::Resource
                      next if check_resource(val)
                      @failed_resource="#{val.ref} used at #{vertex.file.to_s}:#{vertex.line.to_s}: in #{vertex.ref}"
                      retval=false
                    end
                  end
                end
              end
            end
          end
        end
        retval
      end

      description do
        "include all dependencies"
      end

      failure_message_for_should do |actual|
        "expected that the catalogue would include #{@failed_resource}"
      end
    end
  end
end
