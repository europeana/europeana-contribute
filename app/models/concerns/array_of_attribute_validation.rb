# frozen_string_literal: true

module ArrayOfAttributeValidation
  private

  def validate_attribute_value(access, value)
    super
    return unless fields[access] && value
    return unless ArrayOf.types.values.include?(fields[access].type)
    unless value.is_a?(Array)
      raise Mongoid::Errors::InvalidValue.new(Array, value.class)
    end
  end
end
