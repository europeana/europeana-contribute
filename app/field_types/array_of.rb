# frozen_string_literal: true

# Dynamic creation of classes like +ArrayOf::Date+ used to typecast the elements
# of array fields when assigning them to Mongoid fields.
#
# Classes created by this module sub-class +Array+ and implement +#mongoize+ to
# convert each array element into the required type.
#
# These classes offer no further typecasting of elements than during mongoization.
#
# *NB:* Demongoizing does not initialize an instance of the +ArrayOf::+ class.
# This is intentional behaviour, because +Mongoid::Document+ attribute getters
# always demongoize, so creating new objects makes the document attribute immutable
# by methods called on the return value of the getter, e.g. +#push+.
#
# @example Typing a Mongoid field with class factory
#   class Event
#     include Mongoid::Document
#     field :dates, type: ArrayOf.type(Date)
#   end
#
# @example Typing a Mongoid field with pre-constructed class
#   ArrayOf.type(Date) #=> ArrayOf::Date
#   class Event
#     include Mongoid::Document
#     field :dates, type: ArrayOf::Date
#   end
#
# @example Mongoizing a typed field
#   event = Event.new
#   event.dates = ['2018-01-01', '2018-01-02']
#   event.dates #=> [2018-01-01 00:00:00 UTC, 2018-01-02 00:00:00 UTC]
#   event.dates.class #=> Array
#
# @see ArrayOfAttributeValidation
module ArrayOf
  class << self
    # +ArrayOf+ class factory
    #
    # @param klass [Class] Class to mongoize array elements to
    # @return [Class] Sub-class of +Array+ in +ArrayOf+ module
    # @raise [ArgumentError] if the +klass+ param is not a class
    #
    # @example Creation of an +Array+ sub-class
    #   klass = ArrayOf.type(DateTime) #=> ArrayOf::DateTime
    #   array_of_date_time = klass.new
    #   array_of_date_time.class #=> ArrayOf::DateTime
    def type(klass)
      fail ArgumentError, "Expected a Class, got a #{klass}" unless klass.is_a?(Class)
      types[klass] ||= begin
        class_name = "#{self}::#{klass}"
        const_defined?(class_name) ? const_get(class_name) : subclass_array_for(klass)
      end
    end

    # Registry of classes created by +.type+
    #
    # @return [Hash<Class, Class>] keys are the array element class, values are
    #   the generated +Array+ sub-class
    #
    # @example
    #   ArrayOf.types #=> {}
    #   ArrayOf.type(Float)
    #   ArrayOf.types #=> { Float => ArrayOf::Float }
    def types
      @types ||= {}
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
