# frozen_string_literal: true

module RemoveBlankAttributes
  extend ActiveSupport::Concern

  included do
    before_save :remove_blank_attributes!
  end

  # Do not store blank attributes (nil, "") in MongoDB
  def remove_blank_attributes!
    attributes.each do |column, value|
      attributes.delete(column) if value == '' || value.nil?
    end
  end
end
