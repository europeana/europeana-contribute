# frozen_string_literal: true

class PresenceOfAnyValidator < ActiveModel::Validator
  def validate(record)
    unless options[:of].any? { |attr| record.send(:"#{attr}?") }
      options[:of].each do |attr|
        record.errors.add(attr, @error_msg)
      end
    end
  end

  def error_msg
    @error_msg ||= 'one of ' + options[:of].map do |attr|
      record.respond_to?(:rdf_fields_and_predicates) ? record.rdf_fields_and_predicates[attr].pname : attr
    end.to_sentence(last_word_connector: ' or ') + ' is required'
  end
end
