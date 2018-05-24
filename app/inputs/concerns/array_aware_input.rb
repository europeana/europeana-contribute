# frozen_string_literal: true

# Mixin to make +SimpleForm+ inputs aware of arrays of attributes
module ArrayAwareInput
  extend ActiveSupport::Concern

  # Calls +super+ to generate the form input for each value of the array.
  #
  # @param wrapper_options [Hash]
  # @return [String] HTML for the label
  def input(wrapper_options = {})
    array_of_inputs(wrapper_options) do |_index, element_wrapper_options|
      super(element_wrapper_options)
    end
  end

  # Associates the label with the first of the multiple input fields for the array.
  #
  # @param wrapper_options [Hash]
  # @return [String] HTML for the label
  # @see SimpleForm::Components::Labels#label which this overrides
  def label(wrapper_options = {})
    sup = super
    value = wrapper_options[:value] || @builder.object.send(attribute_name)
    return sup unless value.is_a?(Array)
    sup.sub(/ for="([^"]*)"/, %( for="\\1_0")).html_safe
  end

  # Generates inputs for all elements of an array.
  #
  # Yields each value in the array to a block which should generate the input
  # HTML for one that one element, then processes the HTML to make it compatible
  # with Rails handling of arrays from forms.
  #
  # The inputs will each be wrapper in an +<li>+ element, all gathered into a
  # +<ul>+.
  #
  # @param wrapper_options [Hash]
  # @return [String] HTML for the array of inputs for this field
  # @yieldparam index [Integer,NilClass] index of the element to render an input for
  # @yieldparam element_wrapper_options [Hash] wrapper options for the element,
  #   including +:value+
  # @yieldreturn [String] rendered input for one element (without array awareness)
  def array_of_inputs(wrapper_options = {})
    value = wrapper_options[:value] || @builder.object.send(attribute_name)

    unless value.is_a?(Array)
      return yield nil, wrapper_options
    end

    value.push('') if value.blank? # otherwise, no input
    element_fields = value.each_with_index.map do |val, index|
      element_wrapper_options = wrapper_options.merge(value: val)
      element_input = yield index, element_wrapper_options
      element_input.gsub!(/ name="([^"]*)"/, %( name="\\1[]")) # append "[]" to name attr
      element_input.gsub!(/ (id|data-for)="([^"]*)"/, %( \\1="\\2_#{index}")) # append "_n" where n is element index
      @builder.template.content_tag(:li, element_input.html_safe, class: 'input array-element')
    end

    ul_options = { class: 'input array' }
    include_field_template(element_fields, ul_options) if options[:include_template]

    rendered = element_fields.join
    @builder.template.content_tag(:ul, rendered.html_safe, ul_options).html_safe
  end

  def include_field_template(element_fields, array_options)
    element_field_template = CGI.escapeHTML(element_fields.first.gsub(%(_0"), %(_[[index]]")).gsub(/value=".*?"/,''))
    array_options['data-array-field-template'] = element_field_template
    array_options
  end
end
