# frozen_string_literal: true

module ArrayAwareInput
  extend ActiveSupport::Concern

  def input(wrapper_options = {})
    array_of_inputs(wrapper_options) do |_index, element_wrapper_options|
      super(element_wrapper_options)
    end
  end

  def label(wrapper_options = {})
    sup = super
    value = wrapper_options[:value] || @builder.object.send(attribute_name)
    return sup unless value.is_a?(Array)
    sup.sub(/ for="([^"]*)"/, %( for="\\1_0")).html_safe
  end

  def array_of_inputs(wrapper_options = {})
    value = wrapper_options[:value] || @builder.object.send(attribute_name)

    unless value.is_a?(Array)
      return yield nil, wrapper_options
    end

    value.push('') if value.blank?
    element_fields = value.each_with_index.map do |val, index|
      element_wrapper_options = wrapper_options.merge(value: val)
      element_input = yield index, element_wrapper_options
      element_input.gsub!(/ name="([^"]*)"/, %( name="\\1[]"))
      element_input.gsub!(/ (id|data-for)="([^"]*)"/, %( \\1="\\2_#{index}"))
      @builder.template.content_tag(:li, element_input.html_safe, class: 'input array-element')
    end

    rendered = element_fields.join
    # rendered.gsub!(' multiple="multiple"', '') unless input_html_options[:multiple]
    @builder.template.content_tag(:ul, rendered.html_safe, class: 'input array').html_safe
  end
end
