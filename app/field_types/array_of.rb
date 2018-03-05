# frozen_string_literal: true

module ArrayOf
  class << self
    def type(klass)
      fail ArgumentError, "Expected a Class, got a #{klass}" unless klass.is_a?(Class)
      class_name = "#{self}::#{klass}"
      const_defined?(class_name) ? const_get(class_name) : subclass_array_for(klass)
    end

    def namespaces?(klass)
      "#{klass}".split('::').first == 'ArrayOf'
    end

    protected

    # @param klass [Class]
    # @return [Class] dynamically named and declared class subclassing Array,
    #   within `ArrayOf` module namespace
    # TODO: handle namespaced classes, e.g. RDF::URI
    def subclass_array_for(klass)
      array_subclass = Class.new(::Array) do
        class << self
          attr_reader :element_type

          def mongoize(object)
            if object.is_a?(::Array)
              evolve(object).map { |obj| element_type.mongoize(obj) }
            else
              element_type.mongoize(object)
            end
          end
        end
      end

      array_subclass.instance_variable_set(:@element_type, klass)
      const_set(klass.to_s, array_subclass)
    end
  end
end
