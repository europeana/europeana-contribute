# frozen_string_literal: true

module RemoveBlankAttributes
  extend ActiveSupport::Concern

  class_methods do
    def omitted_blank_associations
      @omitted_blank_associations ||= []
    end

    def omit_blank_association(*attributes)
      attributes.each do |attribute|
        omitted_blank_associations << attribute
      end
    end
  end

  included do
    before_save :remove_blank_attributes!
    before_save :clear_omitted_blank_associations
  end

  # Do not store blank attributes (nil, "", blank-valued hashes) in MongoDB
  def remove_blank_attributes!
    attributes.each do |column, value|
      if value == '' || value.nil? || (value.is_a?(Hash) && value.values.all?(&:blank?))
        attributes.delete(column)
      end
    end
  end

  protected

  def clear_omitted_blank_associations
    return unless self.class.omitted_blank_associations.present?

    self.class.omitted_blank_associations.each do |attribute|
      field_value = send(attribute).deep_dup

      if field_value.is_a?(Array)
        field_value.reject!(&:blank?)
      elsif field_value.is_a?(Hash)
        field_value.reject! { |key, value| value.blank? }
      end

      attributes.delete(attribute) if field_value.blank?
    end
  end
end
