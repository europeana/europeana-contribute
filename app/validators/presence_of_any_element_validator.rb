# frozen_string_literal: true

##
# Presence validator rejecting blank values within an array
#
# Because `[''].blank? #=> false`
class PresenceOfAnyElementValidator < ActiveModel::Validations::PresenceValidator
  def validate_each(record, attribute, value)
    return super unless value.is_a?(Array)
    super(record, attribute, value.reject(&:blank?))
  end
end
