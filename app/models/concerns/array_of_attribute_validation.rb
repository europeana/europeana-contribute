# frozen_string_literal: true

# Validation of attribute values for Mongoid fields typed as +ArrayOf+ classes.
#
# Any +Mongoid::Document+-including class using +ArrayOf+ module classes for
# its field types should also include this module concern to ensure that
# non-array values are not permitted to be assigned to those fields.
#
# @example Failure when assigning scalar values
#   class Event
#     include Mongoid::Document
#     include ArrayOfAttributeValidation
#     field :dates, type: ArrayOf.type(Date)
#   end
#
#   Event.new(dates: '2018-01-13')
#
#   # Mongoid::Errors::InvalidValue:
#   # message:
#   #   Value of type String cannot be written to a field of type ArrayOf::Date
#
# @see ArrayOf
module ArrayOfAttributeValidation
  private

  # Overrides +Mongoid::Attributes#validate_attribute_value+
  # @param (see Mongoid::Attributes#validate_attribute_value)
  def validate_attribute_value(access, value)
    super
    return unless fields[access] && value
    return unless ArrayOf.types.values.include?(fields[access].type)
    unless value.is_a?(Array)
      raise Mongoid::Errors::InvalidValue.new(fields[access].type, value.class)
    end
  end
end
