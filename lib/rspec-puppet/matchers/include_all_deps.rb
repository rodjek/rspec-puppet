module RSpec::Puppet
  module ManifestMatchers
    extend RSpec::Matchers::DSL

    matcher :include_all_deps do
      @failed_resource=""

      match do |catalogue|
  retval=true
        # Build a hash of defined resources
        @reshash = { }
        catalogue.vertices.each do |vertix|
          if vertix.class == Puppet::Resource then
            @reshash["#{vertix.type.to_s}[#{vertix.title}]"]=1
            vertix.each do |param,value|
              if param == :alias then
                @reshash["#{vertix.type.to_s}[#{value}]"]=1
              end
            end
          end
        end
        def check_resource (res)
          return true if 1 == @reshash["#{res.type.to_s}[#{res.title.to_s}]"]
          res.each do |param,value|
            if param == :alias then
              return true if 1 == @reshash["#{res.type.to_s}[#{value}]"]
            end
          end
          return false
        end
        catalogue.vertices.each do |vertix|
          if vertix.class.to_s == "Puppet::Resource" then
            vertix.each do |param,value|
              if param == :require or
             param == :subscribe or
                 param == :notify or
                 param == :before then
                 if value.class == Puppet::Resource then
                   next if check_resource(value)
       @failed_resource="#{value.type.to_s}['#{value.title.to_s}'] used at #{vertix.file.to_s}[#{vertix.line.to_s}] in #{vertix.type.to_s}['#{vertix.title.to_s}']"
                   retval=false
                 elsif value.class == Array then
                   value.each do |val|
                     if val.class == Puppet::Resource then
                       next if check_resource(val)
           @failed_resource="#{val.type.to_s}['#{val.title.to_s}'] used at #{vertix.file.to_s}[#{vertix.line.to_s}] in #{vertix.type.to_s}['#{vertix.title.to_s}']"
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
