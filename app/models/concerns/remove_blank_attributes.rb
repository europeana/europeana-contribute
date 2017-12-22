# frozen_string_literal: true

module RemoveBlankAttributes
  extend ActiveSupport::Concern

  included do
    before_save :remove_blank_attributes!
  end

  # Do not store blank attributes (nil, "", blank-valued hashes) in MongoDB
  def remove_blank_attributes!
    attributes.each do |column, value|
      if value == '' || value.nil? || (value.is_a?(Hash) && value.values.all?(&:blank?))
        attributes.delete(column)
      end
    end
  end
end
