module RSpec::Puppet::Helpers
  module Relationships
    def resource_ref(resource)
      resource.respond_to?(:to_ref) ? resource.to_ref : resource
    end

    def resource_from_ref(ref)
      ref.is_a?(Puppet::Resource) ? ref : catalogue.resource(ref)
    end

    def canonicalize_resource(resource)
      res = resource_from_ref(resource_ref(resource))

      if res.nil?
        resource = Struct.new(:type, :title).new(*catalogue.title_key_for_ref(resource)) if resource.is_a?(String)

        res = catalogue.resource_keys.select { |type, title|
          type == resource.type
        }.map { |type, title|
          catalogue.resource(type, title)
        }.compact.find { |cat_res|
          cat_res.builtin_type? && cat_res.uniqueness_key.first == resource.title
        }
      end

      res
    end

    def canonicalize_resource_ref(ref)
      resource_ref(resource_from_ref(ref))
    end

    def relationship_refs(resource, relationship_type, visited = Set.new)
      resource = canonicalize_resource(resource)
      results = Set.new
      return results if resource.nil?

      if visited.include?(resource.object_id)
        return [canonicalize_resource_ref(resource)]
      end
      
      visited << resource.object_id

      Array[resource[relationship_type]].flatten.compact.each do |r|
        results << canonicalize_resource_ref(r)
        results << relationship_refs(r, relationship_type, visited)

        res = canonicalize_resource(r)
        if res && res.builtin_type?
          results << res.to_ref
          results << "#{res.type.to_s.capitalize}[#{res.uniqueness_key.first}]"
        end
      end

      # Add any autorequires
      Puppet::Type.suppress_provider
      if relationship_type == :require && resource.resource_type.respond_to?(:eachautorequire)
        resource.resource_type.eachautorequire do |t, b|
          Array(resource.to_ral.instance_eval(&b)).each do |dep|
            res = "#{t.to_s.capitalize}[#{dep}]"

            if r = relationship_refs(res, relationship_type, visited)
              results << res
              results << r
            end
          end
        end
      end
      Puppet::Type.unsuppress_provider

      results.flatten
    end

    def self_or_upstream(vertex)
      [vertex] + catalogue.upstream_from_vertex(vertex).keys
    end

    def precedes?(first, second)
      return false if first.nil? || second.nil?

      self_or_upstream(first).each do |u|
        self_or_upstream(second).each do |v|
          before_refs = relationship_refs(u, :before) + relationship_refs(u, :notify)
          require_refs = relationship_refs(v, :require) + relationship_refs(u, :subscribe)

          if before_refs.include?(v.to_ref) || require_refs.include?(u.to_ref) || (before_refs & require_refs).any?
            return true
          end
        end
      end

      false
    end

    def notifies?(first, second)
      return false if first.nil? || second.nil?

      self_or_upstream(first).each do |u|
        self_or_upstream(second).each do |v|
          notify_refs = relationship_refs(u, :notify)
          subscribe_refs = relationship_refs(v, :subscribe)

          if notify_refs.include?(v.to_ref) || subscribe_refs.include?(u.to_ref)
            return true
          end
        end
      end

      false
    end
  end
end
