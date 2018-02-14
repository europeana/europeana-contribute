# frozen_string_literal: true

class PresenceOfAnyValidator < ActiveModel::Validator
  def validate(record)
    unless options[:of].any? { |attr| record.send(:"#{attr}?") }
      msg = error_msg(record)
      options[:of].each do |attr|
        record.errors.add(attr, msg)
      end
    end
  end

  def error_msg(record)
    attribute_name_sentence = options[:of].map { |attr| record.class.human_attribute_name(attr) }.
                                           to_sentence(last_word_connector: ' or ')
    'one of ' + attribute_name_sentence + ' is required'
  end
end
