# frozen_string_literal: true

##
# Adds model-level support for additional attributes required for autocomplete
# inputs where the stored value may differ from that displayed.
#
# @see AutocompletableInput
module AutocompletableModel
  extend ActiveSupport::Concern

  def method_missing(method, *args, &block)
    autocomplete_method_missing(method) do |autocomplete_method, attribute|
      return send(autocomplete_method, attribute, *args, &block)
    end
    super
  end

  def respond_to_missing?(method, _include_private = false)
    autocomplete_method_missing(method) do |_autocomplete_method, _attribute|
      return true
    end
    false
  end

  def autocomplete(attribute)
    fail ArgumentError, %(Unknown attribute "#{attribute}") unless self.class.attribute_names.include?(attribute)
    return nil unless @autocomplete.present?
    @autocomplete[attribute]
  end

  def autocomplete=(attribute, value)
    fail ArgumentError, %(Unknown attribute "#{attribute}") unless self.class.attribute_names.include?(attribute)
    @autocomplete ||= HashWithIndifferentAccess.new
    @autocomplete[attribute] = value
  end

  private

  def autocomplete_method_missing(method)
    method_s = method.to_s

    %w(autocomplete autocomplete=).each do |autocomplete_method|
      method_suffix = "_#{autocomplete_method}"
      attribute = method_s.chomp(method_suffix)
      if method_s.end_with?(method_suffix) && self.class.attribute_names.include?(attribute)
        yield autocomplete_method, attribute
      end
    end
  end
end
