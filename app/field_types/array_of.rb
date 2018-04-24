# frozen_string_literal: true

# Dynamic creation of classes like +ArrayOf::Date+ used to typecast the elements
# of array fields when assigning them to Mongoid fields.
#
# Classes created by this module sub-class +Array+ and implement +#mongoize+ to
# convert each array element into the required type.
#
# These classes offer no further typecasting of elements than during mongoization.
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
        const_defined?(klass.to_s, false) ? const_get(klass.to_s, false) : subclass_array_for(klass)
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
    def subclass_array_for(klass)
      array_subclass = new_array_subclass
      array_subclass.instance_variable_set(:@element_type, klass)
      set_const_for_subclass(klass, array_subclass)
    end

    def new_array_subclass
      Class.new(::Array) do
        class << self
          attr_reader :element_type

          def mongoize(object)
            if object.is_a?(::Array)
              evolve(object).map { |obj| element_type.mongoize(obj) }
            else
              element_type.mongoize(object)
            end
          end

          # *NB:* Demongoizing does not initialize an instance of the +ArrayOf::+ class.
          # This is intentional behaviour, because +Mongoid::Document+ attribute getters
          # always demongoize, so creating new objects makes the document attribute immutable
          # by methods called on the return value of the getter, e.g. +#push+.
          def demongoize(object)
            if object.is_a?(::Array)
              # Alter the object itself so that Mongoid document fields can be
              # typecast but remain mutable.
              object.map! do |obj|
                element_type.demongoize(obj)
              end
            else
              element_type.demongoize(object)
            end
          end
        end
      end
    end

    def set_const_for_subclass(klass, array_subclass)
      modules = klass.to_s.split('::')
      const_target = self

      while module_const = modules.shift
        unless const_target.const_defined?(module_const, false)
          const_target.const_set(module_const, modules.blank? ? array_subclass : Module.new)
        end
        const_target = const_target.const_get(module_const, false)
      end

      const_target
    end
  end
end
