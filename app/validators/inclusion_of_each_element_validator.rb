# frozen_string_literal: true

# Inclusion validator for each element of an array
#
# Triggers +ActiveModel+'s +:inclusion+ validation, but on each element of an
# attribute whose value is an +Array+.
#
# @example
#   class Garment
#     include ActiveModel::Model
#     attr_accessor :sizes
#     validates :sizes, inclusion_of_each_element: { in: %i(small medium large) }
#   end
#
#   scarf = Garment.new(sizes: %i(small large))
#   scarf.valid? #=> true
#
#   coat = Garment.new(sizes: %i(tiny small medium large huge))
#   coat.valid? #=> false
class InclusionOfEachElementValidator < ActiveModel::Validations::InclusionValidator
  def validate_each(record, attribute, value)
    return super unless value.is_a?(Array)
    value.each do |val|
      super(record, attribute, val)
    end
  end
end
