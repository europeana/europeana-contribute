# frozen_string_literal: true

##
# Inclusion validator for *each* member of an array
class InclusionOfEachValidator < ActiveModel::Validations::InclusionValidator
  def validate_each(record, attribute, value)
    return super unless value.is_a?(Array)
    value.each do |val|
      super(record, attribute, val)
    end
  end
end
