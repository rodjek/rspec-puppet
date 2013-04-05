module RSpec::Puppet
  module ManifestMatchers
    class Compile
      def initialize
        @failed_resource = ""
        @check_deps = false
        @cycles = []
      end

      def with_all_deps
        @check_deps = true
        self
      end

      def matches?(catalogue)
        @catalogue = catalogue
        if cycles_found?
          false
        elsif @check_deps == true && missing_dependencies?
          false
        else
          true
        end
      end

      def description
        "compile the catalogue without cycles"
      end

      def failure_message_for_should
        unless @cycles.empty?
          "dependency cycles found: #{@cycles.join('; ')}"
        else
          "expected that the catalogue would include #{@failed_resource}"
        end
      end

      def failure_message_for_should_not
        "expected that the catalogue would not compile but it does"
      end

      private
      def missing_dependencies?
        retval = false

        resource_vertices = @catalogue.vertices.select { |v| v.is_a? Puppet::Resource }
        resource_vertices.each do |vertex|
          vertex.each do |param,value|
            if [:require, :subscribe, :notify, :before].include? param
              value = Array[value] unless value.is_a? Array
              value.each do |val|
                if val.is_a? Puppet::Resource
                  retval = true unless resource_exists?(val, vertex)
                end
              end
            end
          end
        end

        retval
      end

      def resource_hash
        @resource_hash ||= Proc.new do
          res_hash = {}
          @catalogue.vertices.each do |vertex|
            if vertex.is_a? Puppet::Resource
              res_hash[vertex.ref] = 1
              if vertex[:alias]
                res_hash["#{vertex.type.to_s}[#{vertex[:alias]}]"] = 1
              end
            end
          end
          res_hash
        end.call
      end

      def check_resource(res)
        if resource_hash[res.ref]
          true
        elsif res[:alias] && resource_hash["#{res.type.to_s}[#{res[:alias]}]"]
          true
        else
          false
        end
      end

      def resource_exists?(res, vertex)
        unless check_resource(res)
          @failed_resource = "#{res.ref} used at #{vertex.file}:#{vertex.line} in #{vertex.ref}"
          false
        else
          true
        end
      end

      def cycles_found?
        retval = false
        begin
          cat = @catalogue.to_ral.relationship_graph
          cat.write_graph(:resources)
          if cat.respond_to? :find_cycles_in_graph
            find_cycles(cat)
          else
            find_cycles_legacy(cat)
          end
          retval = true unless @cycles.empty?
        rescue Puppet::Error
          retval = true
        end
        retval
      end

      def find_cycles(catalogue)
        cycles = catalogue.find_cycles_in_graph
        if cycles.length > 0
          cycles.each do |cycle|
            paths = catalogue.paths_in_cycle(cycle)
            @cycles << (paths.map{ |path| '(' + path.join(" => ") + ')'}.join("\n") + "\n")
          end
        end
      end

      def find_cycles_legacy(catalogue)
        begin
          catalogue.topsort
        rescue Puppet::Error => e
          @cycles = [e.message.rpartition(';').first.partition(':').last]
        end
      end
    end
  end
end
