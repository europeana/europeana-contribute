# frozen_string_literal: true

class PresenceOfAnyValidator < ActiveModel::Validator
  def validate(record)
    return if options[:of].any? { |attr| record.read_attribute_for_validation(attr).present? }

    msg = error_msg(record)
    options[:of].each do |attr|
      record.errors.add(attr, msg)
    end
  end

  def error_msg(record)
    attribute_name_sentence = options[:of].map { |attr| record.class.human_attribute_name(attr) }.
                                           to_sentence(last_word_connector: ' or ')
    'one of ' + attribute_name_sentence + ' is required'
  end
end
