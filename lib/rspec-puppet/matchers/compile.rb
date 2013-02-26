module RSpec::Puppet
  module ManifestMatchers
    extend RSpec::Matchers::DSL

    matcher :compile do
      @failed_resource = ""
      @check_deps = false
      @cycles = []

      chain :with_all_deps do
        @check_deps = true
      end

      match do |catalogue|
        retval = true

        begin
          cat = catalogue.to_ral.relationship_graph
          cat.write_graph(:resources)
          if cat.respond_to? :find_cycles_in_graph
            cycles = cat.find_cycles_in_graph
            if cycles.length > 0
              cycles.each do |cycle|
                paths = cat.paths_in_cycle(cycle)
                @cycles << (paths.map{ |path| '(' + path.join(" => ") + ')'}.join("\n") + "\n")
              end
              retval = false
            end
          else
            begin
              cat.topsort
            rescue Puppet::Error => e
              @cycles = [e.message.rpartition(';').first.partition(':').last]
              retval = false
            end
          end
        rescue Puppet::Error
          retval = false
        end

        if @check_deps == true
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
                        retval = false
                      end
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
        "compile the catalogue without cycles"
      end

      failure_message_for_should do |actual|
        unless @cycles.empty?
          "dependency cycles found: #{@cycles.join('; ')}"
        else
          "expected that the catalogue would include #{@failed_resource}"
        end
      end
    end
  end
end
