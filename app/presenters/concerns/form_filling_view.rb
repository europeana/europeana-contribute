# frozen_string_literal: true

##
# Pages with HTML forms
module FormFillingView
  extend ActiveSupport::Concern

  class_methods do
    attr_reader :form_field_label_scope

    def scopes_form_field_labels(scope)
      @form_field_label_scope = scope
    end
  end

  protected

  def form_field_for(object, *attrs, **options)
    # ORE::Aggregation => "ore_aggregation"
    field_name = object.class.to_s.split('::').map(&:underscore).join('_')
    value = object

    local_attrs = attrs.dup
    while attribute = local_attrs.shift
      suffix = local_attrs.blank? ? '' : '_attributes'
      attribute_name = "[#{attribute}#{suffix}]"
      field_name = "#{field_name}#{attribute_name}"
      value = value.send(attribute)
    end

    options[:label] = form_field_label_for(object, *attrs) unless options.key?(:label)

    form_field(field_name, value, options)
  end

  # Given an instance of ORE::Aggregation, and attrs edm_aggregatedCHO &
  # edm_currentLocation, where edm_aggregatedCHO is an instance of EDM::ProvidedCHO
  # and if the presenter class sets form_field_label_scope to "migration", looks
  # for a label in:
  #
  # * migration.attributes.ore/aggregation.edm_aggregatedCHO.edm_currentLocation
  # * migration.attributes.edm/provided_cho.edm_currentLocation
  # * migration.attributes.edm_currentLocation
  # * attributes.ore/aggregation.edm_aggregatedCHO.edm_currentLocation
  # * attributes.edm/provided_cho.edm_currentLocation
  # * attributes.edm_currentLocation
  #
  # If none match, will delegate to EDM::ProvidedCHO.human_attribute_name(:edm_currentLocation)
  #
  # TODO: introduce "labels" into lookup scopes, and add support for "hints"
  def form_field_label_for(object, *attrs)
    presenter_scope = self.class.form_field_label_scope
    keys = []

    scoped_object = nil

    [presenter_scope, nil].uniq.each do |scope|
      scoped_attrs = attrs.dup
      scoped_object = object
      while scoped_attrs.size.positive?
        field_name = scoped_object.class.to_s.underscore
        keys << [scope, 'attributes', field_name, scoped_attrs].flatten.compact.map(&:to_s).join('.').to_sym
        child_attr = scoped_attrs.shift
        scoped_object = scoped_object.send(child_attr) unless scoped_attrs.blank?
      end
      keys << [scope, 'attributes', attrs.last].compact.map(&:to_s).join('.').to_sym
    end

    pref_key = keys.shift
    I18n.t!(pref_key, default: keys)
  rescue I18n::MissingTranslationData
    scoped_object.class.human_attribute_name(attrs.last)
  end

  def form_field(name, value = nil, **options)
    options.reverse_merge!(label: false)

    if options.delete(:autocomplete)
      options[:name_text] = name.sub(%r{([^\[\]]+)(\])?\z}, '\1_text\2')
    end

    {
      name: name,
      id: view.send(:sanitize_to_id, name),
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
