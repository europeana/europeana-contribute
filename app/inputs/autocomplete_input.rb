# frozen_string_literal: true

##
# Autocomplete input
#
# This input supports autocompletion on a text field where the displayed value
# may be different to the one to be stored.
#
# It will render two fields:
# * a hidden input field for the value to be stored, named after the model attribute
# * a text input field for the value to be displayed, having "_autocomplete"
#   appended to the attribute name
#
# The model the input is used on must support accessing the _autocomplete
# attribute, which can be achieved by including the concern `AutocompletableModel`.
#
# @see AutocompletableModel
class AutocompleteInput < SimpleForm::Inputs::StringInput
  include ArrayAwareInput

  def array_element_input(index, wrapper_options = nil)
    autocomplete_options = input_options.extract!(:url, :param)

    autocomplete_options.each_pair do |k, v|
      input_html_options[:"data-#{k}"] ||= v
    end

    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

    hidden_value = @builder.object.send(hidden_field_attribute_name)
    text_value = @builder.object.send(text_field_attribute_name)
    unless index.nil?
      hidden_value = hidden_value[index]
      text_value = text_value.is_a?(Array) ? text_value[index] : nil
    end

    hidden = @builder.hidden_field(hidden_field_attribute_name, wrapper_options.merge(value: hidden_value))
    hidden_id = hidden.match(/id="(.*?)"/)[1]

    text_field_options = merged_input_options.merge('data-for': hidden_id, value: text_value)
    hidden + @builder.text_field(text_field_attribute_name, text_field_options)
  end

  def label_target
    text_field_attribute_name
  end

  def hidden_field_attribute_name
    attribute_name
  end

  def text_field_attribute_name
    :"#{attribute_name}_autocomplete"
  end
end
