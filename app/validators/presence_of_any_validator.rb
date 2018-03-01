# frozen_string_literal: true

class PresenceOfAnyValidator < ActiveModel::Validator
  def validate(record)
    return if options[:of].any? { |attr| attribute_present_on_record?(record, attr) }

    msg = error_msg(record)
    options[:of].each do |attr|
      record.errors.add(attr, msg)
    end
  end

  def error_msg(record)
    'one of ' + attribute_name_sentence(record) + ' is required'
  end

  def attribute_name_sentence(record)
    attribute_names = options[:of].map { |attr| record.class.human_attribute_name(attr) }
    attribute_names.to_sentence(last_word_connector: ' or ')
  end

  def attribute_present_on_record?(record, attr)
    if record.is_a?(Mongoid::Document) && record.relations.key?(attr.to_s) && record.respond_to?(:blank_relation?)
      !record.blank_relation?(attr)
    elsif record.respond_to?(:blank_attribute?)
      !record.blank_attribute?(attr)
    else
      record.attributes[attr].present?
    end
  end
end
