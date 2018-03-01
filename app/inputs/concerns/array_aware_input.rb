# frozen_string_literal: true

module ArrayAwareInput
  extend ActiveSupport::Concern

  def input(wrapper_options = nil)
    return array_element_input(nil, wrapper_options) if wrapper_options[:value]

    value = @builder.object.send(attribute_name)

    return array_element_input(nil, wrapper_options) unless value.is_a?(Array)

    value.push('') if value.blank?
    element_fields = value.each_with_index.map do |one, index|
      element_input = array_element_input(index, wrapper_options.merge(value: one, multiple: true))
      element_input.gsub!(/ (id|data-for)="(.*?)"/, %( \\1="\\2_#{index}"))
      @builder.template.content_tag(:li, element_input.html_safe, class: 'input array-element')
    end

    rendered = element_fields.join
    rendered.gsub!(' multiple="multiple"', '') unless input_html_options[:multiple]
    @builder.template.content_tag(:ul, rendered.html_safe, class: 'input array').html_safe
  end
end
