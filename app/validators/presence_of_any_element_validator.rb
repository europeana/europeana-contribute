# frozen_string_literal: true

# Presence validator for any element of an array
#
# Triggers +ActiveModel+'s +:presence+ validation on the array having rejected
# blank values. Because +[''].blank? #=> false+
#
# @example
#   class Book
#     include ActiveModel::Model
#     attr_accessor :authors
#     validates :authors, presence_of_any_element: true
#   end
#
#   book = Book.new(authors: ['Anna Bell', ''])
#   book.valid? #=> true
#
#   book = Book.new(authors: ['', ''])
#   book.valid? #=> false
class PresenceOfAnyElementValidator < ActiveModel::Validations::PresenceValidator
  def validate_each(record, attribute, value)
    return super unless value.is_a?(Array)
    super(record, attribute, value.reject(&:blank?))
  end
end
