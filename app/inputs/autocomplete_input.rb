# frozen_string_literal: true

class AutocompleteInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options = nil)
    autocomplete_options.each_pair do |k, v|
      input_html_options[:"data-#{k}"] ||= v
    end

    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

    hidden = @builder.hidden_field(value_attribute_name)
    hidden_id = hidden.match(/id="(.*?)"/)[1]

    text_field_options = merged_input_options.merge('data-for': hidden_id)
    hidden + @builder.text_field(text_attribute_name, text_field_options)
  end

  def autocomplete_options
    @builder.object.autocomplete_attributes[attribute_name][:options]
  end

  def label_target
    text_attribute_name
  end

  def value_attribute_name
    @builder.object.autocomplete_attributes[attribute_name][:names][:value]
  end

  def text_attribute_name
    @builder.object.autocomplete_attributes[attribute_name][:names][:text]
  end
end
