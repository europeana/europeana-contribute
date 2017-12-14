# frozen_string_literal: true

##
# Pages with HTML forms
module FormFillingView
  extend ActiveSupport::Concern

  protected

  def form_field_for(object, *attrs, **options)
    # ORE::Aggregation => "ore_aggregation"
    field_name = object.class.to_s.split('::').map(&:underscore).join('_')
    value = object

    while attribute = attrs.shift
      suffix = attrs.blank? ? '' : '_attributes'
      attribute_name = "[#{attribute}#{suffix}]"
      field_name = "#{field_name}#{attribute_name}"
      value = value.send(attribute)
    end

    form_field(field_name, value, options)
  end

  def form_field(name, value = nil, **options)
    options.reverse_merge!(label: false)

    if options.delete(:autocomplete)
      options[:name_text] = name.sub(%r{([^\[\]]+)(\])?\z}, '\1_text\2')
    end

    {
      name: name,
      id: sanitize_to_id(name),
      value: value,
      is_select: options.delete(:select) || false,
      is_required: options.delete(:required) || false,
      is_textarea: options.delete(:textarea) || false,
      is_subset: options.delete(:subset) || false,
    }.merge(options)
  end

  def blank_item
    { label: '', value: '' }
  end
end
