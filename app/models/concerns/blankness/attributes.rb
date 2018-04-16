# frozen_string_literal: true

module Blankness
  # Detect blank attributes, and reject them before saving a model
  #
  # Requirements of an including model:
  # * implements `#attributes`, returning a `Hash` of the models attributes
  # * is extended with `ActiveModel::Callbacks` and defines the `:save` callback
  module Attributes
    extend ActiveSupport::Concern
    include Check

    included do
      before_save :reject_blank_values!
      before_save :reject_blank_attributes!
      checks_blankness_with :all_attributes_blank?
    end

    def all_attributes_blank?
      attributes.keys.all? do |name|
        ignore_attribute_presence?(name) || blank_attribute?(name)
      end
    end

    def blank_attribute?(name)
      blank_attribute_value?(attributes.with_indifferent_access[name])
    end

    def blank_attribute_value?(value)
      if value == '' || value.nil?
        true
      elsif value.is_a?(Hash) || value.is_a?(Array)
        values = value.is_a?(Hash) ? value.values : value
        values.all? { |element| blank_attribute_value?(element) }
      else
        false
      end
    end

    # Override in including class if attributes should be conditionally
    # rejectable, i.e. some should never be rejected
    def rejectable_attribute?(_name)
      true
    end

    # Override in including class if attributes should be ignored when checking
    # all for blankness
    def ignore_attribute_presence?(_name)
      false
    end

    protected

    def reject_blank_values!
      attributes.each_pair do |name, value|
        if value.is_a?(Hash)
          value.reject! { |_sub_name, sub_value| blank_attribute_value?(sub_value) }
        elsif value.is_a?(Array)
          value.reject! { |sub_value| blank_attribute_value?(sub_value) }
        end
      end
    end

    # Do not store blank attributes (nil, "", blank-valued hashes)
    def reject_blank_attributes!
      return if attributes.frozen?

      attributes.reject! do |name, _value|
        rejectable_attribute?(name) && blank_attribute?(name)
      end
    end
  end
end
