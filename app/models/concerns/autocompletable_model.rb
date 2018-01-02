# frozen_string_literal: true

module AutocompletableModel
  extend ActiveSupport::Concern

  # Supports form auto-completion on a field of this instance
  #
  # Handled *per-instance* with singleton methods because different
  # story-telling campaigns will have different auto-complete needs, e.g. on
  # different fields, or with different suggestion sources.
  #
  # @param attribute_name [Symbol] attribute of this model to auto-complete for
  # @param options [Hash] arbitrary options set as data attributes on HTML inputs
  #   by `AutocompleteInput`
  # @example
  #   cho = EDM::ProvidedCHO.new
  #   cho.extend(AutocompletableModel)
  #   cho.autocompletes(:dc_type, url: 'http://dc.example.org/types', param: 'q')
  def autocompletes(attribute_name, **options)
    @autocomplete_attributes ||= {}

    text_attribute_name = :"#{attribute_name}_text"
    value_attribute_name = :"#{attribute_name}_value"

    @autocomplete_attributes[attribute_name] = {
      options: options,
      names: {
        text: text_attribute_name,
        value: value_attribute_name
      }
    }

    unless respond_to?(:autocomplete_attributes)
      define_singleton_method(:autocomplete_attributes) do
        @autocomplete_attributes
      end
    end

    unless respond_to?(text_attribute_name)
      define_singleton_method(text_attribute_name) do
        autocomplete_attributes[attribute_name][:value]
      end
    end

    unless respond_to?(:"#{text_attribute_name}=")
      define_singleton_method(:"#{text_attribute_name}=") do |value|
        autocomplete_attributes[attribute_name][:value] = value
      end
    end

    unless respond_to?(value_attribute_name)
      define_singleton_method(value_attribute_name) do
        attributes[attribute_name]
      end
    end

    unless respond_to?(:"#{value_attribute_name}=")
      define_singleton_method(:"#{value_attribute_name}=") do |value|
        attributes[attribute_name] = value
      end
    end
  end
end
