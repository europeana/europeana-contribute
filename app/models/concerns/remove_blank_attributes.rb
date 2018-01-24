# frozen_string_literal: true

module RemoveBlankAttributes
  extend ActiveSupport::Concern

  included do
    before_save :remove_blank_embeds!
    before_save :remove_blank_attributes!
  end

  def blank?
    blank_attributes? && blank_embeds?
  end

  def blank_attributes?
    attributes.keys.all? do |name|
      name.start_with?('_') || blank_attribute?(name)
    end
  end

  def blank_embeds?
    embedded_relations.keys.all? do |name|
      blank_relation?(name)
    end
  end

  def blank_attribute?(name)
    blank_attribute_value?(attributes[name])
  end

  def blank_relation?(name)
    blank_relation_value?(send(name))
  end

  def blank_relation_value?(value)
    if value.is_a?(Array) && value.all?(&:blank?)
      true
    elsif value.blank?
      true
    else
      false
    end
  end

  def blank_attribute_value?(value)
    if value == '' || value.nil?
      true
    elsif value.is_a?(Hash) && value.values.all?(&:blank?)
      true
    elsif value.is_a?(Array) && value.all?(&:blank?)
      true
    else
      false
    end
  end

  def embedded_relations
    relations.select { |_k, relation| %i(embeds_one embeds_many).include?(relation.macro) }
  end

  protected

  # Do not store blank attributes (nil, "", blank-valued hashes) in MongoDB
  def remove_blank_attributes!
    fail "Attributes frozen on #{self.inspect}" if attributes.frozen?

    attributes.reject! do |name, _value|
      !name.start_with?('_') && blank_attribute?(name)
    end
  end

  # Do not store blank embeds in MongoDB
  def remove_blank_embeds!
    embedded_relations.keys.each do |name|
      value = send(name)
      next if value.nil?

      if value.is_a?(Array)
        value.reject! do |element|
          blank_relation_value?(element)
        end
      end

      value.clear if blank_relation?(name)
    end
  end
end
